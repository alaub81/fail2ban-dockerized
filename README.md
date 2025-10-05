# fail2ban-dockerized

Dockerized Fail2ban (Debian-based, journald backend, iptables-nft).
- ENV-driven config for Fail2ban + msmtp
- Host networking + NET_ADMIN for banning
- See `.env.example` for configuration

## Quick start
docker compose build && docker compose up -d
