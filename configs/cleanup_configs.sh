#!/bin/bash
# Очистка только паролей (IP остаются)

echo "🔐 Очищаем пароли и токены..."

# Создаем backup
timestamp=$(date +%Y%m%d_%H%M%S)
if [ -d "configs" ]; then
    cp -r configs "configs_backup_${timestamp}"
    echo "✅ Backup создан: configs_backup_${timestamp}/"
fi

# Функция для очистки паролей в файле
clean_passwords() {
    local file=$1
    
    if [ -f "$file" ]; then
        # Заменяем пароли и токены
        sed -i \
            -e 's/password:[[:space:]]*[^[:space:]]\+/password: <REDACTED>/gi' \
            -e 's/secret:[[:space:]]*[^[:space:]]\+/secret: <REDACTED>/gi' \
            -e 's/token:[[:space:]]*[^[:space:]]\+/token: <REDACTED>/gi' \
            -e 's/api_key:[[:space:]]*[^[:space:]]\+/api_key: <REDACTED>/gi' \
            -e 's/access_key:[[:space:]]*[^[:space:]]\+/access_key: <REDACTED>/gi' \
            -e 's/secret_key:[[:space:]]*[^[:space:]]\+/secret_key: <REDACTED>/gi' \
            -e 's/admin_password:[[:space:]]*[^[:space:]]\+/admin_password: <REDACTED>/gi' \
            "$file" 2>/dev/null
    fi
}

# Обрабатываем все конфиги
find configs/ -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.conf" -o -name "*.ini" -o -name "*.json" \) 2>/dev/null | while read file; do
    echo "Обрабатываю: $file"
    clean_passwords "$file"
done

echo ""
echo "✅ Очистка завершена!"
echo "IP-адреса сохранены, пароли заменены на <REDACTED>"
echo ""
echo "🔍 Проверка:"
grep -r -i "password\|secret\|token" configs/ 2>/dev/null | head -5 || echo "✅ Пароли не найдены"
