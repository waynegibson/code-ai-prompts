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
