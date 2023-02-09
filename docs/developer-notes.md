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
