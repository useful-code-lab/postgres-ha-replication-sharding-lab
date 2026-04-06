## Устновка Patroni на master

Установка `etcd`
```bash
sudo snap install etcd
```

Установка Patroni
```bash
# Установите инструменты для venv
sudo apt install python3-venv python3-full

# Создайте окружение
python3 -m venv ~/patroni_venv

# Установите patroni с поддержкой etcd внутри окружения
~/patroni_venv/bin/pip install patroni[etcd]
```

Вот компактная, готовая версия для **README**, чтобы поднять etcd с v2 API для Patroni на одиночном узле:

## Настройка etcd для Patroni (v2 API)

1. **Очистка старых данных и остановка сервиса**:

```bash
sudo systemctl stop etcd
sudo rm -rf /var/lib/etcd
sudo mkdir -p /var/lib/etcd
sudo chown -R etcd:etcd /var/lib/etcd
````

2. **Создание override для systemd**:

```bash
sudo mkdir -p /etc/systemd/system/etcd.service.d
sudo nano /etc/systemd/system/etcd.service.d/override.conf
```

Вставьте:

```ini
[Service]
Environment=
ExecStart=
ExecStart=/usr/bin/etcd \
  --name=pg-master \
  --data-dir=/var/lib/etcd \
  --listen-client-urls=http://0.0.0.0:2379 \
  --advertise-client-urls=http://10.157.62.135:2379 \
  --listen-peer-urls=http://0.0.0.0:2380 \
  --initial-advertise-peer-urls=http://10.157.62.135:2380 \
  --initial-cluster=pg-master=http://10.157.62.135:2380 \
  --initial-cluster-state=new \
  --initial-cluster-token=etcd-cluster-1 \
  --enable-v2=true
```

3. **Очистка `/etc/default/etcd`**:

```bash
sudo mv /etc/default/etcd /etc/default/etcd.bak
```

4. **Перезагрузка systemd и запуск etcd**:

```bash
sudo systemctl daemon-reload
sudo systemctl start etcd
sudo systemctl status etcd
```

5. **Проверка API v2**:

```bash
curl http://10.157.62.135:2379/v2/machines
```

> Должно вернуть: `http://10.157.62.135:2379`
 
