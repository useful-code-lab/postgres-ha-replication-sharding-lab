## На всех этапах может понадобиться
```bash
#Узнаем IP-адреса
MASTER_IP=$(multipass info pg-master | grep IPv4 | awk '{print $2}')
REPLICA_IP=$(multipass info pg-replica | grep IPv4 | awk '{print $2}')

echo "--------------------------------------"
echo "✅ Установка завершена!"
echo "Master IP: $MASTER_IP"
echo "Replica IP: $REPLICA_IP"
echo "--------------------------------------"
```