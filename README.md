# Jitsi Cluster

`Jitsi` cluster based on `LXC`.

## JMS (Jitsi Meet Server)

The `JMS` server contains:

- `Jitsi-Meet` web interface\
  _published through `Nginx`_

- `Prosody`\
  _XMPP server_

- `Jicofo`\
  _Jitsi conference focus service_

- `TURN`

- `JVB`\
  _This service may be disabled if there are additional `JVBs`_

### Prerequisites

#### Supported distribution

`Debian 11 Bullseye`

#### Server specifications

- At least 2 CPU cores
- At least 8 GB RAM
- At least 20 GB disk

#### DNS records

- `DNS A record` for `JMS` which points this server\
  e.g. `jitsi.nordeck.corp`

- `DNS CNAME record` for `TURN` as an alias for `JMS`\
  e.g. `turn.nordeck.corp`

#### Public ports

- `TCP/443`

- `TCP/80`\
  _If Lets Encrypt is used_

- `TCP/5222`\
  _If there are additional `JVBs` or `Jibris` which access `JMS` through the
  public IP_

- `TCP/10000`\
  _If there is an enabled `JVB` on `JMS`_

#### Deployment key

Create a deployment key for each customer

```bash
ssh-keygen -t rsa -b 4096 -f deploy
```

Add the content of `deploy.pub` as a deployment key on `GitHub`.

![deployment key](docs/images/deployment_key.png)
