#!/bin/bash
echo "============================="
echo "Gateway Initialization Script"
echo "============================="

for file in /va/volume-gateway/build/dist/*.noarch.rpm; do
  rpm -ivh "$file"
done;

# for docker
SERVICE_FILE=/etc/init.d/volume-gateway
if [[ -f $SERVICE_FILE ]]; then
  sed -i "/serviceUser=/c\serviceUser=\"root\"" $SERVICE_FILE
  sed -i "/serviceGroup=/c\serviceGroup=\"root\"" $SERVICE_FILE
fi

CONF_FILE=/etc/volume-gateway/application.properties
if [[ -f $CONF_FILE ]]; then
  sed -i "/redirect.port=/c\redirect.port=9443" $CONF_FILE
  sed -i "/kafka.servers=/c\kafka.servers=${KAFKA_CONNECT}" $CONF_FILE
  sed -i "/zookeeper.servers=/c\zookeeper.servers=${ZOOKEEPER_CONNECT}" $CONF_FILE
  sed -i "/graph.url=/c\graph.url=bolt://${GRAPH_HOST}:7687" $CONF_FILE
  sed -i "/graph.username=/c\graph.username=${GRAPH_USER}" $CONF_FILE
  sed -i "/graph.password=/c\graph.password=${GRAPH_PASSWORD}" $CONF_FILE
  sed -i "/security.oauth2.client.clientSecret=/c\security.oauth2.client.clientSecret=${GATEWAY_OAUTH_PASSWORD}" $CONF_FILE
  sed -i "/security.oauth2.client.accessTokenUri=/c\security.oauth2.client.accessTokenUri=${GATEWAY_ELB}/oauth/token" $CONF_FILE
  sed -i "/security.oauth2.client.userAuthorizationUri=/c\security.oauth2.client.userAuthorizationUri=${GATEWAY_ELB}/oauth/authorize" $CONF_FILE
  sed -i "/security.oauth2.resource.userInfoUri=/c\security.oauth2.resource.userInfoUri=${GATEWAY_ELB}/permissions" $CONF_FILEj
  sed -i "/spring.datasource.url=/c\spring.datasource.url=${MYSQL_URL}" $CONF_FILE
  sed -i "/spring.datasource.password=/c\spring.datasource.password=${GATEWAY_PASSWORD}" $CONF_FILE
  echo "Updated database properties in $CONF_FILE"
fi

if [[ -f /settings/https.properties ]]; then
  echo "" >> $CONF_FILE
  cat /settings/https.properties >> $CONF_FILE
fi

KEYSTORE_FILE=/settings/keystore.jks
if [[ -f $KEYSTORE_FILE ]]; then
  sed -i "/server.ssl.key-store=/c\server.ssl.key-store=$KEYSTORE_FILE" $CONF_FILE
fi

TRUSTSTORE_FILE=/settings/truststore.jks
if [[ -f $TRUSTSTORE_FILE ]]; then
  sed -i "/server.ssl.trust-store=/c\server.ssl.trust-store=$TRUSTSTORE_FILE" $CONF_FILE
fi

SYSTEM_PROPS=/settings/system.properties
CORRECT_SYS_PROPS=/etc/volume-gateway/system.properties
if [[ -f $SYSTEM_PROPS ]]; then
  cp $SYSTEM_PROPS $CORRECT_SYS_PROPS
  sed -i "/javax.net.ssl.keyStore=/c\javax.net.ssl.keyStore=$KEYSTORE_FILE" $CORRECT_SYS_PROPS
  sed -i "/javax.net.ssl.trustStore=/c\javax.net.ssl.trustStore=$TRUSTSTORE_FILE" $CORRECT_SYS_PROPS
fi

exec "$@"
