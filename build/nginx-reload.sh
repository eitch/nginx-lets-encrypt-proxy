#!/bin/bash

sleep 5s

WATCH_DIR="/etc/nginx/sites-enabled"

echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Watching directory ${WATCH_DIR} for changes to file ${WATCH_FILE_NAME}..."

lastReload=0

inotifywait -m -e CREATE -e CLOSE_WRITE "${WATCH_DIR}" | while read filename eventlist eventfile ; do
  [[ $eventfile =~ ^\..* ]] && continue
  now=$(date +%s)
  diff=$((now-lastReload))
  if [[ ${diff} -lt 10 ]] ; then
    echo -e "INFO: Ignoring duplicate action to $eventfile"
    continue
  fi

  echo -e "$(date +'%Y-%m-%d %H:%M:%S') INFO: Reloading nginx as changes detected in file $filename $eventlist $eventfile"
  nginx -s reload
done

exit 0