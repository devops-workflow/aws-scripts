
credentials="${HOME}/.aws/credentials"
# For SAML
section='saml'
# Linux -nr
# Mac -nE

#echo -e "\tGet section"
#sed -n "/^\[${section}\]/,/^\[.*\]/p" ${credentials}
for item in aws_access_key_id aws_secret_access_key aws_session_token aws_security_token; do
  var="${item^^}"
  val=$(sed -n "/^\[${section}\]/,/^\[.*\]/p" ${credentials} | grep -E "^${item}[ ]*=" | sed "s/.* = *//")
  echo "$var=$val"
done
