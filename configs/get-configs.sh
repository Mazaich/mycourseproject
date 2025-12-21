#!/bin/bash
# ==============================================
# Скрипт для сбора конфигов (включая Docker)
# ==============================================

# Цвета
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============ НАСТРОЙКИ ============
BASTION_USER="ubuntu"
BASTION_IP="158.160.97.89"
SSH_KEY="~/.ssh/id_rsa_diploma"

# IP-адреса серверов
declare -A SERVERS=(
    ["web1"]="192.168.30.23"
    ["web2"]="192.168.40.11"
    ["prometheus"]="192.168.30.3"
    ["elasticsearch"]="192.168.30.11"
    ["kibana"]="192.168.20.29"
    ["grafana"]="192.168.20.34"
)

# ====================================

echo -e "${GREEN}🚀 Начинаем сбор конфигов инфраструктуры${NC}"
echo "========================================"

SSH_KEY_PATH="${SSH_KEY/\~/$HOME}"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo -e "${RED}❌ SSH ключ не найден${NC}"
    exit 1
fi

chmod 600 "$SSH_KEY_PATH" 2>/dev/null

# Создаем структуру папок
echo "📁 Создаю структуру папок..."
mkdir -p configs/{nginx,prometheus,filebeat,elasticsearch,kibana,grafana,docker,logs,notes} 2>/dev/null

# Функция для SSH
ssh_cmd() {
    local server_ip=$1
    local command=$2
    
    ssh -i "$SSH_KEY_PATH" \
        -o ConnectTimeout=10 \
        -o StrictHostKeyChecking=no \
        -o ProxyCommand="ssh -i $SSH_KEY_PATH -W %h:%p ubuntu@$BASTION_IP" \
        "ubuntu@$server_ip" "$command"
}

# Функция для копирования
copy_file() {
    local server_name=$1
    local server_ip=$2
    local remote_path=$3
    local local_path=$4
    
    echo -n "📋 $server_name: $remote_path ... "
    
    mkdir -p "$(dirname "$local_path")"
    
    ssh_cmd "$server_ip" "sudo cat '$remote_path' 2>/dev/null" > "$local_path" 2>&1
    
    if [ -s "$local_path" ] && ! grep -q "No such file" "$local_path"; then
        lines=$(wc -l < "$local_path" 2>/dev/null || echo 0)
        echo -e "${GREEN}✅ ($lines строк)${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  не найден${NC}"
        rm -f "$local_path"
        return 1
    fi
}

# Функция для Docker
get_docker_config() {
    local server_name=$1
    local server_ip=$2
    local container_name=$3
    local remote_path=$4
    local local_path=$5
    
    echo -n "🐳 $server_name (docker $container_name): $remote_path ... "
    
    mkdir -p "$(dirname "$local_path")"
    
    # Пробуем получить конфиг из контейнера
    ssh_cmd "$server_ip" "docker exec $container_name cat '$remote_path' 2>/dev/null" > "$local_path" 2>&1
    
    if [ -s "$local_path" ]; then
        lines=$(wc -l < "$local_path" 2>/dev/null || echo 0)
        echo -e "${GREEN}✅ ($lines строк)${NC}"
        return 0
    else
        echo -e "${RED}❌ не удалось${NC}"
        # Пробуем найти контейнер
        echo -n "  🔍 Ищу контейнер $container_name ... "
        ssh_cmd "$server_ip" "docker ps --filter 'name=$container_name' --format '{{.Names}}'" > /tmp/container_found.txt 2>&1
        if [ -s /tmp/container_found.txt ]; then
            echo -e "${YELLOW}найдены: $(cat /tmp/container_found.txt)${NC}"
        else
            echo -e "${YELLOW}контейнер не найден${NC}"
        fi
        rm -f "$local_path"
        return 1
    fi
}

# Проверяем bastion
echo -n "🔍 Тестируем bastion ... "
if ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=5 ubuntu@$BASTION_IP "echo OK" &>/dev/null; then
    echo -e "${GREEN}✅${NC}"
else
    echo -e "${RED}❌${NC}"
    exit 1
fi

echo ""
echo "💾 Собираем конфиги..."

# 1. Веб-сервера
for i in 1 2; do
    server_name="web$i"
    server_ip="${SERVERS[$server_name]}"
    
    echo ""
    echo "🌐 $server_name ($server_ip)"
    
    # Nginx
    copy_file "$server_name" "$server_ip" "/etc/nginx/nginx.conf" "configs/nginx/${server_name}/nginx.conf"
    copy_file "$server_name" "$server_ip" "/etc/nginx/sites-enabled/default" "configs/nginx/${server_name}/default.conf"
    
    # Filebeat (в Docker на хосте /etc/filebeat.yml может быть volume)
    copy_file "$server_name" "$server_ip" "/etc/filebeat.yml" "configs/filebeat/${server_name}/filebeat.yml"
    
    # Проверяем Docker контейнеры
    echo -n "🔍 Проверяем Docker контейнеры ... "
    ssh_cmd "$server_ip" "docker ps --format '{{.Names}}'" > "configs/docker/${server_name}_containers.txt" 2>&1
    if [ -s "configs/docker/${server_name}_containers.txt" ]; then
        echo -e "${GREEN}✅ найдены${NC}"
        cat "configs/docker/${server_name}_containers.txt"
    else
        echo -e "${YELLOW}нет контейнеров${NC}"
    fi
done

# 2. Elasticsearch (Docker)
server_ip="${SERVERS[elasticsearch]}"
if [ -n "$server_ip" ]; then
    echo ""
    echo "📈 Elasticsearch ($server_ip) - в Docker"
    
    # Пробуем разные имена контейнеров
    get_docker_config "elasticsearch" "$server_ip" "elasticsearch" "/usr/share/elasticsearch/config/elasticsearch.yml" "configs/elasticsearch/elasticsearch.yml"
    
    # Если не получилось, ищем контейнер
    echo -n "🔍 Ищу контейнеры Elasticsearch ... "
    ssh_cmd "$server_ip" "docker ps --format '{{.Names}}' | grep -i elastic" > "configs/docker/elasticsearch_containers.txt" 2>&1
    cat "configs/docker/elasticsearch_containers.txt"
fi

# 3. Kibana (Docker)
server_ip="${SERVERS[kibana]}"
if [ -n "$server_ip" ]; then
    echo ""
    echo "🔍 Kibana ($server_ip) - в Docker"
    
    get_docker_config "kibana" "$server_ip" "kibana" "/usr/share/kibana/config/kibana.yml" "configs/kibana/kibana.yml"
    
    echo -n "🔍 Ищу контейнеры Kibana ... "
    ssh_cmd "$server_ip" "docker ps --format '{{.Names}}' | grep -i kibana" > "configs/docker/kibana_containers.txt" 2>&1
    cat "configs/docker/kibana_containers.txt"
fi

# 4. Filebeat на web серверах может быть в Docker
echo ""
echo "🔍 Проверяем Filebeat в Docker на web серверах..."
for i in 1 2; do
    server_name="web$i"
    server_ip="${SERVERS[$server_name]}"
    
    echo -n "  $server_name: "
    ssh_cmd "$server_ip" "docker ps --format '{{.Names}}' | grep -i filebeat" > "configs/docker/${server_name}_filebeat.txt" 2>&1
    if [ -s "configs/docker/${server_name}_filebeat.txt" ]; then
        echo -e "${GREEN}Filebeat в Docker: $(cat configs/docker/${server_name}_filebeat.txt)${NC}"
        # Пробуем получить конфиг из контейнера
        container_name=$(cat "configs/docker/${server_name}_filebeat.txt" | head -1)
        get_docker_config "$server_name" "$server_ip" "$container_name" "/usr/share/filebeat/filebeat.yml" "configs/filebeat/${server_name}/filebeat_docker.yml"
    else
        echo -e "${YELLOW}Filebeat не в Docker (возможно на хосте)${NC}"
    fi
done

# 5. Создаем файлы с информацией о Docker
echo ""
echo "📝 Создаю документацию о Docker развертывании..."

# Файл с информацией о Docker
cat > configs/docker/README.md << 'EOF'
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
