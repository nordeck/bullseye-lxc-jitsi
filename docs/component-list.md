## jitsi-meet

`deb package` <-- https://download.jitsi.org

- custom config for `recording`
- custom config for `livestream`
- custom config for `dialplan`
- custom config for `UI`

## jicofo

`deb package` <-- https://download.jitsi.org

- custom config for `JibriBrewery`
- custom config for `SipBrewery`

## Videobridge

`deb package` <-- https://download.jitsi.org

- custom config for `RESTAPI`

## Prosody

`deb package` <-- Official Debian Bullseye repo

- custom config for `authentication`, probably the `token` authentication
- custom config for `Sip virtualhost`
- custom config for `Recorder virtualhost`
- additional `prosody` account for `sip`
- additional `prosody` account for `jibri`
- additional `prosody` account for `recorder`
- optional `prosody` modules from
  https://github.com/jitsi-contrib/prosody-plugins

## Coturn

`deb package` <-- Official Debian Bullseye repo

- optional custom config depending on the setup environment

## Nginx

`deb package` <-- Official Debian Bullseye repo

- custom config for `jitsi-component-selector`
- custom config for `ASAP key server` which provides public keys for
  `jitsi-component-sidecar`
  - See _Atlassian Service Authentication Protocol_
- optional custom config for `coturn` depending on the setup environment
- optional custom config for `dialplan service`

## DialPlan service

`source code` <- https://github.com/jitsi-contrib/sip-dial-plan

This service is an optional component. It is used if moderators start a SIP
session through Jitsi UI.

**Dependencies:**

- `deno` from https://github.com/denoland/deno

## jitsi-component-selector

`source code` <- https://github.com/jitsi/jitsi-component-selector

- building `deb package`
- generating public-private key pair
- custom config

**Dependencies:**

- `nodejs` and `npm` from https://deb.nodesource.com/node_18.x
- `redis` from Official Debian Bullseye repo

## jitsi-component-sidecar

`source code` <- https://github.com/jitsi/jitsi-component-sidecar

- building `deb package`

## pjproject

`source code` <- https://github.com/jitsi/pjproject (_branch jibri-2.10-dev1_)

- building `pjsua` executable

**Dependencies:**

- Some development tools, codecs and libraries from Official Debian Bullseye
  repo
