variable "ssh_public_key_path" {
  description = "Шлях до публічного SSH-ключа студента"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ubuntu_image_url" {
  description = "Офіційний Cloud-образ Ubuntu 22.04"
  type        = string
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "network_cidr" {
  description = "Підмережа для віртуальних машин"
  type        = string
  default     = "192.168.122.0/24"
}