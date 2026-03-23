# RB5009 Clean-Start Staged Config Pack

This folder contains a staged MikroTik RouterOS deployment pack for RB5009 clean-start installs.

## Scope

- Target hardware: RB5009 class routers
- Deployment mode: clean-start (no default config)
- Topology intent:
  - `ether1` WAN (DHCP/IPoE)
  - `ether8` AP trunk (VLANs 10,20,30,40,50)
  - `ether9` admin access (VLAN 10 access)
  - `ether2` main LAN access (VLAN 20)
  - `ether10` voice access (VLAN 50)

## Files and execution order

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

Replace all placeholder values first:

- `CHANGE_ME_STRONG_PASSWORD` in `10-bootstrap-mgmt.rsc`
- `CHANGE_ME_WG_PRIVATE_KEY` in `50-wireguard.rsc`
- `CHANGE_ME_ADMIN_CLIENT_PUBLIC_KEY` in `50-wireguard.rsc`
- `CHANGE_ME_BACKUP_PASSWORD` in `70-logging-backup-maintenance.rsc`
- `192.168.10.50` syslog target in `70-logging-backup-maintenance.rsc`

Recommended one-time checks:

- Confirm physical cabling matches intended ports.
- Confirm WAN ONT hands off DHCP/IPoE on `ether1`.
- Confirm you have out-of-band access (serial/console) in case management lockout occurs.

## Clean-start install workflow

### Option A: staged, safest

Run each stage manually and validate after each:

```routeros
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

Use only after placeholder replacement and file upload validation:

```routeros
/import file-name=master-install-clean-start.rsc
```

## Router reset and upload sequence

1. Reset to no-defaults.
2. Reconnect to the router using your preferred safe method.
3. Upload all `.rsc` files to router `Files`.
4. Run Option A staged install.
5. Run acceptance tests.
6. Save a known-good encrypted backup.

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

## Production hygiene

- Never commit live secrets in this public repo.
- Keep production keys/passwords in your private infrastructure repo.
- Keep this pack as a template and publish only sanitized placeholders.
