# docker build -t iwaco/shja-cron:v0.0.6 -f docker/shja-cron/Dockerfile .
# docker run -d -v /path/to/crontab:/var/spool/cron/crontabs/root iwaco/shja-cron
FROM iwaco/shja:v0.0.6
MAINTAINER Iwaco "iwaco@iwaco.pink"

COPY docker/shja-cron/start.sh /start.sh

CMD ["/start.sh"]
