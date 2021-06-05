#!/usr/bin/bash

ssh root@$HOST_IP "influxd backup -portable -since $(date -d '2 days ago' +'%Y-%m-%dT%H:%M:%SZ') /root/influxdb"
rsync -va root@$HOST_IP:/root/influxdb/ backup-data/influxdb/
rsync -va root@$HOST_IP:/root/api-auth/users.json backup-data
