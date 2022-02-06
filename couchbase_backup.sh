#!/bin/bash
#
# Backup script for 6 Couchbase
#

set -e

: ${AWS_ACCESS_KEY_ID:=""}
: ${AWS_SECRET_ACCESS_KEY:=""}

: ${AWS_DEFAULT_REGION:="us-east-2"}
: ${S3_BUCKET:="example-backup"}

: ${SERVER_IP:="127.0.0.1"}
: ${SERVER_USER:="Administrator"}
: ${SERVER_PASSWORD:="secret"}

: ${BACKUP_PATH:="/data"}
: ${RESTORE_BUCKETS:="default"}

# SERVER_IP="http://${SERVER_IP}:8091"
echo Server IP ${SERVER_IP}

sync_s3_up () {
  aws --region=${AWS_DEFAULT_REGION} \
                     s3 sync  \
                     ${BACKUP_PATH} \
                     s3://${S3_BUCKET}/${BACKUP_PATH}
}

sync_s3_down () {
  aws --region=${AWS_DEFAULT_REGION} \
                     s3 sync \
                     s3://${S3_BUCKET}/${BACKUP_PATH} \
                     ${BACKUP_PATH}
}

run_backup () {
  /opt/couchbase/bin/cbbackup couchbase://${SERVER_IP}:8091 ${BACKUP_PATH} \
           -u ${SERVER_USER} \
           -p ${SERVER_PASSWORD}
}

restore_backup () {
  local bucket
  for bucket in ${RESTORE_BUCKETS}; do
    echo Restoring ${bucket} bucket
    /opt/couchbase/bin/cbrestore ${BACKUP_PATH} couchbase://${SERVER_IP}:8091 \
              --bucket-source=${bucket}
  done
}


configure () {
  aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
  aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
  aws configure set region ${AWS_DEFAULT_REGION}
  
  rm -r ${BACKUP_PATH}
  mkdir -p ${BACKUP_PATH}
}

do_backup () {
  configure
  run_backup
  sync_s3_up
}

do_restore () {
  sync_s3_down
  restore_backup
}

# cron () {
#   echo "Starting backup cron job with frequency '$1'"
#   echo "$1 /$0 backup" > /etc/crontab
#   # crond -f
# }

# Handle command line arguments
case "$1" in
  "backup")
    do_backup
    ;;
  "restore")
    do_restore
    ;;
  *)
    echo "Invalid command '$@'"
    echo "Usage: $0 {backup|restore <pattern>}"
esac
