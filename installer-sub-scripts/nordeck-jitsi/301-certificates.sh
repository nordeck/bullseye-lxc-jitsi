# ------------------------------------------------------------------------------
# CERTIFICATES.SH
# ------------------------------------------------------------------------------
set -e
source $INSTALLER/000-source

# ------------------------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------------------------
cd

# ------------------------------------------------------------------------------
# INIT
# ------------------------------------------------------------------------------
[[ "$DONT_RUN_CERTIFICATES" = true ]] && exit

echo
echo "---------------------- CERTIFICATES -----------------------"

# ------------------------------------------------------------------------------
# EXTERNAL IP
# ------------------------------------------------------------------------------
EXTERNAL_IP=$(dig -4 +short myip.opendns.com a @resolver1.opendns.com) || true
echo EXTERNAL_IP="$EXTERNAL_IP" >> $INSTALLER/000-source

# ------------------------------------------------------------------------------
# SELF-SIGNED CERTIFICATE
# ------------------------------------------------------------------------------
cd /root/nordeck-certs
rm -f /root/nordeck-certs/nordeck-jitsi.*

# the extension file for multiple hosts:
# the container IP, the host IP and the host names
cat >nordeck-jitsi.ext <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
EOF

# FQDNs
echo "DNS.1 = $JITSI_FQDN" >>nordeck-jitsi.ext
echo "DNS.2 = $TURN_FQDN" >>nordeck-jitsi.ext

# internal IPs
i=1
for addr in $(egrep '^address=' /etc/dnsmasq.d/nordeck-jitsi); do
    ip=$(echo $addr | rev | cut -d '/' -f1 | rev)
    echo "IP.$i = $ip" >> nordeck-jitsi.ext
    (( i += 1 ))
done

# external IPs
echo "IP.$i = $REMOTE_IP" >>nordeck-jitsi.ext
(( i += 1 ))
[[ -n "$EXTERNAL_IP" ]] && [[ "$EXTERNAL_IP" != "$REMOTE_IP" ]] \
    && echo "IP.$i = $EXTERNAL_IP" >>nordeck-jitsi.ext \
    || true

# the domain key and the domain certificate
openssl req -nodes -newkey rsa:2048 \
    -keyout nordeck-jitsi.key -out nordeck-jitsi.csr \
    -subj "/O=nordeck/OU=nordeck-jitsi/CN=$JITSI_FQDN"
openssl x509 -req -CA nordeck-CA.pem -CAkey nordeck-CA.key -CAcreateserial \
    -days 10950 -in nordeck-jitsi.csr -out nordeck-jitsi.pem \
    -extfile nordeck-jitsi.ext
