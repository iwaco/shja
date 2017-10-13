#!/usr/bin/env bash

# mkdir -p /var/spool/cron/crontabs
# echo "HOME=/usr/src/app" > /var/spool/cron/crontabs/root
# echo "* * * * * env" > /var/spool/cron/crontabs/root
# echo "* * * * * cd /usr/src/app; bundle exec ruby exe/carib --help" >> /var/spool/cron/crontabs/root
# echo "* * * * * cd /usr/src/app; bundle exec ruby exe/carib --help" >> /var/spool/cron/crontabs/root

exec busybox crond -l 2 -L /dev/stderr -f
