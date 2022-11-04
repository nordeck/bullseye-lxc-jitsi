# Jitsi Cluster

`Jitsi` cluster based on `LXC`.

- [1. JMS (Jitsi Meet Server)](#1-jms-jitsi-meet-server)
  - [1.1 Prerequisites](#11-prerequisites)
    - [1.1.1 Supported distribution](#111-supported-distribution)
    - [1.1.2 Server specifications](#112-server-specifications)
    - [1.1.3 DNS records](#113-dns-records)
    - [1.1.4 Public Ports](#114-public-ports)
    - [1.1.5 Creating the deployment key](#115-creating-the-deployment-key)
  - [1.2 Installation](#12-installation)
    - [1.2.1 Login to the server](#121-login-to-the-server)
    - [1.2.2 Installer script](#122-installer-script)
    - [1.2.3 Installer config](#123-installer-config)
    - [1.2.4 Deployment key](#124-deployment-key)
    - [1.2.5 Running the installer](#125-running-the-installer)
- [2. Additional JVB (Jitsi Video Bridge)](#2-additional-jvb-jitsi-video-bridge)
  - [2.1 Prerequisites](#21-prerequisites)
    - [2.1.1 Supported distribution](#211-supported-distribution)
    - [2.1.2 Server specifications](#212-server-specifications)
    - [2.1.3 Public Ports](#213-public-ports)
    - [2.1.4 SSH server](#214-ssh-server)
    - [2.1.5 JMS public key](#215-jms-public-key)
  - [2.2 Installation](#22-installation)
- [3. Additional Jibri](#3-additional-jibri)
  - [3.1 Prerequisites](#31-prerequisites)
    - [3.1.1 Supported distribution](#311-supported-distribution)
    - [3.1.2 Server specifications](#312-server-specifications)
    - [3.1.3 Public Ports](#313-public-ports)
    - [3.1.4 SSH server](#314-ssh-server)
    - [3.1.5 JMS public key](#315-jms-public-key)
  - [3.2 Installation](#32-installation)
- [4. Additional Video SIP Gateway](#4-additional-video-sip-gateway)
  - [4.1 Prerequisites](#41-prerequisites)
    - [4.1.1 Supported distribution](#411-supported-distribution)
    - [4.1.2 Server specifications](#412-server-specifications)
    - [4.1.3 Public Ports](#413-public-ports)
    - [4.1.4 SSH server](#414-ssh-server)
    - [4.1.5 JMS public key](#415-jms-public-key)
  - [4.2 Configuration](#42-configuration)
  - [4.3 Installation](#43-installation)
  - [4.4 Updating the PJSUA configuration](#44-updating-the-pjsua-configuration)

## 1. JMS (Jitsi Meet Server)

The `JMS` server contains:

- `Jitsi-Meet`\
  _Jitsi web interface published through `Nginx`_

- `Prosody`\
  _XMPP server_

- `Jicofo`\
  _Jitsi Conference Focus service_

- `Coturn`\
  _TURN server_

- `JVB`\
  _Jitsi Video Bridge service_\
  _This service may be disabled if there are additional `JVBs`_

### 1.1 Prerequisites

#### 1.1.1 Supported distribution

`Debian 11 Bullseye`

#### 1.1.2 Server specifications

- At least 2 CPU cores
- At least 8 GB RAM
- At least 8 GB disk

#### 1.1.3 DNS records

- `DNS A record` for `JMS` which points to this server\
  e.g. `jitsi.nordeck.corp`

- `DNS CNAME record` for `TURN` as an alias for `JMS`\
  e.g. `turn.nordeck.corp`

Both FQDNs must be resolvable. Test them using the following commands:

```bash
host jitsi.nordeck.corp
host turn.nordeck.corp
```

#### 1.1.4 Public Ports

- `TCP/443`

- `TCP/80`\
  _If Lets Encrypt is used_

- `TCP/5222`\
  _If there are additional `JVB`, `Jibri` or `Video-SIP-Gateway` nodes which
  access `JMS` through the public IP_

- `UDP/10000`\
  _If there is an enabled `JVB` on `JMS`_

#### 1.1.5 Creating the deployment key

Create a deployment key for each customer

```bash
ssh-keygen -t rsa -b 4096 -f jitsi-deploy-customer_name
```

Add the content of `jitsi-deploy-customer_name.pub` as a deployment key on
`GitHub`.

![deployment key](docs/images/deployment_key.png)

### 1.2 Installation

#### 1.2.1 Login to the server

Login to the server as `root` user

#### 1.2.2 Installer script

Download `ni`, the Nordeck Installer script

```bash
cd /root
wget -O ni https://raw.githubusercontent.com/nordeck/bullseye-lxc-base/main/installer/ni
```

#### 1.2.3 Installer config

Copy [nordeck-jitsi.conf](installer/nordeck-jitsi.conf) into `/root/` folder and
customize it if needed, For example add FQDNs into it:

```bash
echo export JITSI_FQDN=jitsi.nordeck.corp >>nordeck-jitsi.conf
echo export TURN_FQDN=turn.nordeck.corp >>nordeck-jitsi.conf
```

#### 1.2.4 Deployment key

Copy the private part of the deployment key into `/root/.ssh/` folder. Its name
must be `deploy.key`

```bash
cp jitsi-deploy-customer_name /root/.ssh/deploy.key
chmod 600 /root/.ssh/deploy.key
```

_Don't delete the deployment key after the setup because it will be used to add
the additional nodes._

#### 1.2.5 Running the installer

Run the installer

```bash
cd /root
bash ni nordeck-jitsi
```

## 2. Additional JVB (Jitsi Video Bridge)

### 2.1 Prerequisites

#### 2.1.1 Supported distribution

`Debian 11 Bullseye`

#### 2.1.2 Server specifications

- At least 2 CPU cores
- At least 4 GB RAM
- At least 8 GB disk

#### 2.1.3 Public Ports

- `UDP/10000`

- `TCP/9090`\
  _The signaling port... This port must be accessible for `JMS`_

- `TCP/22`\
  _`SSH` port... This port must be accessible for `JMS`_

#### 2.1.4 SSH server

Install `openssh-server` if not already exists:

```bash
apt-get install openssh-server
```

#### 2.1.5 JMS public key

The `JMS` public SSH key must be in `/root/.ssh/authorized_keys` on `JVB`.

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# if there is a self-signed certificate, run it with --no-check-certificate
# wget --no-check-certificate -O /tmp/jms.pub https://jitsi.nordeck.corp/static/jms.pub

wget -O /tmp/jms.pub https://jitsi.nordeck.corp/static/jms.pub
cat /tmp/jms.pub >>/root/.ssh/authorized_keys
```

### 2.2 Installation

Login as `root` to `JMS` and run `add-jvb-node` command using IP address of
`JVB`:

```bash
add-jvb-node <JVB-IP-ADDRESS>
```

## 3. Additional Jibri

### 3.1 Prerequisites

#### 3.1.1 Supported distribution

`Debian 11 Bullseye`

#### 3.1.2 Server specifications

- At least 4 CPU cores for each `Jibri` instance.
- At least 4 GB RAM for each `Jibri` instance.
- At least 8 GB disk.
- More disk space if recorded files will be stored on this server.
- Maximum 16 `Jibri` instances supported on a single server.

#### 3.1.3 Public Ports

- `TCP/22`
  \
  _`SSH` port... This port must be accessible for `JMS`_

#### 3.1.4 SSH server

Install `openssh-server` if not already exists:

```bash
apt-get install openssh-server
```

#### 3.1.5 JMS public key

The `JMS` public SSH key must be in `/root/.ssh/authorized_keys` on `Jibri`.

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# if there is a self-signed certificate, run it with --no-check-certificate
# wget --no-check-certificate -O /tmp/jms.pub https://jitsi.nordeck.corp/static/jms.pub

wget -O /tmp/jms.pub https://jitsi.nordeck.corp/static/jms.pub
cat /tmp/jms.pub >>/root/.ssh/authorized_keys
```

### 3.2 Installation

Login as `root` to `JMS` and run `add-jibri-node` command using IP address of
`Jibri`:

```bash
add-jibri-node <JIBRI-IP-ADDRESS>
```

## 4. Additional Video SIP Gateway

### 4.1 Prerequisites

#### 4.1.1 Supported distribution

`Debian 11 Bullseye`

#### 4.1.2 Server specifications

- At least 8 CPU cores for each `video-sip-gateway` instance.
- At least 8 GB RAM for each `video-sip-gateway` instance.
- At least 8 GB disk.
- Maximum 4 `video-sip-gateway` instances supported on a single server.

#### 4.1.3 Public Ports

- `TCP/22`
  \
  _`SSH` port... This port must be accessible for `JMS`_

#### 4.1.4 SSH server

Install `openssh-server` if not already exists:

```bash
apt-get install openssh-server
```

#### 4.1.5 JMS public key

The `JMS` public SSH key must be in `/root/.ssh/authorized_keys` on
`video-sip-gateway`.

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# if there is a self-signed certificate, run it with --no-check-certificate
# wget --no-check-certificate -O /tmp/jms.pub https://jitsi.nordeck.corp/static/jms.pub

wget -O /tmp/jms.pub https://jitsi.nordeck.corp/static/jms.pub
cat /tmp/jms.pub >>/root/.ssh/authorized_keys
```

### 4.2 Configuration

Before adding the `video-sip-gateway` node, update `pjsua.config` template on
`JMS` according to your environment. `add-sip-node` command uses it to configure
the nodes.

The template file is in the `nordeck-jitsi` container.

- Path in container:\
  `/root/meta/pjsua.config`

- Path on host:\
  `/var/lib/lxc/nordeck-jitsi/rootfs/root/meta/pjsua.config`

Add SIP account info into it using the following format:

```conf
--id "jitsi <sip:<SIP_USER>@127.0.0.1>"
--registrar=sip:<SIP_SERVER_ADDRESS>
--realm=*
--username=<SIP_USER>
--password=<SIP_PASSWORD>
```

### 4.3 Installation

Login as `root` to `JMS` and run `add-sip-node` command using IP address of
`video-sip-gateway`:

```bash
add-sip-node <SIP-IP-ADDRESS>
```

### 4.4 Updating the PJSUA configuration

First, update the template file to change the `PJSUA` configuration. The
template file is in the `nordeck-jitsi` container.

- Path in container:\
  `/root/meta/pjsua.config`

- Path on host:\
  `/var/lib/lxc/nordeck-jitsi/rootfs/root/meta/pjsua.config`

Then run `update-sip-node` command using IP address of `video-sip-gateway`:

```bash
update-sip-node <SIP-IP-ADDRESS>
```

_Be careful, if there is an active SIP session while running this command, it
will be canceled._
