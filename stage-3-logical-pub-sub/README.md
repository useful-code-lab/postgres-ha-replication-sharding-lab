Проверка включена ли логическая репликация
```bash
sudo -u postgres psql -c "SHOW wal_level;"
```
Уроверь логической репликации лучше поменять этой командой
```bash
sudo -u postgres ETCDCTL_API=3 patronictl -c /etc/patroni.yml edit-config
```
Дополнить
```bash
+postgresql:
+  parameters:
+    wal_level: logical
+    max_replication_slots: 10
+    max_wal_senders: 10
```
Потом перезагрузить
```bash
 ETCDCTL_API=3 /usr/bin/patroni /etc/patroni.yml
```

