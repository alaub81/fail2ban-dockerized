# Security Policy

Thank you for helping keep **fail2ban-dockerized** secure! This document explains which versions are supported and how to report vulnerabilities responsibly.

## Supported Versions

| Component / Image Tag | Support Status | Notes |
|---|---|---|
| `main` branch | ✅ Supported | Active development; receives security fixes and dependency updates. |
| Versioned container tags (e.g., `ghcr.io/alaub81/fail2ban-dockerized:v1.2.3`) | ✅ Supported | Updated for critical security issues when feasible. |
| Snapshot tags (e.g., `:main`, `:sha-<commit>`) | ⚠️ Best effort | If published, treated as pre-release builds. |
| Deprecated/archived tags | ⚠️ Best effort | No guarantees for timely patches. |

> We keep base images and dependencies up to date using **GitHub Actions**, **Dependabot/Renovate**, and **Trivy** scans (filesystem & container image). Linting includes **actionlint**, **yamllint**, **hadolint**, and **shellcheck**.

## How to Report a Vulnerability

**Preferred:** Open a private *GitHub Security Advisory* for this repository:
**Security → Advisories → Report a vulnerability**
Direct link: [https://github.com/alaub81/fail2ban-dockerized/security/advisories/new](https://github.com/alaub81/fail2ban-dockerized/security/advisories/new)

Please include:

- Affected component/file and **commit or tag** (SHA or release),
- Clear **description** and **impact**,
- **Steps to reproduce** / Proof of Concept,
- Relevant **logs**/screenshots (scrub secrets),
- Any **mitigations** or proposed fixes you may have.

If you cannot use GitHub advisories, you may open a private issue or contact the maintainer via GitHub.

### Our Response SLAs

- **Acknowledgement:** within **48 hours** (business days).
- **Triage & severity assignment:** within **5 business days**.
- **Fix or mitigation:** targeted within **30 days** for High/Critical; best effort for Medium/Low. Timelines may vary based on complexity and upstream dependencies.

We will coordinate a disclosure timeline with you and publish a security advisory once a fix or mitigation is available.

## Coordinated Disclosure

- Please **do not disclose** details publicly until a fix/mitigation is available and we have published an advisory.
- With your permission, we are happy to credit you in the release notes or advisory.

## Scope

### In scope

- This repository: `Dockerfile-fail2ban`, `docker-compose*.yml`, entrypoint scripts, example configuration under `data/fail2ban/`, CI workflows, and the published container images `ghcr.io/alaub81/fail2ban-dockerized:*`.
- Secrets handling (`.env` vs `.env.example`, Docker secrets), configuration rendering (msmtp, jail/fail2ban overrides), journald mounts, and iptables/nftables interactions initiated by the container.

### Out of scope

(Report upstream and/or submit as informative only.)

- Vulnerabilities in **upstream** software (e.g., `fail2ban`, `debian` base images, `msmtp`, `iptables`/`nftables`, Docker engine).
- Theoretical issues without a realistic exploit path in this project’s context.
- Operational concerns such as denial-of-service from extreme connection attempts or log volume (rate limiting/monitoring is a deployment matter).

## Additional Security Practices

- **Supply chain:** Image builds run in GitHub Actions with multi-stage checks (lint, build, Trivy FS & image scans). Releases are tagged and pushed to GHCR.
- **Least privilege:** The container requires `CAP_NET_ADMIN`/`CAP_NET_RAW` and `host` networking to manage bans; avoid additional capabilities or privileged mode.
- **Secrets:** Prefer file-based secrets (e.g., `MSMTP_PASSWORD_FILE` via Docker Secret). Do **not** commit real secrets—use `.env.example` as a template only.
- **Logging:** msmtp can log to STDOUT; verify that logs do not contain sensitive data before sharing.

## Safe Harbor

We support **good‑faith security research** in your own test environment:

- No access to third‑party data, no social engineering, no physical access.
- Do not intentionally disrupt production systems.
- Follow applicable laws. Report findings privately (see above).

## Cryptography / PGP (optional)

If you prefer encrypted communication, we can provide a PGP key upon request. Please mention this in your report.

---

**Thank you!** Security is a continuous effort—your responsible disclosure helps keep this project safe for everyone.
