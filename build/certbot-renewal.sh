#!/bin/bash

sleep 30s

echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Renewing certificates every 12h."
while :
do
	sleep "12h"
	echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Renewing certificates..."

	if ! certbot -q renew --post-hook nginx -s reload ; then
		echo -e "$(date +'%Y-%m-%d %H:%M:%S') ERROR: Failed to renew certificates stopping nginx!"
		nginx -s stop
	fi
done

exit 0