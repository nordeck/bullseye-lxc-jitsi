## Development Notes

### Inbound call issue

`Video-SIP-Gateway` is in `LXC` container behind a firewall. So `pjsua` is not
accessible directly through `UDP/5060`. This prevents `inbound calls` if there
is no solution which can handle `NAT`.
