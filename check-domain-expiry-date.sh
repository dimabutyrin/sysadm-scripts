#!/bin/bash
#
# WARNING! For .com domain script may return incorrect data, compare it with domain registrar whois.
#
# Script returns the list of domains with days amount left to their expiration.
# Run this script with a parameter if you want to send an email when expiration date is less than 30 days.
# Sendmail should be configured on host from which this script starts.
# Supports only .com .is and .ua domains. Other domains can be added easily.
# Responsible whois servers for different zones can be found here: http://www.nirsoft.net/whois_servers_list.html
#

# Array with domains
array=( twitter.com facebook.com page.is imena.ua)

# Check for whois
if ( ! which whois >/dev/null 2>/dev/null );  then
	echo "You do not have the 'whois' tool installed."
	exit 2
fi

for name in "${array[@]}"
        do
		# Find domain root zone
		TLDTYPE="`echo $name | cut -d '.' -f3 | tr '[A-Z]' '[a-z]'`"
		if [ "${TLDTYPE}"  == "" ];
		then
			TLDTYPE="`echo $name | cut -d '.' -f2 | tr '[A-Z]' '[a-z]'`"
		fi

		# Find expiration date
		if [ "${TLDTYPE}"  == "com" ];
		then
			date=$(whois $name 2>/dev/null | awk '/Expiration Date:/ { print $3 }' | head -1)
		elif  [ "${TLDTYPE}"  == "is" ];
		then
			date=$(whois -h whois.isnic.is $name | awk '/expires:/ { print $2 " " $3 " " $4 }')
		elif [ "${TLDTYPE}"  == "ua" ];
		then
			date=$(whois -h whois.ua $name | awk '/expires:/ { print $2 }')
		else
			echo "Unknown root zone .$TLDTYPE"
			# Continue to the next item in the array
			continue
		fi

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
		FROM='dns.check@example.net'
		TO='sysadm@example.net'
		TO2='sysadm2@example.net'
		SUBJECT="Expiration date for domain $name"
		BODY="Registration of $name domain expires: `date` [$diff in the future]."
		printf "From: <%s>\nTo: <%s>\nTo: <%s>\nSubject: %s\n\n%s" "$FROM" "$TO" "$TO2" "$SUBJECT" "$BODY" | sendmail -t -f "$FROM"

		# And print the result
		echo "$name $diff"

		else
		# Just print the result
		echo "$name $diff"
		fi

done
