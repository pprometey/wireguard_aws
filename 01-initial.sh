#!/bin/bash

echo "# Installing Wireguard"

./20-remove.sh && \

./10-install.sh && \

./11-add-client.sh

echo "# Wireguard installed"
