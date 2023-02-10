## Development Notes

### Inbound call issue

`Video-SIP-Gateway` is in `LXC` container behind a firewall. So `pjsua` is not
accessible directly through `UDP/5060`. This prevents `inbound calls` if there
is no solution which can handle `NAT`.

- Using alphanumeric as an extention fails in `FreeSWITCH`. Maybe there is an
  error in my configuration. Use only numbers to be safe.

- `Incoming call` fails in there is no `--contact` while running `pjsua`

- `--contact` with `FQDN` doesn't work in my environment.
  - `--contact '<sip:1000@sip.mydomain.corp:5060;transport=udp>'` fails
  - `--contact '<sip:1000@172.17.17.36:5060;transport=udp>'` works
    \
    `172.17.17.36` is the IP address of SIP server.
