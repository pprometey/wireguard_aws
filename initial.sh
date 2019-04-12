l#!/bin/bash

echo "# Installing Wireguard"

chmod +x remove.sh
./remove.sh

chmod +x install.sh
./install.sh

chmod +x add-client.sh 
./add-client.sh

echo "# Wireguard installed"
