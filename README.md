# Jitsi Cluster

`Jitsi` cluster based on `LXC`.

- [JMS (Jitsi Meet Server)](#jms-jitsi-meet-server)
  - [Prerequisites](#prerequisites)
    - [Supported distribution](#supported-distribution)
    - [Server specifications](#server-specifications)
    - [DNS records](#dns-records)
    - [Public ports](#public-ports)
    - [Creating the deployment key](#creating-the-deployment-key)
  - [Installation](#installation)
    - [Login to the server](#login-to-the-server)
    - [Installer script](#installer-script)
    - [Installer config](#installer-config)
    - [Deployment key](#deployment-key)
    - [Running the installer](#running-the-installer)

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

- `UDP/10000`\
  _If there is an enabled `JVB` on `JMS`_

#### Creating the deployment key

Create a deployment key for each customer

```bash
ssh-keygen -t rsa -b 4096 -f jitsi-deploy-customer_name
```

Add the content of `jitsi-deploy-customer_name.pub` as a deployment key on
`GitHub`.

![deployment key](docs/images/deployment_key.png)

### Installation

#### Login to the server

Login to the server as `root` user

#### Installer script

Download `ni`, the Nordeck Installer script

```bash
cd /root
wget -O ni https://raw.githubusercontent.com/nordeck/bullseye-lxc-base/main/installer/ni
```

#### Installer config

Copy [nordeck-jitsi.conf](installer/nordeck-jitsi.conf) into `/root/` folder and
customize it if needed, For example add FQDNs into it:

```bash
echo export JITSI_FQDN=jitsi.nordeck.corp >>nordeck-jitsi.conf
echo export TURN_FQDN=turn.nordeck.corp >>nordeck-jitsi.conf
```

#### Deployment key

Copy the private part of the deployment key into `/root/.ssh/` folder. Its name
must be `deploy.key`

```bash
cp jitsi-deploy-customer_name /root/.ssh/deploy.key
chmod 600 /root/.ssh/deploy.key
```

#### Running the installer

Run the installer

```bash
cd /root
bash ni nordeck-jitsi
```
