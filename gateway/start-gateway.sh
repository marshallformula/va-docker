#!/bin/bash

set -e
set -o pipefail

service volume-gateway start
tail -F /var/log/volume-gateway/volume-gateway.out
