#!/bin/bash

/sbin/service neo4j start

tail -F /var/log/neo4j/neo4j.out
