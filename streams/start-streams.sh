#!/bin/bash

set -e
set -o pipefail

sleep 60

service volume-streams start
tail -F /var/log/volume-streams/volume-streams.out
