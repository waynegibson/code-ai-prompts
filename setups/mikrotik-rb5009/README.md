# RB5009 Clean-Start Staged Config Pack

This folder contains a staged MikroTik RouterOS deployment pack for RB5009 clean-start installs.

## Scope

- Target hardware: RB5009 class routers
- Deployment mode: clean-start (no default config)
- Topology intent:
  - `ether1` WAN (DHCP/IPoE)
  - `ether8` AP trunk (VLANs 10,20,30,40,50)
  - `ether7` admin access (VLAN 10 access)
  - `ether2` main LAN access (VLAN 20)
  - `ether6` voice access (VLAN 50)

## Files and execution order

0. `00-site-overlay.example.rsc` -> copy to `00-site-overlay.local.rsc` and fill in locally
1. `00-precheck.rsc`
2. `10-bootstrap-mgmt.rsc`
3. `20-interfaces-vlans.rsc`
4. `30-addressing-dhcp-dns.rsc`
5. `40-firewall-nat.rsc`
6. `50-wireguard.rsc`
7. `60-qos.rsc`
8. `70-logging-backup-maintenance.rsc`
9. `99-verify.rsc`

Utilities:

- `90-rollback-emergency.rsc`: rollback helper guidance
- `master-install-clean-start.rsc`: imports all stages in order

## Before you run anything

Use a local overlay instead of editing the staged base files directly:

1. Copy `00-site-overlay.example.rsc` to `00-site-overlay.local.rsc`
2. Fill in your real local values in the `.local` file only
3. Keep `.local` untracked

Base files should remain sanitized templates.

Recommended one-time checks:

- Confirm physical cabling matches intended ports.
- Confirm WAN ONT hands off DHCP/IPoE on `ether1`.
- Confirm you have out-of-band access (serial/console) in case management lockout occurs.

## Clean-start install workflow

### Option A: staged, safest

Run each stage manually and validate after each:

```routeros
/import file-name=00-site-overlay.local.rsc
/import file-name=00-precheck.rsc
/import file-name=10-bootstrap-mgmt.rsc
/import file-name=20-interfaces-vlans.rsc
/import file-name=30-addressing-dhcp-dns.rsc
/import file-name=40-firewall-nat.rsc
/import file-name=50-wireguard.rsc
/import file-name=60-qos.rsc
/import file-name=70-logging-backup-maintenance.rsc
/import file-name=99-verify.rsc
```

### Option B: master installer

Use only after creating `00-site-overlay.local.rsc` and uploading all files:

```routeros
/import file-name=master-install-clean-start.rsc
```

## Router reset and upload sequence

1. Reset to no-defaults.
2. Reconnect to the router using your preferred safe method.
3. Copy `00-site-overlay.example.rsc` to `00-site-overlay.local.rsc` and fill in local values.
4. Upload all `.rsc` files to router `Files`.
5. Run Option A staged install.
6. Run acceptance tests.
7. Save a known-good encrypted backup.

## Suggested acceptance checks

- WAN lease is bound on `ether1`.
- Admin access works on VLAN 10 via SSH and WinBox.
- DHCP works on VLANs 20/30/40/50.
- Guest VLAN cannot access private RFC1918 ranges.
- Voice endpoints register and maintain quality under load.
- WireGuard admin tunnel connects and reaches management plane.
- Logs are visible locally and on remote syslog target.

## Rollback

If a stage fails:

1. Stop and inspect output immediately.
2. Use `90-rollback-emergency.rsc` guidance.
3. If necessary, restore known-good backup.
4. Last resort: clean reset and rerun staged install.

Encrypted scheduled backups are intentionally not fully parameterized in the public base pack. Keep the real backup password and any scheduled encrypted-backup job in your private repo or local overlay.

## Production hygiene

- Never commit live secrets in this public repo.
- Keep production keys/passwords in your private infrastructure repo.
- Keep this pack as a template and publish only sanitized placeholders.

## Review Notes

This pack was adjusted to avoid two deployment risks in the original draft:

- Bootstrap management now brings up VLAN 10 correctly on `ether7` before later stages, instead of relying on an access-port path that would not have carried the VLAN interface safely.
- WireGuard rules now live in the WireGuard stage, so firewall stage imports do not fail before `wg0` exists.

There is still one important operational constraint:

- The staged files are template-oriented, not fully idempotent. Re-importing the same stage without cleanup can create duplicate objects. Use them for controlled clean-start installs, not repeated converge runs.
