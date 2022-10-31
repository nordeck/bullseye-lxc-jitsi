# Bullseye LXC Jitsi

`Jitsi` cluster based on `LXC`.

## JMS (Jitsi Meet Server)

The `JMS` server contains:

- `Jitsi-Meet` web interface\
  _published through `Nginx`_

- `Prosody`\
  _XMPP server_

- `Jicofo`\
  _`Jitsi` conference focus service_

- `TURN`

- `JVB`\
  _This service may be disabled if there are additional `JVB`s_

### Prerequisites

#### Supported distribution

`Debian 11 Bullseye`

#### Server specifications

- At least 2 CPU cores
- At least 8 GB RAM
- At least 20 GB disk

#### DNS records

- `DNS A record` for `JMS`\
  e.g. `jitsi.nordeck.corp`

- `DNS CNAME record` for `TURN`\
  e.g. `turn.norec.corp`
