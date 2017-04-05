#!/bin/bash

echo "================================="
echo "Webapp Initialization Script"
echo "================================="

for file in /code/cre-web/build/dist/*.noarch.rpm; do
  rpm -ivh "$file"
done;

# for docker
SERVICE_FILE=/etc/init.d/volume-streams
if [[ -f $SERVICE_FILE ]]; then
  sed -i "/serviceUser=/c\serviceUser=\"root\"" $SERVICE_FILE
  sed -i "/serviceGroup=/c\serviceGroup=\"root\"" $SERVICE_FILE
fi

WEBAPP_PROPERTIES=/etc/cre-web/application.properties
if [[ -f $WEBAPP_PROPERTIES ]]; then
    sed -i "/logging.level.org.springframework.security=/c\logging.level.org.springframework.security=DEBUG" $WEBAPP_PROPERTIES
    sed -i "/graph.url=/c\graph.url=bolt://${GRAPH_HOST}:7687" $WEBAPP_PROPERTIES
    sed -i "/graph.username=/c\graph.username=${GRAPH_USER}" $WEBAPP_PROPERTIES
    sed -i "/graph.password=/c\graph.password=${GRAPH_PASSWORD}" $WEBAPP_PROPERTIES
    sed -i "/server.ssl.enabled=/c\server.ssl.enabled=true" $WEBAPP_PROPERTIES
    sed -i "/server.port=/c\server.port=9001" $WEBAPP_PROPERTIES
    sed -i "/http.port=/c\http.port=8080" $WEBAPP_PROPERTIES
    sed -i "/redirect.port=/c\redirect.port=9001" $WEBAPP_PROPERTIES 
    sed -i "/server.ssl.client-auth=/c\server.ssl.client-auth=need" $WEBAPP_PROPERTIES
    sed -i "/server.ssl.key-store-password=/c\server.ssl.key-store-password=changeit" $WEBAPP_PROPERTIES
    sed -i "/server.ssl.key-alias=/c\server.ssl.key-alias=test.volumeintegration.com" $WEBAPP_PROPERTIES
    sed -i "/server.ssl.key-password=/c\server.ssl.key-password=changeit" $WEBAPP_PROPERTIES
    sed -i "/server.ssl.trust-store-password=/c\server.ssl.trust-store-password=changeit" $WEBAPP_PROPERTIES
    sed -i "/security.oauth2.client.clientId=/c\security.oauth2.client.clientId=cre" $WEBAPP_PROPERTIES
    sed -i "/security.oauth2.client.clientSecret=/c\security.oauth2.client.clientSecret=crepassword" $WEBAPP_PROPERTIES
    sed -i "/security.oauth2.client.accessTokenUri=/c\security.oauth2.client.accessTokenUri=${GATEWAY_ELB}/oauth/token" $WEBAPP_PROPERTIES
    sed -i "/security.oauth2.client.userAuthorizationUri=/c\security.oauth2.client.userAuthorizationUri=${GATEWAY_ELB_EXTERNAL}/oauth/authorize" $WEBAPP_PROPERTIES
    sed -i "/security.oauth2.resource.userInfoUri=/c\security.oauth2.resource.userInfoUri=${GATEWAY_ELB}/permissions" $WEBAPP_PROPERTIES
    echo "server.session.cookie.name=CRESESSIONID" >> $WEBAPP_PROPERTIES
    echo "Updated database properties in $WEBAPP_PROPERTIES"
fi


KEYSTORE_FILE=/settings/keystore.jks
if [[ -f $KEYSTORE_FILE ]]; then
  sed -i "/server.ssl.key-store=/c\server.ssl.key-store=$KEYSTORE_FILE" $WEBAPP_PROPERTIES
fi

TRUSTSTORE_FILE=/settings/truststore.jks
if [[ -f $TRUSTSTORE_FILE ]]; then
  sed -i "/server.ssl.trust-store=/c\server.ssl.trust-store=$TRUSTSTORE_FILE" $WEBAPP_PROPERTIES
fi

SYSTEM_PROPS=/settings/system.properties
CORRECT_SYS_PROPS=/etc/cre-webapp/system.properties
if [[ -f $SYSTEM_PROPS ]]; then
  cp $SYSTEM_PROPS $CORRECT_SYS_PROPS
  sed -i "/javax.net.ssl.keyStore=/c\javax.net.ssl.keyStore=$KEYSTORE_FILE" $CORRECT_SYS_PROPS
  sed -i "/javax.net.ssl.trustStore=/c\javax.net.ssl.trustStore=$TRUSTSTORE_FILE" $CORRECT_SYS_PROPS
fi

exec "$@"
