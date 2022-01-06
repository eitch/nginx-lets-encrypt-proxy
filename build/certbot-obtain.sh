#!/bin/bash

if [[ "$#" != "3" ]] ; then
  echo -e "ERROR: Usage: $0 <watch_file> <letsencrypt_dir> <certbot_dir>"
  exit 1
fi

WATCH_FILE="$1"
LETSENCRYPT_DIR="$2"
CERTBOT_WWW_DIR="$3"

WATCH_FILE_NAME=$(basename $(realpath ${WATCH_FILE}))
WATCH_DIR=$(dirname $(realpath ${WATCH_FILE}))

sleep 5s

echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Watching directory ${WATCH_DIR} for changes to file ${WATCH_FILE_NAME}..."

function parseFile() {
  file="$1"
  cat ${file} | while read line ; do
    line=${line##*( )}
    line=${line%%*( )}
    [[ "$line" == "" ]] && continue
    [[ $line =~ ^#.* ]] && continue
    
    obtainCertificate ${line}
  done
}

function obtainCertificate() {
  domain="$1"

  nginx_file="/etc/nginx/sites-enabled/${domain}"
  letsencrypt_file="${LETSENCRYPT_DIR}/live/${domain}"
  
  [[ ! -f ${nginx_file} ]] && continue
  [[ -d ${letsencrypt_file} ]] && continue

  echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Obtaining certificate for new domain ${domain}"
  if ! echo certbot certonly \
    --test-cert \
    --dry-run \
    --config-dir ${LETSENCRYPT_DIR} \
    --agree-tos \
    --domain "${domain}" \
    --email "${LETS_ENCRYPT_EMAIL}" \
    --expand \
    --noninteractive \
    --webroot \
    --webroot-path ${CERTBOT_WWW_DIR} ; then
    echo -e "$(date +'%Y-%m-%d %H:%M:%S') ERROR: Failed to obtain certificate for $domain"
    echo nginx -s quit
    exit 1
  fi
}

echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Initially obtaining certificates..."
parseFile ${WATCH_FILE}
echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Done."

inotifywait -m -e CLOSE_WRITE "${WATCH_DIR}" | while read filename eventlist eventfile ; do
  [[ $eventfile != ${WATCH_FILE_NAME} ]] && continue
  echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Obtaining certificates as changes detected in file $filename $eventlist $eventfile"
  parseFile ${WATCH_FILE}
done

exit 0