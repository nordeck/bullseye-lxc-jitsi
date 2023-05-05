## Direct Incoming Call

This notes are related with direct incoming SIP calls. This is the case when
there is no SIP server in the environment and the remote peer calls `pjsua`
directly to start the SIP session.

### Needed changes

The following changes should be applied to `video-sip-gateway` server manually
after the standard setup.

#### Disable sip-ephemeral-container service

```bash
systemctl stop sip-ephemeral-container.service
systemctl disable sip-ephemeral-container.service
```

#### Create a static video-sip-gateway container

Create a static video-sip-gateway container by cloning it from
`nordeck-sip-template`.

```bash
lxc-copy -n nordeck-sip-template -N nordeck-sip-1
```

Set a static internal IP for this container.

```bash
cat >/var/lib/lxc/nordeck-sip-1/rootfs/etc/systemd/network/eth0.network <<EOF
[Match]
Name=eth0

[Network]
Address=172.22.22.101/24
Gateway=172.22.22.1
EOF
```

Add mount entries for video devices:

```bash
cat >>/var/lib/lxc/nordeck-sip-1/config <<EOF
lxc.mount.entry = /dev/video2 dev/video0 none bind,optional,create=file
lxc.mount.entry = /dev/video3 dev/video1 none bind,optional,create=file
EOF
```

#### Firewall rules

Add NAT rules in `/etc/nftables.conf`

```
chain prerouting {
  ...
  iif "enp1s0" ip saddr != 172.22.22.0/24 tcp dport 5060 dnat to 172.22.22.101
  iif "enp1s0" ip saddr != 172.22.22.0/24 udp dport 5060 dnat to 172.22.22.101
  iif "enp1s0" ip saddr != 172.22.22.0/24 udp dport 4000-4010 dnat to 172.22.22.101
```

And restart `nftables`

```bash
systemctl restart nftables.service
```

#### Pjsua config

Set `pjsua` config, `EXTERNAL_IP` is the IP address which is publicly accessible
by remote peers.

```bash
EXTERNAL_IP=172.17.17.203

cat >>/var/lib/lxc/nordeck-sip-1/rootfs/etc/jitsi/jibri/pjsua.config <<EOF
--ip-addr=$EXTERNAL_IP
--contact "<sip:$EXTERNAL_IP:5060>"
--id "jibri <sip:$EXTERNAL_IP>"
EOF
```

#### Start container

```bash
lxc-start -n nordeck-sip-1
```
