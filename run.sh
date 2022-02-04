#!/bin/sh

set -eo pipefail

echo "0 1 * * * /bin/sh /backup.sh" > /etc/crontabs/root
exec crond -d 8 -f
