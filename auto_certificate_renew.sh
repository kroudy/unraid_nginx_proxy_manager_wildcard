#!/bin/bash
# Purpose: Automatically renew unRAID certificate with NGINX wildcard certificate
# Author: Kyle Roudebush {https://github.com/kroudy} under GPL v2.x+
# -------------------------------------------------------------------------------

LANNAME=$(hostname -s) # Server name
PEM="/boot/config/ssl/certs/${LANNAME}_unraid_bundle.pem" # SSL certificate location
NGINX="/mnt/user/appdata/nginx-proxy" # Nginx Proxy Manager appdata folder
CERTNUM="24" # Nginx Certificate number
DAYS="604800" # Number of days (in seconds) until certificate expires. (currently 7 days)

/usr/bin/openssl x509 -enddate -noout -in $PEM -checkend $DAYS | grep -q 'Certificate will expire'
 
# Regenterate NGINX certificates
if [ $? -eq 0 ]; then
	echo "$LANNAME certificate is being renewed."
	cat ${NGINX}/letsencrypt/live/npm-${CERTNUM}/fullchain.pem /mnt/user/appdata/nginx-proxy/letsencrypt/live/npm-${CERTNUM}/privkey.pem > $PEM
	/etc/rc.d/rc.nginx restart
	EXPIREDATE=$(openssl x509 -enddate -noout -in "$PEM" | awk '{ print substr( $0, 10 ) }')
	echo "$LANNAME certificate has been renewed and will expire on $EXPIREDATE."
else
	EXPIREDATE=$(openssl x509 -enddate -noout -in "$PEM" | awk '{ print substr( $0, 10 ) }')
	echo "Nothing to do. Certificates for $LANNAME is valid until $EXPIREDATE"
fi
