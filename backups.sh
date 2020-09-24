#!/bin/bash

source /pgenv.sh

#echo "Running with these environment options" >> /var/log/cron.log
#set | grep PG >> /var/log/cron.log

MYDATE=`date +%d-%B-%Y`
MONTH=$(date +%B)
YEAR=$(date +%Y)
MYBACKUPDIR=${S3_BUCKET_PREFIX}/${YEAR}/${MONTH}
mkdir -p ${MYBACKUPDIR}
cd ${MYBACKUPDIR}

echo "Backup running to $MYBACKUPDIR" >> /var/log/cron.log

echo "Dump users and permisions"  >> /var/log/cron.log
pg_dumpall --globals-only | aws s3 cp - s3://${S3_BUCKET}/${S3_BUCKET_PREFIX}/globals.dmp

#
# Loop through each pg database backing it up
#
for DB in ${DBLIST}
do
  FILENAME=${MYBACKUPDIR}/${DUMPPREFIX}_${DB}.${MYDATE}.dmp
  echo "Backing up $DB to s3://${S3_BUCKET}/${FILENAME}"  >> /var/log/cron.log
  pg_dump -Fc ${DB} | aws s3 cp - s3://${S3_BUCKET}/${FILENAME}
done
