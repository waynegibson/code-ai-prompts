# RB5009 Ops Cheat Sheet

Quick command reference for clean-start deployment and recovery.

## 1) First-Time Install (Staged, Recommended)

Prerequisites:

- All .rsc files uploaded to router Files.
- `00-site-overlay.local.rsc` created from `00-site-overlay.example.rsc` and filled in.
- You have console or known-safe management access.

Run in this exact order:

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

Optional one-shot (after staged testing confidence):

```routeros
/import file-name=master-install-clean-start.rsc
```

## 2) Post-Install Validation (Copy/Paste)

Core health and topology:

```routeros
/interface print
/interface bridge port print
/interface bridge vlan print
/interface vlan print
/ip address print
/ip route print
/ip dhcp-client print
```

DHCP/DNS services:

```routeros
/ip dhcp-server print
/ip dhcp-server lease print
/ip dns print
```

Security and NAT:

```routeros
/ip firewall filter print stats
/ip firewall nat print stats
```

VPN and QoS:

```routeros
/interface wireguard print detail
/interface wireguard peers print detail
/queue tree print stats
```

System/logs:

```routeros
/system resource print
/log print where topics~"critical|error|warning"
```

Pass criteria (minimum):

- WAN DHCP bound on ether1.
- Admin access works from VLAN 10 over SSH/WinBox.
- DHCP leases issued on VLAN 20/30/40/50.
- Guest VLAN blocked from private RFC1918 ranges.
- WireGuard admin tunnel connects successfully.

## 3) Disaster Recovery Sequence

### A. Soft rollback (preferred)

1. Stop at failed stage.
2. Inspect rule counters and logs.
3. Disable only offending rule(s), then retest.

Helpful commands:

```routeros
/ip firewall filter print stats
/ip firewall filter disable [find where comment~"Drop all other"]
/log print where topics~"error|warning|critical"
```

### B. Restore known-good backup

```routeros
/file print
/system backup load name=rb5009-known-good.backup password="REPLACE_ME"
```

### C. Last resort clean reset (destructive)

```routeros
/system reset-configuration no-defaults=yes skip-backup=yes
```

After reset:

1. Re-upload staged scripts.
2. Run install sequence from Section 1.
3. Re-run validation sequence from Section 2.

## 4) Suggested Operational Habit

After every successful production change:

1. Run validation commands.
2. Save encrypted backup.
3. Export text config.
4. Record date and change reason in your private infra repo.
