#!/bin/bash

detect_wan () {
	ip -c route | grep "default" | awk '{print $5}'
}
echo $(detect_wan)
read -p "Enter the name of the WAN network interface ([ENTER] set to default: $(detect_wan)): " \
	WAN_INTERFACE_NAME
if [ -z $WAN_INTERFACE_NAME ]
then WAN_INTERFACE_NAME=$(detect_wan)
fi
echo $WAN_INTERFACE_NAME
