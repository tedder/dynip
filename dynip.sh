#!/bin/bash -e

while true; do
  if [ -n "$HEALTHCHECK_URL" ]; then
    curl --silent -o /dev/null $HEALTHCHECK_URL
  fi

  MYNAME=${MYNAME:-home}
  OLDIP=$(dig @${WHOIS_HOST} +short ${MYNAME}.${MYDOMAIN})
  MYIP=$(/usr/bin/curl --silent https://api.ipify.org)
  if [ "$MYIP" == "$OLDIP" ]; then
    echo "match."
    sleep 3600
    continue
  fi

  echo "IP for $MYNAME changing (from $OLDIP to $MYIP)."

  read -d '' MYJSON <<EOF
  { "Changes": [ { "Action": "UPSERT", "ResourceRecordSet": { "Name": "${MYNAME}.${MYDOMAIN}.", "Type": "A", "TTL": 600, "ResourceRecords": [{ "Value": "$MYIP" }] }}]}
EOF
  echo "$MYJSON"
  RET=`/usr/bin/aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONE_ID} --change-batch "$MYJSON"`
  IS_PENDING=`echo $RET | jq ".ChangeInfo.Status == \"PENDING\""`
  echo "$RET"

  echo "update done"
done
