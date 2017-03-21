#!/bin/bash
echo "========================="
echo "Installing volume-streams"
echo "========================="

for file in /va/volume-streams/build/dist/*.noarch.rpm; do
  rpm -ivh "$file"
done;

for file in /code/cre-amp/build/dist/*.noarch.rpm; do
  rpm -ivh "$file"
done;

for file in /code/cre-rules-engine/build/dist/*.noarch.rpm; do
  rpm -ivh "$file"
done;

for file in /code/hook-tasks/build/dist/*.noarch.rpm; do
  rpm -ivh "$file"
done;

# for docker
SERVICE_FILE=/etc/init.d/volume-streams
if [[ -f $SERVICE_FILE ]]; then
  sed -i "/serviceUser=\"va\"/c\serviceUser=\"root\"" $SERVICE_FILE
  sed -i "/serviceGroup=\"va\"/c\serviceGroup=\"root\"" $SERVICE_FILE
fi

STREAMS_PROPERTIES=/etc/volume-streams/application.properties
if [[ -f $STREAMS_PROPERTIES ]]; then
    sed -i "/kafka.servers=/c\kafka.servers=${KAFKA_CONNECT}" $STREAMS_PROPERTIES
    sed -i "/zookeeper.servers=/c\zookeeper.servers=${ZOOKEEPER_CONNECT}" $STREAMS_PROPERTIES
    sed -i "/graph.url=/c\graph.url=bolt://${GRAPH_HOST}:7687" $STREAMS_PROPERTIES
    sed -i "/graph.username=/c\graph.username=${GRAPH_USER}" $STREAMS_PROPERTIES
    sed -i "/graph.password=/c\graph.password=${GRAPH_PASSWORD}" $STREAMS_PROPERTIES
    echo "Updated $STREAMS_PROPERTIES"
fi


FLOW_PROPERTIES_FILES=/var/lib/volume-streams/flows/*.properties
for f in $FLOW_PROPERTIES_FILES
do
    sed -i "/kafka.servers=/c\kafka.servers=${KAFKA_CONNECT}" $f
    sed -i "/zookeeper.servers=/c\zookeeper.servers=${ZOOKEEPER_CONNECT}" $f
    sed -i "/graph.url=/c\graph.url=bolt://${GRAPH_HOST}:7687" $f
    sed -i "/graph.username=/c\graph.username=${GRAPH_USER}" $f
    sed -i "/graph.password=/c\graph.password=${GRAPH_PASSWORD}" $f

    sed -i "/alert.sns.topic.compliance=/c\alert.sns.topic.compliance=what" $f
    sed -i "/alert.sns.topic.operational=/c\alert.sns.topic.operational=ever" $f
    sed -i "/alert.base.url=/c\alert.base.url=blergh" $f

    sed -i "/hook.task.discover.accounts.interval.ms=/c\hook.task.discover.accounts.interval.ms=60000" $f
    sed -i "/hook.task.discover.accounts.portal.url=/c\hook.task.discover.accounts.portal.url=file:///access.json" $f
    sed -i "/hook.task.discover.accounts.access.list.property=/c\hook.task.discover.accounts.access.list.property=c2sAccessList" $f
    sed -i "/hook.task.discover.accounts.account.name.property=/c\hook.task.discover.accounts.account.name.property=mission" $f
    sed -i "/hook.task.discover.accounts.default.role=/c\hook.task.discover.accounts.default.role=TECHREADONLY" $f
    sed -i "/hook.task.discover.accounts.networks=/c\hook.task.discover.accounts.networks=A:NETA,J:NETJ,M:NETM" $f
    sed -i "/hook.task.discover.accounts.overlays=/c\hook.task.discover.accounts.overlays=INT-A,INT-B,INT-C" $f
    sed -i "/hook.task.poll.accounts.for.describes.interval.ms=/c\hook.task.poll.accounts.for.describes.interval.ms=300500" $f
    sed -i "/hook.task.poll.accounts.for.events.interval.ms=/c\hook.task.poll.accounts.for.events.interval.ms=300000" $f
    sed -i "/rules.execution.interval.ms=/c\rules.execution.interval.ms=120000" $f
    echo "" >> $f
    # echo "com.volumeintegration.cre.aws.mocks.enabled=true" >> $f
    
    for PROPERTY in $FLOW_PROPERTIES
    do
        sed -i "/${PROPERTY%%=*}=/c\\${PROPERTY}" $f
    done
    echo "Updated properties in $f"
done


KEYSTORE_FILE=/settings/keystore.jks
TRUSTSTORE_FILE=/settings/truststore.jks

SYSTEM_PROPS=/settings/system.properties
CORRECT_SYS_PROPS=/etc/volume-gateway/system.properties
if [[ -f $SYSTEM_PROPS ]]; then
  cp $SYSTEM_PROPS $CORRECT_SYS_PROPS
  sed -i "/javax.net.ssl.keyStore=/c\javax.net.ssl.keyStore=$KEYSTORE_FILE" $CORRECT_SYS_PROPS
  sed -i "/javax.net.ssl.trustStore=/c\javax.net.ssl.trustStore=$TRUSTSTORE_FILE" $CORRECT_SYS_PROPS
fi

exec "$@"
