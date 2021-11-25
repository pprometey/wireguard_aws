#!/bin/bash
if [ $# -eq 0 ]
then
	echo "must have peer id as arg: remove-peer.sh asdf123="
else
	sudo wg set wg0 peer $1 remove
	sudo wg show
fi