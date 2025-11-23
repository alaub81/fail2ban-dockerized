#!/bin/sh
set -eu

# 1) Fail2ban erreichbar?
if ! fail2ban-client ping >/dev/null 2>&1; then
  echo "healthcheck: fail2ban ping failed"
  exit 1
fi

# 2) Optional: mindestens 1 Jail?
if ! fail2ban-client status 2>/dev/null | grep -q "Jail list:"; then
  echo "healthcheck: no jail list found"
  exit 1
fi

# 3) Optional: SMTP erreichbar (nur prüfen, wenn Host gesetzt)
if [ -n "${MSMTP_HOST:-}" ] && [ -n "${MSMTP_PORT:-}" ]; then
  # TLS/STARTTLS je nach ENV übernehmen
  tls_args=""
  [ "${MSMTP_TLS:-on}" = "on" ] && tls_args="$tls_args --tls"
  [ "${MSMTP_STARTTLS:-on}" = "on" ] && tls_args="$tls_args --tls-starttls"
  if ! msmtp --serverinfo --host="$MSMTP_HOST" --port="$MSMTP_PORT" $tls_args --timeout=5 >/dev/null 2>&1; then
    echo "healthcheck: smtp server not reachable: $MSMTP_HOST:$MSMTP_PORT"
    exit 1
  fi
fi

echo "healthy"
exit 0
