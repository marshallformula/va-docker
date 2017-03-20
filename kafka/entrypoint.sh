#!/bin/bash

set -e
set -o pipefail

echo "==============="
echo "SETUP ZOOKEEPER/KAFKA"
echo "==============="

ZOO_PROPS=/etc/kafka/zookeeper.properties

# write zookeper servers
echo "Writing $ZOO_SERVERS to $ZOO_PROPS"
for server in $ZOO_SERVERS; do
  echo "$server" >> "$ZOO_PROPS"
done

# write myid
echo "${ZOO_MY_ID:-1}" > /var/lib/zookeeper/myid 
chown kafka:kafka /var/lib/zookeeper/myid


sed -i "/broker.id=/c\broker.id=${ZOO_MY_ID:-1}" /etc/kafka/kafka.properties
echo "num.partitions=10" >> /etc/kafka/kafka.properties
echo "default.replication.factor=3" >> /etc/kafka/kafka.properties
echo "min.insync.replicas=2" >> /etc/kafka/kafka.properties

# /sbin/service kafka stop
# /sbin/service zookeper stop

echo "ZOOKEEPER/KAFKA INIT COMPLETE"

exec "$@"
