# 🐘 Postgres Scaling Lab

### От репликации к шардированию

Практический проект по поэтапному масштабированию **PostgreSQL** в изолированной среде *Multipass*.
Демонстрирует эволюцию системы: от одиночного сервера → к распределенному кластеру с высокой доступностью (HA).

---

## 🏗 Архитектура проекта

Проект состоит из **4 этапов**, каждый из которых решает отдельную инженерную задачу:

---

### 🔹 Stage 1: Физическая репликация

**Задача:**
Обеспечить резервное копирование данных при сбое основного сервера.

**Стек:**

* PostgreSQL 16 (Streaming Replication)

**Результат:**

* Настроен `wal_level = replica`
* Использован `pg_basebackup -R`
* Реализована синхронная и асинхронная передача WAL

---

### 🔹 Stage 2: Отказоустойчивость (HA)

**Задача:**
Автоматическое переключение на реплику при падении мастера (*failover*).

**Стек:**

* Patroni
* etcd
* HAProxy

**Результат:**

* Кластер автоматически выбирает нового лидера
* Failover протестирован командой:

```bash
multipass stop pg-master
```

---

### 🔹 Stage 3: Логическая репликация

**Задача:**
Передача **выбранных таблиц**, а не всей базы (Pub/Sub модель).

**Стек:**

* PostgreSQL Logical Replication

**Результат:**

* Настроены:

  * `PUBLICATION` (источник)
  * `SUBSCRIPTION` (приемник)
* Реплика становится доступной для записи (в отличие от физической)

---

### 🔹 Stage 4: Горизонтальное масштабирование

**Задача:**
Распределить данные одной таблицы между серверами.

**Стек:**

* Citus 12.1

**Результат:**

* Таблица `orders` распределена по воркерам
* Реализован **Shard Pruning**
* Координатор знает, где искать конкретные данные

---

## 🛠 Технический стек

* **Virtualization:** Multipass (Ubuntu 24.04)
* **Database:** PostgreSQL 16
* **Scaling:** Citus Extension
* **HA:** Patroni + etcd

---

## 🔍 Основные команды для проверки

# Узнаем IP-адреса
```bash
MASTER_IP=$(multipass info pg-master | grep IPv4 | awk '{print $2}')
REPLICA_IP=$(multipass info pg-replica | grep IPv4 | awk '{print $2}')

echo "--------------------------------------"
echo "Master IP: $MASTER_IP"
echo "Replica IP: $REPLICA_IP"
echo "--------------------------------------"
```

### 📊 Проверка шардирования (Citus)

```sql
SELECT 
    shardid,
    nodename,
    shardminvalue,
    shardmaxvalue
FROM pg_dist_shard s
JOIN pg_dist_placement p ON s.shardid = p.shardid
JOIN pg_dist_node n ON p.groupid = n.groupid
WHERE s.logicalrelid = 'orders'::regclass;
```

---

### 📈 Проверка плана распределенного запроса

```sql
EXPLAIN (VERBOSE)
SELECT * FROM orders WHERE id = 42;
```

**Ожидаемый результат:**

```
Custom Scan (Citus Adaptive)
```

Это означает, что запрос отправлен на конкретный воркер.

---

### ⚙️ Проверка состояния HA-кластера

```bash
sudo patronictl -c /etc/patroni.yml list
```


