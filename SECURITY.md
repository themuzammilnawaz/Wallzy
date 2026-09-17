# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest (main) | ✅ |
| Older commits | ❌ |

## Reporting a Vulnerability

We take the security of Wallzy seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do NOT Open a Public Issue

Security vulnerabilities should be reported privately to prevent exploitation.

### 2. Report via GitHub Security Advisories

1. Go to the [Security tab](https://github.com/themuzammilnawaz/Wallzy/security)
2. Click **"Report a vulnerability"**
3. Fill out the form with details

### 3. Include in Your Report

- **Description** of the vulnerability
- **Steps to reproduce**
- **Potential impact**
- **Suggested fix** (if you have one)

### 4. What to Expect

| Timeframe | Action |
|-----------|--------|
| 48 hours | Acknowledgment of your report |
| 7 days | Initial assessment and severity classification |
| 30 days | Fix or mitigation plan |

### 5. Responsible Disclosure

Please do not disclose the vulnerability publicly until we've had a chance to address it.

## Scope

The following are in scope:

- `install.sh` — the installation script
- `scripts/` — all shell and Python scripts
- `index.html`, `styles.css`, `app.js` — the gallery website
- GitHub Actions workflows

The following are out of scope:

- Wallpapers themselves (content, not code)
- Third-party dependencies (report upstream)

## Security Best Practices for Users

- Always verify the `install.sh` script before piping to bash
- Use the manual install method if you prefer to review code first
- Keep your system updated
- Don't run scripts with `sudo` unless necessary

---

**Wallzy** — Curated & developed by [Muzammil Nawaz](https://github.com/themuzammilnawaz)
