#!/bin/bash
#
# Script returns the list of domains with days amount left to their SSL expiration
# Run this script with a parameter if you want to send an email when SSL expiration date is less than 30 days
# Sendmail should be configured on host from which this script starts
#

# Array with domains
array=( facebook.com twitter.com )

# Check for openssl
if ( ! which openssl >/dev/null 2>/dev/null );  then
	echo "You do not have the 'openssl' tool installed"
	exit 2
fi

# Make a temporary file
tmp=$(mktemp)

for name in "${array[@]}"
        do
		# Download the certificate
		if ( ! echo "" | openssl s_client -connect $name:443 > $tmp 2>/dev/null ); then
			echo "Failed to get cert from https://$name"
			exit 3
		fi

		# Get the expiry date
		date=$(openssl x509 -in "$tmp" -noout -enddate | awk -F= '{print $2}')

		# Convert the expiry date + todays date to seconds-past epoch
		then=$(date --date "$date" +%s)
		now=$(date +%s)

		# Day diff
		diff=$(expr "$then" - "$now" )
		diff=$(expr $diff / 86400 )

		# Check that script is started with a parameter and expiration date less or equal 30
		if [ ! -z "$1" ] && [ $diff -le 30 ]
		then
		# Send e-mail
		FROM='ssl.check@example.net'
		TO='sysadm@example.net'
		TO2='sysadm2@example.net'
		SUBJECT="SSL sertificate for $name"
		BODY="SSL certificate for $name expires: `date` [$diff days in the future]."
		printf "From: <%s>\nTo: <%s>\nTo: <%s>\nSubject: %s\n\n%s" "$FROM" "$TO" "$TO2" "$SUBJECT" "$BODY" | sendmail -t -f "$FROM"

		# And print the result
		echo "$name $diff"

		else
		# Just print the result
		echo "$name $diff"
		fi

# Remove the temporary file
rm -f "$tmp"
done
