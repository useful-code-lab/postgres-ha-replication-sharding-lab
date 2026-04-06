#!/bin/bash

# 1. Создаем узлы (Master и Replica)
echo "🚀 Запуск узлов в Multipass..."
multipass launch --name pg-master --memory 2G --cpus 2
multipass launch --name pg-replica --memory 2G --cpus 2

# 2. Установка PostgreSQL 16 на оба узла
# Используем bash -c "...", чтобы весь блок команд выполнился ВНУТРИ Multipass
echo "🐘 Установка PostgreSQL 16..."

for node in pg-master pg-replica; do
    echo "--- Настройка $node ---"
    multipass exec $node -- bash -c "
        sudo apt update && \
        sudo apt install -y curl ca-certificates gnupg && \
        sudo install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://postgresql.org | sudo gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg && \
        echo \"deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://postgresql.org \$(lsb_release -cs)-pgdg main\" | sudo tee /etc/apt/sources.list.d/pgdg.list && \
        sudo apt update && \
        sudo apt install -y postgresql-16 postgresql-contrib-16
    "
done

# 3. Узнаем IP-адреса
MASTER_IP=$(multipass info pg-master | grep IPv4 | awk '{print $2}')
REPLICA_IP=$(multipass info pg-replica | grep IPv4 | awk '{print $2}')

echo "--------------------------------------"
echo "✅ Установка завершена!"
echo "Master IP: $MASTER_IP"
echo "Replica IP: $REPLICA_IP"
echo "--------------------------------------"
