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

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
}

variable "grafana_password" {
  type      = string
  default   = "admin"
  sensitive = true
}

variable "project_name" {
  type    = string
  default = "mycourseproject"
}
