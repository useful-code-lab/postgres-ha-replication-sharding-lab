## Настройка master-реплика
```bash
multipass shell pg-master
```

Выполнить для установки серверов
```bash
 cd stage-1-streaming-replication
 bash setup_nodes.sh
 ```
Поменять на ``listen_addresses = '*'`` в `/etc/postgresql/16/main/postgresql.conf`

Создать пользователя для репликации
```bash
sudo -u postgres psql -c "CREATE ROLE replication WITH REPLICATION PASSWORD 'mysecret' LOGIN;"
```
В файле `/etc/postgresql/16/main/pg_hba.conf` добавить в конец 
```
host    replication     replication     0.0.0.0/0               md5
```
Перезапуск сервера
```bash
sudo systemctl restart postgresql
```
Проверка
```bash
ss -nlt | grep 5432
```

Должно быть так
```bash
LISTEN 0      200          0.0.0.0:5432      0.0.0.0:*          
LISTEN 0      200             [::]:5432         [::]:*  
```

## Настройка Replica-узла
```bash
multipass shell pg-replica
sudo systemctl stop postgresql
```
Очистить стандартные данные
```bash
sudo rm -rf /var/lib/postgresql/16/main
```
Скопировать БД из master 
```bash
sudo -u postgres pg_basebackup -h 10.157.62.135 -D /var/lib/postgresql/16/main/ -U replication -P -R
``` 

## Проверка репликации
На мастере:
```bash
sudo -u postgres psql -c "CREATE TABLE replication_test (id serial PRIMARY KEY, message text, created_at timestamp DEFAULT now());"
sudo -u postgres psql -c "INSERT INTO replication_test (message) VALUES ('Привет от Мастера'), ('Репликация работает');"
```

На реплике:
```bash
sudo -u postgres psql -c "SELECT * FROM replication_test;"
```

Проверка защиты от записи на реплике
```bash
sudo -u postgres psql -c "INSERT INTO replication_test (message) VALUES ('Попытка записи на реплику');"
```
