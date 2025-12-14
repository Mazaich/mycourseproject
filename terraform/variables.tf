variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
  sensitive   = true
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
  sensitive   = true
}

variable "yc_zone" {
  type    = string
  default = "ru-central1-a"
}

# SSH ключ для доступа к ВМ
variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
}

# Пароль для Grafana (можно сгенерировать)
variable "grafana_password" {
  type      = string
  default   = "admin123"
  sensitive = true
}

# Имена сервисов
variable "project_name" {
  type    = string
  default = "mycourseproject"
}
