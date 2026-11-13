# Лабораторна робота №4: IaC. Terraform. Ansible (Варіант 6)

## Опис індивідуального завдання (Варіант N = 6)

- **V2 = (6 % 2) + 1 = 1**: СУБД **MariaDB** (порт `3306`), конфігурація застосунку через аргументи командного рядка.
- **V3 = (6 % 3) + 1 = 1**: Веб-застосунок **Notes Service** (`mywebapp`).
- **V5 = (6 % 5) + 1 = 2**: Порт застосунку **5200** (`127.0.0.1:5200`).

## Архітектура системи

- **VM1 (`lab4-worker`)**: Nginx (`0.0.0.0:80`) + Web-застосунок (`127.0.0.1:5200`) під користувачем `app`.
- **VM2 (`lab4-db`)**: MariaDB (`<VM2-IP>:3306`) з доступом виключно з VM1 (`worker`).

## Попередні вимоги на хості (Linux)

1. Встановлені `terraform`, `ansible`, `qemu-kvm` / `libvirt`.
2. Наявний SSH-ключ `~/.ssh/id_ed25519.pub` (за потреби згенерувати: `ssh-keygen -t ed25519`).
3. Встановлені колекції Ansible:
   `ansible-galaxy collection install community.general community.mysql ansible.posix`

## Інструкція із запуску

### 1. Розгортання віртуальних машин (Terraform)

```bash
cd terraform
terraform init
terraform apply -auto-approve
```
