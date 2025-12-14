# Target Group
resource "yandex_alb_target_group" "web-targets" {
  name = "${var.project_name}-web-targets"

  target {
    subnet_id  = yandex_vpc_subnet.private-subnet-a.id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private-subnet-b.id
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

# Backend Group
resource "yandex_alb_backend_group" "web-backend" {
  name = "${var.project_name}-web-backend"

  http_backend {
    name             = "web-backend"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.web-targets.id]

    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthcheck_port = 80
      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP Router
resource "yandex_alb_http_router" "web-router" {
  name = "${var.project_name}-web-router"
}

# Virtual Host
resource "yandex_alb_virtual_host" "web-host" {
  name           = "${var.project_name}-web-host"
  http_router_id = yandex_alb_http_router.web-router.id

  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web-backend.id
        timeout          = "60s"
      }
    }
  }
}

# Application Load Balancer
# Обновляем ALB для работы в двух зонах
resource "yandex_alb_load_balancer" "web-alb" {
  name       = "${var.project_name}-web-alb"
  network_id = yandex_vpc_network.mycourseproject-network.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-subnet-a.id
    }
    location {
      zone_id   = "ru-central1-b" # Добавляем вторую зону
      subnet_id = yandex_vpc_subnet.public-subnet-b.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web-router.id
      }
    }
  }
}
