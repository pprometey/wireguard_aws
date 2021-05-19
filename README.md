# Скрипт установки Wireguard 
Скрипт автоматической установки и настройки Wireguard на сервере с Ubuntu Server 18.04 и новее.

## Как пользоваться

### Установка
```
git clone https://github.com/blackden/wireguard_vds.git wireguard_vds
cd wireguard_vds
sudo ./01-initial.sh
```

The `01-initial.sh` script removes the previous Wireguard installation (если такая была), тспользуя скрипт `20-remove.sh`. It then installs and configures the Wireguard service using the `10-install.sh` script. And then creates a client using the `11-add-client.sh` script.

### Добавить нового клиента
`11-add-client.sh` - Script to add a new VPN client. As a result of the execution, it creates a configuration file ($CLIENT_NAME.conf) on the path ./clients/$CLIENT_NAME/, displays a QR code with the configuration.

```
sudo ./add-client.sh
# или
sudo ./add-client.sh $CLIENT_NAME
```

### Сбросить настройки и записи о пользователях. Пересоздать сервер
`19-reset.sh` - script that removes information about clients. And stopping the VPN server Winguard
```
sudo ./19-reset.sh
```

### Удалить Wireguard
```
sudo ./20-remove.sh
```
## Авторы
- Fedorov Tech
- Denis Fedorov

## Форк основан на 
https://github.com/pprometey/wireguard_aws
