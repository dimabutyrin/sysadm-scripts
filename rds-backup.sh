#!/bin/bash

 # check awscli is istalled or not
command -v aws >/dev/null 2>&1 || { echo -e "This script require aws-cli but it's not installed. Run: \n\tsudo apt-get install python-pip && sudo pip install awscli==1.5.1" >&2; exit 1; }

 #AWS credentials (IAM user - rds-dumper)
 export AWS_ACCESS_KEY_ID=YOUR_AWS_KEY
 export AWS_SECRET_ACCESS_KEY=YOUR_AWS_KEY_SECRET
 export AWS_DEFAULT_REGION=us-east-1

 #list of RDS DBs which we will backup
array=( rds-node-1 rds-node-2 rds-node-3 )
 #script should be run with a parameter - backup retention period
period=$1

 #function for db-backup
function db-backup {
for i in "${array[@]}"
	do
	# creating new snapshots
	aws rds create-db-snapshot --db-instance-identifier=$i --db-snapshot-identifier=$i-$period-backup-`date +%Y-%m-%d`;
	# deleting old snapshots
	aws rds describe-db-snapshots --snapshot-type=manual --output=text --db-instance-identifier=$i | grep $period | sort -r -k13 | cut -f5 | tail -n +$keep_snapshots | while read line
		do
			aws rds delete-db-snapshot --db-snapshot-identifier=$line
		done
	done
}

case $period in
	weekly)
	keep_snapshots=5 #this will delete db-snapsots starts from 5th
	if [ $(date '+%d') -ne 1 ];then #check if today a 1st day of month
	db-backup
	fi
	;;
	monthly)
	keep_snapshots=3 #this will delete db-snapsots starts from 3rd
	db-backup
	;;
	daily)
	keep_snapshots=7 #this will delete db-snapsots starts from 7th
	if [ $(date '+%a') != Sun ];then #check if today a 1st day of week
	db-backup
	fi
	;;
	*) #wrong period, show help
	echo "$(basename "$0") [ARG] -- script for RDS backups
	USAGE:
	$(basename "$0") weekly - for weekly backup
	$(basename "$0") monthly - for monthly backup"
esac
