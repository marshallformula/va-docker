#!/bin/bash

set -e
set -o pipefail

service cre-web start
tail -F /var/log/cre-web.out
