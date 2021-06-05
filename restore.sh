#!/usr/bin/bash

rsync -va backup-data/users.json root@$HOST_IP:/root/api-auth/users.json
rsync -va backup-data/influxdb/ root@$HOST_IP:/root/influxdb/

ssh root@$HOST_IP "systemctl restart api-auth"
ssh root@$HOST_IP "influx -execute 'DROP DATABASE ballometer'"
ssh root@$HOST_IP "influx -execute 'DROP DATABASE weather'"
ssh root@$HOST_IP "influxd restore -portable /root/influxdb"
