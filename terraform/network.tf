# Создаем VPC
resource "yandex_vpc_network" "mycourseproject-network" {
  name = "${var.project_name}-network"
}

# Публичная подсеть в зоне A
resource "yandex_vpc_subnet" "public-subnet-a" {
  name           = "${var.project_name}-public-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.mycourseproject-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Публичная подсеть в зоне B
resource "yandex_vpc_subnet" "public-subnet-b" {
  name           = "${var.project_name}-public-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.mycourseproject-network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

# Приватная подсеть в зоне A
resource "yandex_vpc_subnet" "private-subnet-a" {
  name           = "${var.project_name}-private-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.mycourseproject-network.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = yandex_vpc_route_table.private-rt.id
}

# Приватная подсеть в зоне B
resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "${var.project_name}-private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.mycourseproject-network.id
  v4_cidr_blocks = ["192.168.40.0/24"]
  route_table_id = yandex_vpc_route_table.private-rt-b.id
}

# Таблица маршрутизации для приватных подсетей
resource "yandex_vpc_route_table" "private-rt" {
  network_id = yandex_vpc_network.mycourseproject-network.id
  name       = "${var.project_name}-private-rt"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}

# Обновляем таблицу маршрутизации для приватной подсети B
resource "yandex_vpc_route_table" "private-rt-b" {
  network_id = yandex_vpc_network.diploma-network.id
  name       = "${var.project_name}-private-rt-b"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance-b.network_interface.0.ip_address
  }
}

# NAT instance для выхода в интернет из приватных подсетей
resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" # NAT instance от Yandex
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true # Для экономии средств
  }
}

# Добавляем NAT instance в зоне B
resource "yandex_compute_instance" "nat-instance-b" {
  name        = "nat-instance-b"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"  # Добавляем в зону B

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1" # NAT instance
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet-b.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Обновляем таблицу маршрутизации для приватной подсети B
resource "yandex_vpc_route_table" "private-rt-b" {
  network_id = yandex_vpc_network.diploma-network.id
  name       = "${var.project_name}-private-rt-b"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance-b.network_interface.0.ip_address
  }
}

# Обновляем приватную подсеть B
resource "yandex_vpc_subnet" "private-subnet-b" {
  name           = "${var.project_name}-private-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diploma-network.id
  v4_cidr_blocks = ["192.168.40.0/24"]
  route_table_id = yandex_vpc_route_table.private-rt-b.id  # Обновляем на новую таблицу
}

