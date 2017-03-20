#!/bin/bash

echo "============================="
echo "Manager Initialization Script"
echo "============================="

if [[ -f /etc/vamonitor/application.properties ]]; then
    sed -i "/graph.url=/c\graph.url=bolt://${GRAPH_HOST}:7687" /etc/vamonitor/application.properties
    sed -i "/graph.username=/c\graph.username=${GRAPH_USER}" /etc/vamonitor/application.properties
    sed -i "/graph.password=/c\graph.password=${GRAPH_PASSWORD}" /etc/vamonitor/application.properties
    sed -i "/zookeeper.connect=/c\zookeeper.connect=${ZOOKEEPER_CONNECT}" /etc/vamonitor/application.properties
    echo "Updated database properties in /etc/vamonitor/application.properties"
fi

exec "$@"
