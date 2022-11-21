#!/bin/bash
set -e

PARAMS=("$@")

i=0
for arg in "${PARAMS[@]}"; do
    # update the hardcoded protocol which comes from Jibri
    PARAMS[i]=$(echo $arg | sed 's/transport=tcp/transport=udp/')
    (( i += 1 ))
done

# push display :0 view to virtual camera 1
ffmpeg -f x11grab -r 30 -i :0.0 -pix_fmt yuv420p -f v4l2 /dev/video1 &
sleep 0.8

# if the request is from the selector, use all arguments.
# otherwise (if the request is from the dialplan) use only the second argument
# which is the callee address.
if [[ "$#" -gt 2 ]]; then
    exec /usr/local/bin/pjsua --config-file /etc/jitsi/jibri/pjsua.config \
        "${PARAMS[@]}" >/dev/null
else
    exec /usr/local/bin/pjsua --config-file /etc/jitsi/jibri/pjsua.config \
        "$2" >/dev/null
