## Development Notes

### Existing sound card issue

If there is a sound card on the system, `snd_aloop` module needs the system to
be rebooted to create loopback devices because the first card (`card 0`) was
already reserved by the existing card and `snd_aloop` cannot use it.

So rebooting `jibri` and `video-sip-gateway` machines after the installation
solve the issue.

### Incoming call issue

`Video-SIP-Gateway` is in `LXC` container behind a firewall. So `pjsua` is not
accessible directly through `UDP/5060`. This prevents `incoming calls` if there
is no solution which can handle `NAT`.

- Using alphanumeric as an extention fails in `FreeSWITCH`. Maybe there is an
  error in my configuration. Use only numbers to be safe.

- `Incoming call` fails if there is no `--contact` while running `pjsua`

- `--contact` with `FQDN` doesn't work in my environment.
  - `--contact '<sip:1009@sip.nordeck.corp:5060;transport=udp>'` fails
  - `--contact '<sip:1009@172.17.17.36:5060;transport=udp>'` works
    \
    `172.17.17.36` is the IP address of SIP server.

```bash
exec /usr/local/bin/pjsua --config-file /etc/jitsi/jibri/pjsua.config \
  --id 'jitsi <sip:1009@sip.nordeck.corp>' \
  --registrar 'sip:sip.nordeck.corp' \
  --realm=* \
  --username=1009 \
  --password=1234 \
  --auto-answer-timer=30 \
  --auto-answer=200 \
  --contact '<sip:1009@172.17.17.36:5060;transport=udp>' \
  >/dev/null
```

### VP8 issue

Two `Linphone` peers can communicate with video over `FreeSWITCH` even `H.264`
is disabled.

When `H.264` is disabled, `Linphone` can see `pjsua`'s video but `pjsua` cannot
see `Linphone`'s video. It seems that there is `VP8` decoding issue in `pjsua`.

Check SIP packages on `FreeSWITCH` to collect more data about the issue.

**Edit:**\
After disabling `H.264` on `FreeSWITCH`, `VP8` works for `pjsua` too.

- `/etc/freeswitch/vars.xml`

```
253,254c253,254
<   <X-PRE-PROCESS cmd="set" data="global_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8"/>
<   <X-PRE-PROCESS cmd="set" data="outbound_codec_prefs=OPUS,G722,PCMU,PCMA,H264,VP8"/>
---
>   <X-PRE-PROCESS cmd="set" data="global_codec_prefs=OPUS,G722,PCMU,PCMA,VP8"/>
>   <X-PRE-PROCESS cmd="set" data="outbound_codec_prefs=OPUS,G722,PCMU,PCMA,VP8"/>
```

**Edit:**\
`VP8` works for direct calling without a SIP server. Tested with `Linphone` with
a disabled `H.264`.
