terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "lab4_pool" {
  name = "lab4_pool"
  type = "dir"
  path = "/var/lib/libvirt/images/lab4_pool"
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-22.04-base.qcow2"
  pool   = libvirt_pool.lab4_pool.name
  source = var.ubuntu_image_url
  format = "qcow2"
}

resource "libvirt_network" "lab4_net" {
  name      = "lab4_net"
  mode      = "nat"
  domain    = "lab4.local"
  addresses = [var.network_cidr]
  dhcp {
    enabled = true
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    ssh_public_key = file(pathexpand(var.ssh_public_key_path))
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  pool      = libvirt_pool.lab4_pool.name
  user_data = data.template_file.user_data.rendered
}

# VM1: WORKER (Nginx + WebApp)
resource "libvirt_volume" "worker_disk" {
  name           = "worker-disk.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  pool           = libvirt_pool.lab4_pool.name
  size           = 10737418240
}

resource "libvirt_domain" "worker" {
  name      = "lab4-worker"
  memory    = "1024"
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id     = libvirt_network.lab4_net.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.worker_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

# VM2: DB (MariaDB)
resource "libvirt_volume" "db_disk" {
  name           = "db-disk.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  pool           = libvirt_pool.lab4_pool.name
  size           = 10737418240
}

resource "libvirt_domain" "db" {
  name      = "lab4-db"
  memory    = "1024"
  vcpu      = 1
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  network_interface {
    network_id     = libvirt_network.lab4_net.id
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.db_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
}

# Автоматична генерація Ansible Inventory
resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content  = <<-EOT
    [workers]
    worker ansible_host=${libvirt_domain.worker.network_interface[0].addresses[0]}

    [db]
    db ansible_host=${libvirt_domain.db.network_interface[0].addresses[0]}

    [all:vars]
    ansible_user=ansible
    ansible_ssh_common_args='-o StrictHostKeyChecking=no'
  EOT
}