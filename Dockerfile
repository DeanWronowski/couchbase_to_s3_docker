FROM couchbase:community-6.0.0

RUN \
  apt-get update \
  && apt-get install -y python-pip && pip install awscli  \
  && apt-get autoremove && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt install cron
RUN systemctl enable cron

ENV PATH "/bin:/sbin:/usr/bin:/usr/sbin:/opt/couchbase/bin:/usr/local/bin/:/usr/local/sbin/"

ENTRYPOINT ["/run.sh"]
CMD ["cron", "0 1 * * *"]

COPY run.sh /
