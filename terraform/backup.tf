# Snapshot schedule для всех ВМ
resource "yandex_compute_snapshot_schedule" "daily-backup" {
  name = "${var.project_name}-daily-backup"

  schedule_policy {
    expression = "0 1 * * *" # Ежедневно в 01:00
  }

  snapshot_count = 7 # Хранить 7 дней

  snapshot_spec {
    description = "Daily backup"
  }

  disk_ids = [
    yandex_compute_instance.bastion.boot_disk.0.disk_id,
    yandex_compute_instance.web1.boot_disk.0.disk_id,
    yandex_compute_instance.web2.boot_disk.0.disk_id,
    yandex_compute_instance.prometheus.boot_disk.0.disk_id,
    yandex_compute_instance.grafana.boot_disk.0.disk_id,
    yandex_compute_instance.elasticsearch.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id,
    yandex_compute_instance.nat-instance.boot_disk.0.disk_id,      # Добавляем
    yandex_compute_instance.nat-instance-b.boot_disk.0.disk_id,    # Добавляем  
  ]
}
