Создать ещё один узел
```bash
# В терминале вашего основного компьютера
multipass launch --name pg-worker --memory 2G --cpus 2
```

Установка citus
```bash
sudo apt install -y postgresql-16 postgresql-server-dev-16

curl https://install.citusdata.com/community/deb.sh > add-citus-repo.sh
sudo bash add-citus-repo.sh

sudo apt install -y postgresql-16-citus-13.2
```

Мастер делаем координатором. Предварительно я его сделал PATRONI-лидером
```bash
sudo pg_conftool 16 main set shared_preload_libraries citus
sudo systemctl restart postgresql
sudo -u postgres psql -c "CREATE EXTENSION citus; SELECT citus_version();"

sudo -u postgres psql -c "SELECT citus_set_coordinator_host('IP_MASTER', 5432);"
```

## Добавить worker
```bash
 sudo -u postgres psql -c "SELECT * FROM citus_add_node('10.157.62.64', 5432);"
 ```