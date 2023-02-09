## Local setup

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
- Testing
  - 3 participants while `coturn` and `main jvb` are stopped

### Additional Jibri

- Testing
  - recording

### Additional Video-SIP-Gateway

- Testing
  - outgoing call through UI
  - outgoing call through API
  - incoming call through API
