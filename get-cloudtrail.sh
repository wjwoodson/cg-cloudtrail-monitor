#!/bin/bash

set -e

if [[ -n $1 && $1 =~ (-h|--help)$ ]]
then
  echo -e "
  ./get-cloudtrail.sh [--help, -h] [--days -d]

  Get cloudtrail events listed in https://cloud.gov/docs/ops/maintenance-list/#review-aws-cloudtrail-events

  --help, -h        show this message

  --days, -d        number of days (now - days) to get events
  "
  exit
fi

echo "======== ======== get-cloudtrail.sh ======== ========"
echo "Getting events"

# end event window at now
end_ts=$(date +%s)

if [[ -n $1 && $1 =~ (-d|--days)$ ]]
then
  start_ts=$(($end_ts - ($2 * 86400)))
  echo "Days of events: ${2}"
else
  #start event window at (now - 1 day)
  start_ts=$(($end_ts - 86400))
  echo "Days of events: 1"
fi

#the types of events we need to lookup
lookupEvents=(
	"DeleteTrail"
	"UpdateTrail"
	"ModifyVpcAttribute"
	"PutUserPolicy"
	"PutRolePolicy"
	"RevokeSecurityGroupEgress"
	"RevokeSecurityGroupIngress"
	"AuthorizeSecurityGroupEgress"
	"AuthorizeSecurityGroupIngress"
	"CreatePolicy"
	"CreateSecurityGroup"
)

#display cloudtrail events for each EventName
for name in ${lookupEvents[@]}
do
  echo "======== ======== ${name} ======== ========"
  logs=$(
    aws cloudtrail lookup-events --start-time $start_ts --end-time $end_ts \
      --lookup-attributes AttributeKey=EventName,AttributeValue=$name
  )
  echo $logs | jq -r ' .Events[] | (.EventTime | todate) + " " + .EventName + " " + .Username + " " +
  (.CloudTrailEvent|fromjson| .sourceIPAddress + " " + .userAgent)'
done

echo "Done looking up events."
