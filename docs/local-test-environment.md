## Local Test Environment

These are only valid for the test environment.

### JMS

- Before installation
  - Set `JITSI_FQDN` and `TURN_FQDN` in `nordeck-jitsi.conf`
  - Set `APP_ID` and `APP_SECRET` in `nordeck-jitsi.conf`
- After installation
  - `/etc/jitsi/videobridge/sip-communicator.properties` in `nordeck-jitsi`
    - Disable `STUN_MAPPING_HARVESTER_ADDRESSES`
    - Enable `harvester` addresses
  - Custom port in `/root/.ssh/jms-config`
  - Update `/root/meta/pjsua.config` (only needed for calls from UI)
  - Update `/home/dialplan/app/dial-plan.json`
    `/var/lib/lxc/nordeck-dialplan/rootfs/home/dialplan/app/dial-plan.json`
- Testing
  - 3 participants while `coturn` is stopped

### Additional JVB

- After installation
  - Enable `harvester` addresses in
    `/etc/jitsi/videobridge/sip-communicator.properties`
  - Hard-coded `EXTERNAL_IP` in `/usr/local/sbin/jvb-config`
- Testing
  - 3 participants while `coturn` and `main jvb` are stopped

### Additional Jibri

- After installation
  - Set `CPI` to `1` in `/usr/local/sbin/jibri-ephemeral-start`
- Testing
  - recording with local JVB
  - recording with additional JVB

### Additional Video-SIP-Gateway

- Before installation
  - Update `pjsua.config` in `meta` (only needed for calls from UI)
    ```
    --id "jitsi <sip:1009@sip.nordeck.corp>"
    --registrar=sip:sip.nordeck.corp
    --realm=*
    --username=1009
    --password=1234
    ```
- After installation
  - Set `CPI` to `2` in `/usr/local/sbin/sip-ephemeral-start`
- Testing
  - start `FreeSWITCH` to allow SIP
  - Add `Jitsi SIP account` into the SIP server
  - Configure a SIP client as a remote peer
  - `outgoing call` through UI
  - `outgoing call` through API
  - `incoming call` through API
  - `direct incoming call` is not supported on LXC based `video-sip-gateway`

### Additional Video-SIP-Gateway on VM

- Before installation update kernel on VM and reboot
  ```bash
  apt-get update
  apt-get install linux-image-amd64
  reboot
  ```
- Testing
  - `direct incoming call` through API
  - `direct outgoing call` through UI
