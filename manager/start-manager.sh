#!/bin/bash

set -e
set -o pipefail

service volume-manager start
tail -F /var/log/volume-manager.out
