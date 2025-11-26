#!/bin/sh
set -e

: "${F2B_DESTEMAIL:=admin@example.com}"

: "${MSMTP_HOST:=smtp.example.com}"
: "${MSMTP_PORT:=587}"
: "${MSMTP_FROM:=user@example.com}"
: "${MSMTP_USER:=user@example.com}"
: "${MSMTP_PASSWORD:=changeme}"
: "${MSMTP_MAILDOMAIN:=example.com}"
: "${MSMTP_TLS:=on}"
: "${MSMTP_STARTTLS:=on}"

# Feste Wartezeit in Sekunden (optional)
: "${F2B_WAIT_BEFORE_START:=0}"

if [ "${F2B_WAIT_BEFORE_START}" -gt 0 ] 2>/dev/null; then
  echo "entrypoint: sleeping ${F2B_WAIT_BEFORE_START}s before start"
  sleep "${F2B_WAIT_BEFORE_START}"
fi

cat > /etc/msmtprc <<EOF
defaults
auth on
tls ${MSMTP_TLS}
maildomain ${MSMTP_MAILDOMAIN}
auto_from on

account default
host ${MSMTP_HOST}
port ${MSMTP_PORT}
from ${MSMTP_FROM}
user ${MSMTP_USER}
password ${MSMTP_PASSWORD}
tls_starttls ${MSMTP_STARTTLS}
aliases /etc/msmtp-aliases
EOF
chmod 600 /etc/msmtprc

cat > /etc/msmtp-aliases <<EOF
root: ${F2B_DESTEMAIL}
default: ${F2B_DESTEMAIL}
EOF

# Exec fail2ban in foreground
exec /usr/bin/fail2ban-server -f
