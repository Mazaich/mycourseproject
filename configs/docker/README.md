# Docker развертывание сервисов

## Сервисы, развернутые в Docker:

### 1. Elasticsearch
- **Хост:** 192.168.30.11
- **Статус:** Развернут в Docker
- **Порт:** 9200
- **Конфиг:** Внутри контейнера по пути `/usr/share/elasticsearch/config/elasticsearch.yml`
- **Команда для просмотра конфига:**
  ```bash
  docker exec elasticsearch cat /usr/share/elasticsearch/config/elasticsearch.yml
