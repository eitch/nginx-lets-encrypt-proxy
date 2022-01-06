#!/bin/bash
# Create a self signed default certificate, so Nginx can start before we have
# any real certificates.

#Ensure we have folders available

WATCH_FILE="/etc/letsencrypt/configured-domains"
LETSENCRYPT_DIR="/etc/letsencrypt"
CERTBOT_WWW_DIR="/var/www/certbot"

if [[ ! -f "${WATCH_FILE}" ]] ; then
  echo -e "E$(date +'%Y-%m-%d %H:%M:%S') RROR: Failed to read configured-domains file: ${WATCH_FILE}"
  exit 1
fi

if [[ ! -d "${CERTBOT_WWW_DIR}" ]] ; then
  echo -e "E$(date +'%Y-%m-%d %H:%M:%S') RROR: Certbot directory does not exist at ${CERTBOT_WWW_DIR}"
  exit 1
fi

LETS_ENCRYPT_EMAIL=eitch@eitchnet.ch
NGINX_HOST=proxy.eitchnet.ch
NGINX_PORT=80

if [[ ! -f /etc/letsencrypt/snake-oil/fullchain.pem ]] ; then
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Creating snake-oil certificate..."
    mkdir -p /etc/letsencrypt/snake-oil
    openssl genrsa -out /etc/letsencrypt/snake-oil/private-key.pem 4096
    openssl req -new -key /etc/letsencrypt/snake-oil/private-key.pem -out /etc/letsencrypt/snake-oil/snake-oil.csr -nodes -subj \
    "/C=CH/ST=Solothurn/L=Solothurn/O=Home/OU=Lab/CN=${NGINX_HOST}"
    openssl x509 -req -days 365 -in /etc/letsencrypt/snake-oil/snake-oil.csr -signkey /etc/letsencrypt/snake-oil/private-key.pem -out /etc/letsencrypt/snake-oil/fullchain.pem
fi

trap "echo $(date +'%Y-%m-%d %H:%M:%S') exiting due to signal ; kill $(jobs -p)" SIGHUP SIGINT SIGTERM SIGQUIT SIGTRAP SIGABRT SIGSTOP
trap "echo $(date +'%Y-%m-%d %H:%M:%S') exiting due to error! ; exit" ERR

nginx -g "daemon off;" &
nginx_sid=$!

/opt/certbot-obtain.sh ${WATCH_FILE} ${LETSENCRYPT_DIR} ${CERTBOT_WWW_DIR} &
/opt/certbot-renewal.sh "12h" &
/opt/nginx-reload.sh &

echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Sleeping indefinitely..."
wait ${nginx_sid}
echo -e "INFO: nginx has exited, exiting script!"
kill $(jobs -p)
exit 0