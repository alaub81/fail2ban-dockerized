#!/bin/sh
set -eu

# 1) Fail2ban accessible?
if ! fail2ban-client ping >/dev/null 2>&1; then
  echo "healthcheck: fail2ban ping failed"
  exit 1
fi

# 2) At least one jail?
if ! fail2ban-client status 2>/dev/null | grep -q "Jail list:"; then
  echo "healthcheck: no jail list found"
  exit 1
fi

# 3) SMTP accessible? (only check if host/port are set)
if [ -n "${MSMTP_HOST:-}" ] && [ -n "${MSMTP_PORT:-}" ]; then
  # Build arguments cleanly with 'set --' (avoids SC2086)
  set -- --serverinfo --host="${MSMTP_HOST}" --port="${MSMTP_PORT}" --timeout=5
  [ "${MSMTP_TLS:-on}" = "on" ] && set -- "$@" --tls
  [ "${MSMTP_STARTTLS:-on}" = "on" ] && set -- "$@" --tls-starttls

  if ! msmtp "$@" >/dev/null 2>&1; then
    echo "healthcheck: smtp server not reachable: ${MSMTP_HOST}:${MSMTP_PORT}"
    exit 1
  fi
fi

echo "healthy"
