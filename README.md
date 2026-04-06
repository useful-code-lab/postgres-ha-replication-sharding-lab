Выполнить для установки серверов
```bash
 cd stage-1-streaming-replication
 bash setup_nodes.sh
 ```
Поменять на ``listen_addresses = '*'`` в `/etc/postgresql/16/main/postgresql.conf`

Создать пользователя для репликации
```bash
sudo -u postgres psql -c "CREATE ROLE replication WITH REPLICATION PASSWORD 'secret_pass' LOGIN;"
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
