# Security Group для Bastion
resource "yandex_vpc_security_group" "bastion-sg" {
  name       = "${var.project_name}-bastion-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"] # В продакшене замените на ваш IP
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для внутреннего SSH
resource "yandex_vpc_security_group" "internal-ssh-sg" {
  name       = "${var.project_name}-internal-ssh-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol          = "TCP"
    description       = "SSH from bastion"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion-sg.id
  }
}

# Security Group для веб-серверов
resource "yandex_vpc_security_group" "web-sg" {
  name       = "${var.project_name}-web-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol          = "TCP"
    description       = "HTTP from ALB"
    port              = 80
    security_group_id = yandex_vpc_security_group.alb-sg.id
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from internal"
    port              = 22
    security_group_id = yandex_vpc_security_group.internal-ssh-sg.id
  }

  ingress {
    protocol          = "TCP"
    description       = "Node Exporter"
    port              = 9100
    security_group_id = yandex_vpc_security_group.prometheus-sg.id
  }

  ingress {
    protocol          = "TCP"
    description       = "Nginx Log Exporter"
    port              = 4040
    security_group_id = yandex_vpc_security_group.prometheus-sg.id
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для ALB
resource "yandex_vpc_security_group" "alb-sg" {
  name       = "${var.project_name}-alb-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Prometheus
resource "yandex_vpc_security_group" "prometheus-sg" {
  name       = "${var.project_name}-prometheus-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol          = "TCP"
    description       = "Prometheus UI"
    port              = 9090
    security_group_id = yandex_vpc_security_group.grafana-sg.id
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from internal"
    port              = 22
    security_group_id = yandex_vpc_security_group.internal-ssh-sg.id
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Grafana
resource "yandex_vpc_security_group" "grafana-sg" {
  name       = "${var.project_name}-grafana-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol       = "TCP"
    description    = "Grafana UI"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from internal"
    port              = 22
    security_group_id = yandex_vpc_security_group.internal-ssh-sg.id
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Elasticsearch
resource "yandex_vpc_security_group" "elasticsearch-sg" {
  name       = "${var.project_name}-elasticsearch-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol          = "TCP"
    description       = "Elasticsearch API"
    port              = 9200
    security_group_id = yandex_vpc_security_group.kibana-sg.id
  }

  ingress {
    protocol          = "TCP"
    description       = "Filebeat from web servers"
    port              = 9200
    security_group_id = yandex_vpc_security_group.web-sg.id
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from internal"
    port              = 22
    security_group_id = yandex_vpc_security_group.internal-ssh-sg.id
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для Kibana
resource "yandex_vpc_security_group" "kibana-sg" {
  name       = "${var.project_name}-kibana-sg"
  network_id = yandex_vpc_network.mycourseproject-network.id

  ingress {
    protocol       = "TCP"
    description    = "Kibana UI"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "SSH from internal"
    port              = 22
    security_group_id = yandex_vpc_security_group.internal-ssh-sg.id
  }

  egress {
    protocol       = "ANY"
    description    = "Any outgoing"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
