#!/bin/bash

echo "================================="
echo "Webapp Initialization Script"
echo "================================="

for file in /code/cre-web/build/dist/*.noarch.rpm; do
  rpm -ivh "$file"
done;

WEBAPP_PROPERTIES=/etc/cre-web/application.properties
if [[ -f $WEBAPP_PROPERTIES ]]; then
    sed -i "/graph.url=/c\graph.url=bolt://${GRAPH_HOST}:7687" $WEBAPP_PROPERTIES
    sed -i "/graph.username=/c\graph.username=${GRAPH_USER}" $WEBAPP_PROPERTIES
    sed -i "/graph.password=/c\graph.password=${GRAPH_PASSWORD}" $WEBAPP_PROPERTIES
    sed -i "/zookeeper.connect=/c\zookeeper.connect=${ZOOKEEPER_CONNECT}" $WEBAPP_PROPERTIES
    sed -i "/server.ssl.enabled=true/c\server.ssl.enabled=false" $WEBAPP_PROPERTIES
    sed -i "/server.port=8443/c\server.port=9001" $WEBAPP_PROPERTIES
    sed -i "/redirect.port=443/c\redirect.port=9001" $WEBAPP_PROPERTIES 
    sed -i "/server.ssl.client-auth=need/c\server.ssl.client-auth=" $WEBAPP_PROPERTIES
    echo "Updated database properties in $WEBAPP_PROPERTIES"
fi

exec "$@"
