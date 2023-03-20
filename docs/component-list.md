# Components for video-sip-gateway

- All components are publicly available
- The components need to be put together in a special way
- Custom configurations are needed for many components
- Custom tools, scripts and modifications are needed to integrate components
- No publicly available documentation with all details
- Additional customizations and modifications may be needed depending on the
  target environment and use-case.

## 1. Jitsi-meet

`deb package` <-- https://download.jitsi.org

- custom config for `recording`
- custom config for `livestream`
- custom config for `dialplan`
- custom config for `UI`

## 2. Jicofo

`deb package` <-- https://download.jitsi.org

- custom config for `JibriBrewery`
- custom config for `SipBrewery`

## 3. Jitsi-videobridge

`deb package` <-- https://download.jitsi.org

- custom config for `RESTAPI`

## 4. Prosody

`deb package` <-- Official Debian Bullseye repo

- custom config for `authentication`, probably the `token` authentication
- custom config for `Sip virtualhost`
- custom config for `Recorder virtualhost`
- additional `prosody` account for `sip`
- additional `prosody` account for `jibri`
- additional `prosody` account for `recorder`
- optional `prosody` modules from
  https://github.com/jitsi-contrib/prosody-plugins

## 5. Coturn

`deb package` <-- Official Debian Bullseye repo

- optional custom config depending on the setup environment

## 6. Nginx

`deb package` <-- Official Debian Bullseye repo

- custom config for `jitsi-component-selector`
- custom config for `ASAP key server` which provides public keys for
  `jitsi-component-sidecar`
  - See _Atlassian Service Authentication Protocol_
- optional custom config for `coturn` depending on the setup environment
- optional custom config for `dialplan service`

## 7. DialPlan service

`source code` <- https://github.com/jitsi-contrib/sip-dial-plan

This service is an optional component. It is used if moderators start a SIP
session through Jitsi UI.

**Dependencies:**

- `deno` from https://github.com/denoland/deno

## 8. Jitsi-component-selector

`source code` <- https://github.com/jitsi/jitsi-component-selector

- building `deb package`
- generating public-private key pair
- custom config

**Dependencies:**

- `nodejs` and `npm` from https://deb.nodesource.com/node_18.x
- `redis` from Official Debian Bullseye repo

## 9. Jitsi-component-sidecar

`source code` <- https://github.com/jitsi/jitsi-component-sidecar

- building `deb package`

**Dependencies:**

- `nodejs` and `npm` from https://deb.nodesource.com/node_18.x

## 10. Pjproject

`source code` <- https://github.com/jitsi/pjproject (_branch jibri-2.10-dev1_)

- building `pjsua` executable

**Dependencies:**

- Some development tools, codecs and libraries from Official Debian Bullseye
  repo

## 11. Sip-video-gateway

Our `jibri` related modifications are in the `master` branch but not released
yet as `deb` package.

**Dependencies:**

- `deb package` of `jibri` <-- https://download.jitsi.org
- `deb package` of `jitsi-component-sidecar`
- `executable binary` of `pjsua`
- `nodejs` and `npm` from https://deb.nodesource.com/node_18.x
- `google-chrome-stable` from https://dl.google.com/linux/chrome/deb/
- `chromedriver` from https://chromedriver.storage.googleapis.com/
- `ffmpeg` from Official Debian Bullseye repo
- `redis` from Official Debian Bullseye repo

**Customization**

- `xorg` with 2 displays
- `icewm` with 2 desktops
- custom `jibri.conf`
- custom `icewm` config
- custom `asoundrc`
- custom `pjsua` config
- custom `ffmpeg` config
- custom `jitsi-component-sidecar` config
