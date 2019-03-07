ouName=$1
email=$2 
accountName=$3
rootOrgId=$(aws organizations list-roots --query 'Roots[*].Id[]' --output text)
existingOU=$(aws organizations list-organizational-units-for-parent --parent-id $rootOrgId --output text --query "OrganizationalUnits[?contains(Name,'$ouName')].Name")
echo $existingOU
if [[ ! -z $existingOU ]] && [ $existingOU == $ouName ]
then
echo "OU not to be created as this OU already exists"
else
aws organizations create-organizational-unit --parent-id $rootOrgId --name $ouName
fi
existingAccount=$(aws organizations list-accounts --output text --query "Accounts[?contains(Email,'$email')].Email")
if [[ ! -z $existingAccount ]] && [ $existingAccount == $email ]
then
echo "This email is already, please use a different email address"
else
echo "Starting account creation"
reqId=$(aws organizations create-account --email $email --account-name "$accountName" --query "CreateAccountStatus.[Id]" --output text)
echo "Account is being created now"
sleep 25
status=$(aws organizations describe-create-account-status --create-account-request-id $reqId --query "CreateAccountStatus.[State]" --output text)
echo $status
accountId=$(aws organizations describe-create-account-status --create-account-request-id $reqId --query "CreateAccountStatus.[AccountId]" --output text)
echo $accountId
aws organizations move-account --account-id $accountId --source-parent-id $rootOrgId --destination-parent-id $ouName
fi

