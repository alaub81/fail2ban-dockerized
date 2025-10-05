# fail2ban-dockerized (Debian 13 / journald)

Dockerized **Fail2ban** tuned for systemd **journald** on the host and **iptables (nf_tables)** banning. Also included email notifications via **msmtp**.

- **Debian slim** as base
- Journald backend support (bind mounts), no host file logs required
- iptables/nftables banning for host SSH (INPUT chain)
- ENV-driven msmtp config (password via file/secret), logs to STDOUT
- Works on amd64 and arm64

## Requirements

- Host runs systemd **journald** and exposes it to the container (see volumes).
- Docker with `--cap-add=NET_ADMIN` and `--network host` allowed (see compose).
- SMTP relay (optional) if you want email notifications.

## Quick start

1. **Configure environment**
   Create a local env file and adjust values:

   ```bash
   cp fail2ban.env.example fail2ban.env
   # edit fail2ban.env (SMTP host/user, recipient, etc.)
   ```

2. **Enable SSH protection**
   Create your SSH jail from the example:

   ```bash
   mkdir -p data/fail2ban/jail.d
   cp data/fail2ban/jail.d/10-sshd.local.example data/fail2ban/jail.d/10-sshd.local
   ```

   Recommended when using host journald:

   ```ini
   # in 10-sshd.local
   backend = systemd
   ```

   Adjust ports if you use non‑standard SSH ports (e.g., `2222`).

3. **Start with Docker Compose**

   ```bash
   # pull a published image:
   docker compose -f docker-compose.yml up -d
   # or build locally:
   docker compose -f docker-compose.dev.yml up -d
   ```

4. **Verify**

   ```bash
   docker logs -f <container>
   docker exec -it <container> fail2ban-client status
   docker exec -it <container> fail2ban-client status sshd
   ```

## Configuration layout

- **Global fail2ban overrides**: put `.local` files into
  `data/fail2ban/fail2ban.d/` → mounted read-only to `/etc/fail2ban/fail2ban.d`
- **Jails**: put `.local` files into
  `data/fail2ban/jail.d/` → mounted read-only to `/etc/fail2ban/jail.d`

Typical files:

- `data/fail2ban/jail.d/10-sshd.local` – enable/adjust SSH jail (`enabled = true`, `port`, `backend = systemd`, etc.)
- `data/fail2ban/jail.d/99-custom.local` – your custom jails/filters
- `data/fail2ban/fail2ban.d/00-logging.local` – override global loglevel/target if needed

### Journald vs file backend

- Using host **journald**: set in your jail(s)

  ```ini
  backend = systemd
  ```

- Using file logs instead: provide `logpath` and mount the log file into the container.

### iptables chains

- **Host SSH**: use the default `chain = INPUT` (already implied by examples).
- **Protecting container‑exposed services**: consider

  ```ini
  chain = DOCKER-USER
  ```

  which is evaluated before Docker’s own rules for bridged ports.

## Configuration

Set in `fail2ban.env` (see `fail2ban.env.example`):

```dotenv
F2B_DESTEMAIL=alerts@yourdomain.tld
MSMTP_HOST=mx.yourdomain.tld
MSMTP_PORT=587
MSMTP_MAILDOMAIN=yourdomain.tld
MSMTP_FROM=fail2ban@yourdomain.tld
MSMTP_USER=fail2ban@yourdomain.tld
MSMTP_PASSWORD=CHANGE_ME
MSMTP_TLS=on
MSMTP_STARTTLS=on

```

At container start, the entrypoint renders:

- `/etc/msmtprc` with your SMTP settings (logging to STDOUT by default),
- `/etc/msmtp-aliases` mapping both `root` and `default` to `F2B_DESTEMAIL`.

Fail2ban’s default mail action is `%(action_mwl)s` (mail with log excerpt).
You can change the action in a `.local` file under `data/fail2ban/jail.d/`.

## Compose files

- `docker-compose.yml` — pulls **ghcr.io/alaub81/fail2ban-dockerized:latest**
- `docker-compose.dev.yml` — builds locally from `Dockerfile-fail2ban`

Both use:

```yaml
network_mode: host
cap_add:
  - NET_ADMIN
  - NET_RAW
volumes:
  - ./data/fail2ban/fail2ban.d/:/etc/fail2ban/fail2ban.d:ro
  - ./data/fail2ban/jail.d/:/etc/fail2ban/jail.d:ro
  - data_fail2ban:/var/lib/fail2ban
  - /run/log/journal:/run/log/journal:ro
  - /var/log/journal:/var/log/journal:ro
  - /etc/machine-id:/etc/machine-id:ro
logging:
  driver: journald
  options: { tag: "fail2ban-DC" }
```

## Local test tips

- Force a ban manually:

  ```bash
  docker exec -it <container> fail2ban-client set sshd banip 203.0.113.77
  docker exec -it <container> iptables -L f2b-sshd -n --line-numbers
  ```

- Unban:

  ```bash
  docker exec -it <container> fail2ban-client set sshd unbanip 203.0.113.77
  ```

## CI/CD

- **CI**: lint (actionlint, yamllint, hadolint, shellcheck), build, **Trivy FS + Image**, and an **E2E ban test** that injects a fake sshd log entry and asserts an iptables rule.
- **Release**: Tag with `vX.Y.Z` to build multi‑arch and push to GHCR with SemVer tags and `latest`.

## Security notes

- Never commit real secrets. Prefer `MSMTP_PASSWORD_FILE` (Docker secret or mounted file).
- Consider `allowipv6 = auto` so IPv6 bans are enforced (via `ip6tables`) when IPv6 is enabled on the host.

## License & Security

- License: MIT (see `LICENSE`)
- Security Policy: see `SECURITY.md` (how to report vulnerabilities)

---

## Changelog

See Git commit history and release notes.
