#!/bin/bash

echo "===================="
echo "Neo4J Database Setup"
echo "===================="

echo "neo4j   soft    nofile  40000" >> /etc/security/limits.conf
echo "neo4j   hard    nofile  40000" >> /etc/security/limits.conf

if [[ -f /etc/neo4j/neo4j.conf ]]; then
    sed -i "/dbms.connectors.default_listen_address=/c\dbms.connectors.default_listen_address=0.0.0.0" /etc/neo4j/neo4j.conf
    echo "Updated connector properties in /etc/neo4j/neo4j.conf"
fi


echo "Contacting Neo4J server using HTTP"
/sbin/service neo4j start > /dev/null 2>&1
end="$((SECONDS+15))"
while true; do
    [[ "200" = "$(curl --silent --write-out %{http_code} --output /dev/null http://localhost:7474)" ]] && break
    if [[ "${SECONDS}" -ge "${end}" ]]; then
	echo "Neo4J server is not responding. Start service and try again."
	exit 1
    fi
    sleep 1
done

while [[ -z "$GRAPH_PASSWORD" ]]; do
	read -s -p "    New password for neo4j user: " GRAPH_PASSWORD
	echo ""
done

neo4j-initpass "${GRAPH_PASSWORD}"

if [[ "$?" != 0 ]]; then
	echo "Neo4J setup failed. Please try again."
	exit 1 
fi

/sbin/service neo4j stop
