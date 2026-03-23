# Private Repo Migration Checklist

Use this checklist to move deployable RouterOS config assets from this public repo into a private infrastructure repo safely.

## Goal

- Keep public repo for prompt templates and sanitized examples.
- Keep live deployable scripts, environment overlays, and operational history in a private repo.
- Prevent secrets from ever entering public Git history.

## Recommended private repo structure

```text
network-configs-private/
  README.md
  docs/
    runbooks/
      rb5009-clean-start.md
      rollback-playbook.md
  sites/
    cape-town/
      rb5009/
        staged/
          00-site-overlay.example.rsc
          00-precheck.rsc
          10-bootstrap-mgmt.rsc
          20-interfaces-vlans.rsc
          30-addressing-dhcp-dns.rsc
          40-firewall-nat.rsc
          50-wireguard.rsc
          60-qos.rsc
          70-logging-backup-maintenance.rsc
          90-rollback-emergency.rsc
          99-verify.rsc
          master-install-clean-start.rsc
        overlays/
          prod.local.rsc
          lab.local.rsc
        secrets/
          .gitkeep
        backups/
          .gitkeep
        exports/
          .gitkeep
        README.md
```

## What to move now

From this repo path:

- `setups/mikrotik-rb5009/00-site-overlay.example.rsc`
- `setups/mikrotik-rb5009/*.rsc`
- `setups/mikrotik-rb5009/README.md`
- `setups/mikrotik-rb5009/OPS-CHEATSHEET.md`

Do not move public prompt docs unless required.

## Secret handling rules (mandatory)

1. Keep placeholders in tracked `.rsc` files.
2. Put real values only in local overlays or secret management tooling.
3. Never commit:

- real admin passwords
- WireGuard private keys
- backup passwords
- live syslog credentials or tokens

Suggested private repo `.gitignore` baseline:

```gitignore
# local overlays and secrets
*.local.rsc
*.secrets.rsc

# RouterOS artifacts
*.backup
*.auto.rsc
*.npk

# generated exports/backups
sites/*/*/rb5009/backups/*
sites/*/*/rb5009/exports/*
!sites/*/*/rb5009/backups/.gitkeep
!sites/*/*/rb5009/exports/.gitkeep
```

## Cutover checklist

1. Create private repository.
2. Copy staged pack into private repo structure.
3. Add private repo `.gitignore` and commit placeholders only.
4. Create `prod.local.rsc` with real environment values on a secure workstation.
5. Test full staged install in lab or maintenance window.
6. Run validation and rollback drills.
7. Tag first known-good release (for example `rb5009-cpt-v1.0.0`).
8. Keep only sanitized examples in public repo.

## Minimal overlay example

Create `staged/00-site-overlay.local.rsc` or `overlays/prod.local.rsc` (untracked, choose one convention and keep it consistent):

```routeros
# Untracked production overlay - do not commit
:global CFG_SITE_NAME "RB5009-Cape-Town"
:global CFG_ADMIN_PASSWORD "REAL_STRONG_PASSWORD"
:global CFG_WG_PRIVATE_KEY "REAL_WG_PRIVATE_KEY"
:global CFG_WG_ADMIN_PUBLIC_KEY "REAL_CLIENT_PUBLIC_KEY"
:global CFG_SYSLOG_REMOTE "192.168.10.50"
```

Apply after base pack import:

```routeros
/import file-name=00-site-overlay.local.rsc
```

For encrypted scheduled backups, keep the actual backup script and password in the private repo only.

## Versioning guidance

- Keep semantic tags per site and router profile:
  - `rb5009-cpt-v1.0.0`
  - `rb5009-cpt-v1.1.0`
- Require PR review for firewall, NAT, VPN, and management-plane changes.
- Keep change notes with timestamp, reason, and rollback outcome.

## Final public-repo hygiene check

Before pushing public changes:

1. Search for real secrets:

```bash
rg -n "password=|private-key=|public-key=|token=|secret=" setups/mikrotik-rb5009
```

2. Ensure only placeholders remain.
3. Ensure no `.local.rsc`, `.secrets.rsc`, `.backup` files are tracked.
