# Cisco API

### HTTP Basic Access Authentication

See _page 38_ in _API Reference_ for API.

```bash
BASIC_AUTH_USER="myname"
BASIC_AUTH_PASS="mypassword"
BASIC_AUTH=$(echo -ne "$BASIC_AUTH_USER:$BASIC_AUTH_PASS" | base64 --wrap 0)
HOST="https://cisco_ip"

curl -k -H "Authorization: Basic $BASIC_AUTH" $HOST/status.xml
curl -k -H "Authorization: Basic $BASIC_AUTH" $HOST/configuration.xml
```

### Command through API

#### Updating the device name

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
  -d "$DATA"
```

#### Rebooting

See _page 325_ in _API Reference_ for `SystemUnit Boot`.

```bash
DATA=$(cat <<EOF
<Command>
  <SystemUnit>
    <Boot command="True">
      <Action>Restart</Action>
      <Force>True</Force>
    </Boot>
  </SystemUnit>
</Command>
EOF
)

curl -k $HOST/putxml \
  -H "Authorization: Basic $BASIC_AUTH" \
  -H "Content-Type: text/xml" \
  -d "$DATA"
```

### Factory reset

See _page 326_ in _API Reference_ for

```bash
DATA=$(cat <<EOF
<Command>
  <SystemUnit>
    <FactoryReset command="True">
      <Confirm>Yes</Confirm>
      <Keep>Certificates/HTTP/LocalSetup/Network/Provisioning/RemoteSupportUser</Keep>
      <TrailingAction>Restart</TrailingAction>
    </FactoryReset>
  </SystemUnit>
</Command>
EOF
)

curl -k $HOST/putxml \
  -H "Authorization: Basic $BASIC_AUTH" \
  -H "Content-Type: text/xml" \
  -d "$DATA"
```

### Links

- https://www.cisco.com/c/dam/en/us/td/docs/telepresence/endpoint/roomos-111/api-reference-guide-roomos-111.pdf
