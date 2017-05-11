
set -e 

#the types of events we need to lookup
lookupEvents=(
  "AuthorizeSecurityGroupEgress"
  "AuthorizeSecurityGroupIngress"
  "ConsoleLogin"
  "CreatePolicy"
  "CreateSecurityGroup"
  "DeleteTrail"
  "ModifyVpcAttribute"
  "PutUserPolicy"
  "PutRolePolicy"
  "RevokeSecurityGroupEgress"
  "RevokeSecurityGroupIngress"
  "UpdateTrail"
)

# end window at now
current_ts=$(date +%s)
# start window at (now - 48 hours)
start_ts=$(($current_ts - 172800))

for name in ${lookupEvents[@]}
do
  logs=$(
    aws cloudtrail lookup-events --start-time $start_ts --end-time $current_ts \
    --lookup-attributes AttributeKey=EventName,AttributeValue=$name
  )
  echo $logs | jq ' .Events[] | .EventName + " " + .Username + " " '
done

echo "Done looking up events"
