# Bastion host
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet-a.id
    nat       = true
    security_group_ids = [
      yandex_vpc_security_group.bastion-sg.id,
      yandex_vpc_security_group.internal-ssh-sg.id
    ]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Web Server 1
resource "yandex_compute_instance" "web1" {
  name        = "web1"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Web Server 2
resource "yandex_compute_instance" "web2" {
  name        = "web2"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-b.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.web-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Prometheus VM
resource "yandex_compute_instance" "prometheus" {
  name        = "prometheus"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04
      size     = 30
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.prometheus-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Grafana VM
resource "yandex_compute_instance" "grafana" {
  name        = "grafana"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet-a.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.grafana-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Elasticsearch VM
resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet-a.id
    nat       = false
    security_group_ids = [yandex_vpc_security_group.elasticsearch-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}

# Kibana VM
resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 20.04
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet-a.id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.kibana-sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = true
  }
}
