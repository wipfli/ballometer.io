#!/usr/bin/bash

ssh root@$HOST_IP "influxd backup -portable /root/influxdb"
rsync -va root@$HOST_IP:/root/influxdb/ backup-data/influxdb/
rsync -va root@$HOST_IP:/root/api-auth/users.json backup-data
