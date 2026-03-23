# RB5009 Simulation v3 Review RSC Pack

This folder is a review-only staged `.rsc` artifact set derived from simulation v3.

Target RouterOS version: 7.22
Idempotency classification: staged clean-start only (non-rerunnable without cleanup)

Source model:

- `../SIMULATION-OUTPUT.md`
- trust-zone VLANs: 10,20,25,30,40,50,60,70

## Files

- `00-site-overlay.example.rsc`
- `00-precheck.rsc`
- `10-bootstrap-mgmt.rsc`
- `20-interfaces-vlans.rsc`
- `30-addressing-dhcp-dns.rsc`
- `40-firewall-nat.rsc`
- `50-wireguard.rsc`
- `60-qos.rsc`
- `70-logging-backup-maintenance.rsc`
- `90-rollback-emergency.rsc`
- `99-verify.rsc`
- `master-install-clean-start.rsc`

## Important review notes

- This pack is for staged clean-start import review and lab validation.
- It is not idempotent and is not intended for repeated converge imports.
- The `backup-approved-wired` address-list is intentionally empty by default.
- The `services-approved-wired` and `services-approved-wifi` address-lists are intentionally empty by default.
- Add explicit approved VLAN20 endpoint IPs before production rollout.
- AP trunk capability still determines whether VLAN 25/30/40/50/70 can be carried to Wi-Fi.

## Required pre-production inputs

Before production import, define allowlists in Stage 40 after import or in a local post-stage snippet.

Example commands:

```routeros
/ip firewall address-list add list=backup-approved-wired address=192.168.20.10 comment="Mac Studio"
/ip firewall address-list add list=services-approved-wired address=192.168.20.10 comment="Mac Studio to printer"
/ip firewall address-list add list=services-approved-wifi address=192.168.25.50 comment="Approved iPad/iPhone"
```

Also complete these ops inputs before production cutover:

- Set `cfgSyslogRemote` to your real syslog destination.
- Add private encrypted backup automation via a private/local script named `private-encrypted-backup`.
- Confirm scheduler times align with maintenance windows.

## Cutover Run Notes (Lessons Learned)

These notes were captured during a live bring-up and should be treated as required operator practice.

### 1) Upload prerequisites before import

- Upload all referenced `.rsc` files to router `Files` before running a master installer.
- If `master-install-stage1-wan-bringup.rsc` reports missing files, confirm exact filenames first.

### 2) Overlay must import first

- Test overlay syntax explicitly before master import:

```routeros
/import file-name=00-site-overlay.local.rsc
```

- Current overlay variable names are:
  - `cfgSiteName`
  - `cfgAdminPassword`
  - `cfgWgPrivateKey`
  - `cfgWgAdminPublicKey`
  - `cfgSyslogRemote`

### 3) Stage 1 bring-up sequence

- Recommended command:

```routeros
/import file-name=master-install-stage1-wan-bringup.rsc
```

- This brings up management, VLAN baseline, WAN DHCP, firewall/NAT, and stage-1 verification.

### 4) If a stage partially applied, do not blindly rerun all stages

- Errors like `device already added as bridge port` or `already have such address` mean that stage already applied.
- Continue from the next unapplied stage after validating current state.

### 5) Stage 1 success checks

- Run:

```routeros
/import file-name=98-stage1-wan-verify.rsc
```

- Success criteria:
  - WAN DHCP on `ether1` is `bound`
  - default route exists
  - ping `1.1.1.1` succeeds
  - DNS resolve succeeds
  - `vlan10-admin` present at `192.168.10.1/24`

### 6) Service hardening to retain

- Keep `reverse-proxy` disabled:

```routeros
/ip service set [find name=reverse-proxy] disabled=yes
```

- Restrict management services to admin VLAN:

```routeros
/ip service set [find where name="ssh" and dynamic=no] address=192.168.10.0/24
/ip service set [find where name="winbox" and dynamic=no] address=192.168.10.0/24
```

### 7) L2 discovery/MAC access behavior

- Firewall rules do not replace these controls; they are separate L2 settings.
- For secure steady state:

```routeros
/tool mac-server set allowed-interface-list=none
/tool mac-server mac-winbox set allowed-interface-list=none
/ip neighbor discovery-settings set discover-interface-list=none
```

- During setup only (temporary): you may set these to `all`, then revert to `none`.

### 8) Stage 2 timing

- Do not run Stage 2 WireGuard import until real WG keys are set in overlay.
- If keys are placeholders, run only non-WG stages first (`60`, `70`, `99`) and return to `50` later.

### 9) Useful operator commands

```routeros
/ip service print where dynamic=no
/ip address print where interface=vlan10-admin
/interface bridge port print where interface=ether7
/interface bridge vlan print where vlan-ids=10
```

Logout from RouterOS CLI over SSH:

```routeros
/quit
```
