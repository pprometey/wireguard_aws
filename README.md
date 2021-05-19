# Скрипт установки Wireguard 
Скрипт автоматической установки и настройки Wireguard на сервере с Ubuntu Server 18.04 и новее.

## Как пользоваться

### Установка
```
git clone https://github.com/blackden/wireguard_vds.git wireguard_vds
cd wireguard_vds
sudo ./01-initial.sh
```

Скрипт `01-initial.sh` удаляет предыдущую установку Wireguard (если такая была), используя скрипт `20-remove.sh`. Затем он устанавливает и настраивает Wireguard, используя скрипт `10-install.sh`. А затем создает клиента, используя скрипт `11-add-client.sh`.

### Добавить нового VPN клиента
`11-add-client.sh` - скрипт добавляет нового VPN клиента. В результате выполнения, он создаст конфигурационный файл клиента ($CLIENT_NAME.conf) по пути ./clients/$CLIENT_NAME/ и выведет на экран QR-код с конфигурацией.

```
sudo ./11-add-client.sh
# или
sudo ./11-add-client.sh $CLIENT_NAME
```

### Сбросить настройки и записи о пользователях. Пересоздать сервер
`19-reset.sh` - Скрипт удаляет информацию о клиентах и останавливает VPN сервер Winguard.
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
