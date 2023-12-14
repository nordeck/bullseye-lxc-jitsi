# Cisco API

### HTTP Basic Access Authentication

```bash
BASIC_AUTH_USER="myname"
BASIC_AUTH_PASS="mypassword"
BASIC_AUTH=$(echo -ne "$BASIC_AUTH_USER:$BASIC_AUTH_PASS" | base64 --wrap 0)
HOST="https://cisco_ip"

curl -k -H "Authorization: Basic $BASIC_AUTH" $HOST/status.xml
curl -k -H "Authorization: Basic $BASIC_AUTH" $HOST/configuration.xml
```

### Command through API

```bash
DATA=$(cat <<EOF
<Configuration>
  <SystemUnit>
    <Name>cisco</Name>
  </SystemUnit>
</Configuration>
EOF
)

curl -k $HOST/putxml \
  -H "Authorization: Basic $BASIC_AUTH" \
  -H "Content-Type: text/xml" \

```
