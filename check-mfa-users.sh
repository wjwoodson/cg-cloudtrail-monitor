users=$(aws iam list-users | jq '[.[]| .[] | select (.PasswordLastUsed) | .UserName] | sort')
mfa_users=$(aws iam list-virtual-mfa-devices | jq '[.[]| .[].User.UserName]| sort')
echo "Human IAM users without MFA enabled:"
echo "{ \"users\": $users, \"mfa_users\": $mfa_users}" | jq '.users - .mfa_users'
