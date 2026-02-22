#!/bin/bash

/usr/bin/aws --version

while true; do
  date

  MYNAME=${MYNAME:-home}
  OLDIP=$(dig @${WHOIS_HOST} +short ${MYNAME}.${MYDOMAIN})
  MYIP=$(/usr/bin/curl --silent https://api.ipify.org)
  if [ "$MYIP" == "$OLDIP" ]; then
    echo "match."
    if [ -n "$HEALTHCHECK_URL" ]; then
      curl --silent --fail --show-error "${HEALTHCHECK_URL}?status=up&msg=${MYIP}"
    fi
    sleep 3600
    continue
  fi

  echo "IP for $MYNAME changing (from $OLDIP to $MYIP)."

  MYJSON="{ \"Changes\": [ { \"Action\": \"UPSERT\", \"ResourceRecordSet\": { \"Name\": \"${MYNAME}.${MYDOMAIN}.\", \"Type\": \"A\", \"TTL\": 600, \"ResourceRecords\": [{ \"Value\": \"$MYIP\" }] }}]}"
  echo "$MYJSON"
  /usr/bin/aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch "$MYJSON"

  echo "update done"

  if [ -n "$HEALTHCHECK_URL" ]; then
    curl --silent --fail --show-error "${HEALTHCHECK_URL}?status=up&msg=IP+changed%3A+${OLDIP}+to+${MYIP}"
  fi

  # we need to sleep so we don't repeatedly try to fix this
  sleep 300
done
