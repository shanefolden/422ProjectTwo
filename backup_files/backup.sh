#!/bin/bash

MONTH=`date +%m`
DAY=`date +%d`
HOUR=`date +%H`
cd /home/kenneth/Desktop/Adrian/cis422_backup/CIS422_Project1_backup_v2
mkdir -p $MONTH-$DAY/$HOUR
mysqldump -umanhimf -hix-dev.cs.uoregon.edu -p6523652389 --port=3797 CIS422_Project1 > $MONTH-$DAY/$HOUR/backup.sql

