FROM couchbase:community-6.0.0

ENV PATH "/bin:/sbin:/usr/bin:/usr/sbin:/opt/couchbase/bin:/usr/local/bin/:/usr/local/sbin/"

ENV AWS_ACCESS_KEY_ID ''
ENV AWS_SECRET_ACCESS_KEY ''

ENV AWS_DEFAULT_REGION ''
ENV S3_BUCKET ''

ENV SERVER_IP ''
ENV SERVER_USER ''
ENV SERVER_PASSWORD ''

ENV BACKUP_PATH ''
ENV RESTORE_BUCKETS ''

RUN \
  apt-get update \
  && apt-get install -y python-pip && pip install awscli  \
  && apt-get autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY couchbase_backup.sh /

RUN apt-get update && apt-get -y install cron

# Copy backup-cron file to the cron.d directory
COPY backup-cron /etc/cron.d/backup-cron
 
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/backup-cron

# Apply cron job
RUN crontab /etc/cron.d/backup-cron
 
# Create the log file to be able to run tail
RUN touch /var/log/cron.log

RUN echo "Running cron job"
 
# Run the command on container startup
CMD cron && tail -f /var/log/cron.log

# RUN apt-get install cron
# RUN systemctl enable cron

# ENTRYPOINT ["/run.sh"]
# CMD ["cron", "0 1 * * *"]
