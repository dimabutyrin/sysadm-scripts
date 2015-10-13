# sysadm-scripts

Some useful scripts

## rds-backup.sh 
Script for backing up AWS RDS on monthly/weekly basis. Additionaly you can configure your RDS backup retention period to 7 days to have possibility to return your database to state of last 7 days, last 4 weeks and last 2 months.

In AWS IAM create separate user with these rights: rds:DescribeDBSnapshots, rds:CreateDBSnapshot, rds:DeleteDBSnapshot, and fill in his credentials into script.
