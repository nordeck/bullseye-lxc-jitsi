## Local Test Environment

These are only valid for the test environment.

### JMS

- Before installation
  - Set `JITSI_FQDN` and `TURN_FQDN` in `nordeck-jitsi.conf`
  - Set `APP_ID` and `APP_SECRET` in `nordeck-jitsi.conf`
- After installation
  - Enable `harvester` addresses in
    `/etc/jitsi/videobridge/sip-communicator.properties`
  - Update `/root/meta/pjsua.config`
  - Update `/root/meta/env.sidecar.sip`
    - `SIP_CLIENT_PASSWORD`
    - `SIP_CLIENT_USERNAME`
  - Custom port in `/root/.ssh/jms-config`
  - Update `/home/dialplan/app/dial-plan.json`
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

- Testing
  - recording

### Additional Video-SIP-Gateway

- After installation
  - Set `CPI` to `2` in `/usr/local/sbin/sip-ephemeral-start`
- Testing
  - start `FreeSWITCH` to allow SIP
  - Add `Jitsi SIP account` into the SIP server
  - Configure a SIP client as a remote peer
  - outgoing call through UI
  - outgoing call through API
  - incoming call through API
