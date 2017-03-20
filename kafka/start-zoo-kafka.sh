#!/bin/bash

set -e
set -o pipefail

service zookeeper start
sleep 15
service kafka start

#sleep 1
cd /var/log/kafka
tail -F zookeeper.out zookeeper.log kafka.out kafka.log
