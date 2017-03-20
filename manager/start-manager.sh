#!/bin/bash

set -e
set -o pipefail

service vamonitor start
tail -F /var/log/vamonitor.out
