# MikroTik RB5009 RouterOS 7.22 Simulation v2

A. Requirements summary

Confirmed inputs:

- Platform: RB5009UG+S+IN
- RouterOS target: 7.22
- Deployment path: clean-start
- Intent: deployable artifacts requested
- WAN: DHCP/IPoE on ether1 from Vumatel ONT
- Port speeds: ether1-ether7 are 1G, ether8 is 2.5G, sfp-sfpplus1 is 10G
- Trunk/access strategy:
  - ether8 trunk to ASUS AP
  - ether7 emergency admin access
  - ether2 access for main unmanaged switch on VLAN 20
  - ether6 access for voice unmanaged PoE switch on VLAN 50
- Security posture: hardened, deny by default, SSH/WinBox only from VLAN 10 and WireGuard
- VLAN plan:
  - VLAN 10 Admin
  - VLAN 20 Main/Trusted
  - VLAN 30 Guest
  - VLAN 40 IoT/Cameras
  - VLAN 50 Voice

Assumptions:

- Mac Studio and Rodecaster Pro should remain on VLAN 20 for normal day-to-day use, with router administration performed via WireGuard or emergency local admin access on ether7.
- ASUS AP may require a fallback design if per-SSID VLAN tagging is unavailable.
- 3CX is assumed cloud-hosted for now.

Unresolved decisions and risks:

- ASUS per-SSID VLAN support not yet confirmed.
- 3CX hosting location not explicitly confirmed.
- Remote syslog target is still unknown.
- Backup destination and alert channels are still unknown.
- Printer placement remains functionally trusted but could later move to a dedicated services VLAN if desired.

Selected deployment path and baseline-state assumptions:

- Clean-start only.
- No inherited defaults relied on.
- Staged import is intended for one-time bootstrap and validation, not repeated reconciliation.

A1. Defaults register

- Clean-start deployment: chosen to eliminate inherited config ambiguity.
- Deny-by-default inter-VLAN posture: chosen for containment.
- WireGuard for admin access: chosen to avoid broad management exposure.
- Overlay-based secret handling: chosen so base scripts remain safe for shared/public storage.
- No inbound port forwards: chosen to reduce exposed attack surface.

B. Target architecture

Interface and VLAN model:

- ether1: WAN
- ether2: VLAN 20 access to Tenda SG108
- ether6: VLAN 50 access to Tenda PoE switch
- ether7: VLAN 10 emergency admin access
- ether8: VLAN trunk to ASUS AP
- sfp-sfpplus1: reserved

WAN/routing strategy:

- Single WAN, DHCP-learned default route.
- Static inter-VLAN routing on the RB5009.

Security zones and trust boundaries:

- VLAN 10: highest trust, management and admin recovery
- VLAN 20: trusted user devices and normal daily use
- VLAN 30: guest internet only
- VLAN 40: low-trust IoT/cameras
- VLAN 50: voice-only access path

Management plane design:

- Router management reachable only from VLAN 10 and WireGuard.
- Mac Studio can stay on VLAN 20 and use WireGuard when admin access is needed.

B1. Compatibility and install-safety status

- Exact RouterOS target version or channel-only limitation:
  - exact target version specified: RouterOS 7.22
- Exact-version status:
  - exact-version targeted, not runtime-validated in this simulation environment
- Whether output is simulation-only or deployable:
  - deployable candidate pending operator validation
- Idempotency classification:
  - staged clean-start only; not idempotent
- Stage ordering and dependency notes:
  - bootstrap must establish VLAN 10 access before later firewall/VLAN stages
  - firewall replacement stage must remove bootstrap-safe filter set before production filter set is applied
  - WireGuard rules must be inserted before final drop rules
- Secret-handling model used for script artifacts:
  - tracked example overlay plus untracked local overlay/private repo values

Install-safety summary:

- Bootstrap access safety: conditionally yes, if ether7 is used as dedicated admin access during bootstrap
- Stage ordering safety: improved, but still requires controlled one-time execution
- Object dependency safety: acceptable for staged clean-start only
- Rerun safety: no

C. RouterOS configuration

Target RouterOS version: 7.22
Idempotency classification: staged clean-start only, not rerunnable without cleanup

1. System baseline and identity

```routeros
/system identity set name="RB5009-Cape-Town"
/system clock set time-zone-name=Africa/Johannesburg
/ip service set telnet disabled=yes
/ip service set ftp disabled=yes
/ip service set www disabled=yes
/ip service set www-ssl disabled=yes
/ip service set api disabled=yes
/ip service set api-ssl disabled=yes
/ip service set ssh disabled=no port=22
/ip service set winbox disabled=no port=8291
/ip ssh set strong-crypto=yes
```

2. Interfaces, bridge, VLANs

```routeros
/interface bridge add name=bridge1 vlan-filtering=no protocol-mode=rstp
/interface bridge port add bridge=bridge1 interface=ether7 pvid=10 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged
/interface bridge port add bridge=bridge1 interface=ether2 pvid=20 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged
/interface bridge port add bridge=bridge1 interface=ether6 pvid=50 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged
/interface bridge port add bridge=bridge1 interface=ether8 ingress-filtering=yes frame-types=admit-only-vlan-tagged
/interface vlan add name=vlan10-admin interface=bridge1 vlan-id=10
/interface vlan add name=vlan20-main interface=bridge1 vlan-id=20
/interface vlan add name=vlan30-guest interface=bridge1 vlan-id=30
/interface vlan add name=vlan40-iot interface=bridge1 vlan-id=40
/interface vlan add name=vlan50-voice interface=bridge1 vlan-id=50
/interface bridge vlan add bridge=bridge1 vlan-ids=10 tagged=bridge1,ether8 untagged=ether7
/interface bridge vlan add bridge=bridge1 vlan-ids=20 tagged=bridge1,ether8 untagged=ether2
/interface bridge vlan add bridge=bridge1 vlan-ids=30 tagged=bridge1,ether8
/interface bridge vlan add bridge=bridge1 vlan-ids=40 tagged=bridge1,ether8
/interface bridge vlan add bridge=bridge1 vlan-ids=50 tagged=bridge1,ether8 untagged=ether6
/interface bridge set [find name=bridge1] vlan-filtering=yes
```

3. IP addressing and routing

```routeros
/ip address add address=192.168.10.1/24 interface=vlan10-admin
/ip address add address=192.168.20.1/24 interface=vlan20-main
/ip address add address=192.168.30.1/24 interface=vlan30-guest
/ip address add address=192.168.40.1/24 interface=vlan40-iot
/ip address add address=192.168.50.1/24 interface=vlan50-voice
/ip dhcp-client add interface=ether1 use-peer-dns=no add-default-route=yes default-route-distance=1
```

4. DHCP/DNS/NTP

```routeros
/ip pool add name=pool-vlan10 ranges=192.168.10.10-192.168.10.99
/ip pool add name=pool-vlan20 ranges=192.168.20.10-192.168.20.199
/ip pool add name=pool-vlan30 ranges=192.168.30.10-192.168.30.199
/ip pool add name=pool-vlan40 ranges=192.168.40.10-192.168.40.199
/ip pool add name=pool-vlan50 ranges=192.168.50.10-192.168.50.49
/ip dhcp-server add name=dhcp-vlan10 interface=vlan10-admin address-pool=pool-vlan10 disabled=no
/ip dhcp-server add name=dhcp-vlan20 interface=vlan20-main address-pool=pool-vlan20 disabled=no
/ip dhcp-server add name=dhcp-vlan30 interface=vlan30-guest address-pool=pool-vlan30 disabled=no
/ip dhcp-server add name=dhcp-vlan40 interface=vlan40-iot address-pool=pool-vlan40 disabled=no
/ip dhcp-server add name=dhcp-vlan50 interface=vlan50-voice address-pool=pool-vlan50 disabled=no
/ip dns set allow-remote-requests=yes servers=1.1.1.1,9.9.9.9
/system ntp client set enabled=yes
```

5. Firewall filter rules

```routeros
/interface list add name=WAN
/interface list add name=LAN
/interface list member add list=WAN interface=ether1
/interface list member add list=LAN interface=bridge1
/interface list member add list=LAN interface=vlan10-admin
/interface list member add list=LAN interface=vlan20-main
/interface list member add list=LAN interface=vlan30-guest
/interface list member add list=LAN interface=vlan40-iot
/interface list member add list=LAN interface=vlan50-voice
/ip firewall filter remove [find]
/ip firewall filter add chain=input action=accept connection-state=established,related comment="Input established/related"
/ip firewall filter add chain=input action=drop connection-state=invalid comment="Input invalid"
/ip firewall filter add chain=input action=accept protocol=icmp limit=10,20:packet comment="Input ICMP"
/ip firewall filter add chain=input action=accept in-interface=vlan10-admin protocol=tcp dst-port=22,8291 comment="Mgmt from admin VLAN"
/ip firewall filter add chain=input action=accept in-interface-list=LAN protocol=udp dst-port=53,67,68,123 comment="LAN service traffic"
/ip firewall filter add chain=input action=drop in-interface-list=WAN comment="Drop WAN to router"
/ip firewall filter add chain=input action=drop comment="Drop all other input"
/ip firewall filter add chain=forward action=accept connection-state=established,related comment="Forward established/related"
/ip firewall filter add chain=forward action=drop connection-state=invalid comment="Forward invalid"
/ip firewall filter add chain=forward action=accept in-interface=vlan10-admin comment="Admin can reach all"
/ip firewall filter add chain=forward action=drop in-interface=vlan30-guest dst-address=10.0.0.0/8 comment="Guest block RFC1918 part1"
/ip firewall filter add chain=forward action=drop in-interface=vlan30-guest dst-address=172.16.0.0/12 comment="Guest block RFC1918 part2"
/ip firewall filter add chain=forward action=drop in-interface=vlan30-guest dst-address=192.168.0.0/16 comment="Guest block RFC1918 part3"
/ip firewall filter add chain=forward action=drop in-interface=vlan40-iot out-interface=vlan10-admin comment="IoT blocked to admin"
/ip firewall filter add chain=forward action=drop in-interface=vlan50-voice out-interface=vlan10-admin comment="Voice blocked to admin"
/ip firewall filter add chain=forward action=accept in-interface-list=LAN out-interface-list=WAN comment="LAN to internet"
/ip firewall filter add chain=forward action=drop comment="Drop all other forward"
```

6. NAT and optional mangle

```routeros
/ip firewall nat add chain=srcnat action=masquerade out-interface-list=WAN comment="Masquerade LAN to WAN"
/ip firewall mangle add chain=forward action=mark-packet new-packet-mark=voice passthrough=no protocol=udp dst-port=5060,5061,10000-20000 comment="Voice"
/ip firewall mangle add chain=forward action=mark-packet new-packet-mark=interactive passthrough=no protocol=tcp dst-port=22,443,8291 comment="Interactive"
/ip firewall mangle add chain=forward action=mark-packet new-packet-mark=bulk packet-mark=no-mark passthrough=no out-interface=ether1 comment="Bulk default"
```

7. VPN

```routeros
/interface wireguard add name=wg0 listen-port=51820 mtu=1420 private-key="FROM_LOCAL_OVERLAY"
/ip address add address=10.10.10.1/24 interface=wg0
/interface wireguard peers add interface=wg0 public-key="FROM_LOCAL_OVERLAY" allowed-address=10.10.10.2/32 comment="Mac admin"
/ip firewall filter add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=51820 place-before=[find where comment="Drop WAN to router"] comment="WireGuard handshake"
/ip firewall filter add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=22,8291 place-before=[find where comment="Drop all other input"] comment="Mgmt from WireGuard"
/ip firewall filter add chain=forward action=accept in-interface=wg0 out-interface-list=LAN place-before=[find where comment="Drop all other forward"] comment="WG to LAN"
/ip firewall filter add chain=forward action=accept in-interface-list=LAN out-interface=wg0 connection-state=established,related place-before=[find where comment="Drop all other forward"] comment="LAN return to WG"
```

8. QoS/queues

```routeros
/queue type add name=pcq-upload kind=pcq pcq-classifier=src-address
/queue tree add name=wan-root parent=ether1 max-limit=950M
/queue tree add name=voice parent=wan-root packet-mark=voice priority=1 limit-at=150M max-limit=300M queue=pcq-upload
/queue tree add name=interactive parent=wan-root packet-mark=interactive priority=2 limit-at=200M max-limit=450M queue=pcq-upload
/queue tree add name=bulk parent=wan-root packet-mark=bulk priority=8 limit-at=50M max-limit=900M queue=pcq-upload
```

9. Management access controls

```routeros
# Router management should be reachable only from vlan10-admin and wg0
# Daily admin workflow for a Mac on VLAN 20: connect WireGuard first, then use SSH/WinBox
```

10. Logging, monitoring, and backups

```routeros
/system logging add topics=system action=memory
/system logging add topics=firewall action=memory
# Remote syslog and encrypted scheduled backups remain private-overlay/private-repo items until target details are confirmed
```

11. Scheduled maintenance tasks

```routeros
/system script add name=weekly-export source={ /export file="rb5009-weekly-export" }
/system scheduler add name=run-weekly-export interval=7d start-time=03:00:00 on-event=weekly-export
```

Path-specific deliverables:

- Clean-start pre-reset checklist required
- Bootstrap script required
- Full staged install required
- Tracked example overlay plus local-overlay instructions required

D. Validation and rollout plan

Pre-change checks:

- Confirm exact cabling on ether1, ether2, ether6, ether7, ether8.
- Confirm local admin access path on ether7 before firewall replacement stage.
- Confirm local overlay contains real keys/passwords outside tracked files.

Deployment order:

- 00 overlay
- 00 precheck
- 10 bootstrap
- 20 VLANs/interfaces
- 30 addressing/DHCP/DNS
- 40 firewall/NAT
- 50 WireGuard
- 60 QoS
- 70 logging/ops
- 99 verify

Post-change verification commands and expected results:

- `/ip dhcp-client print` -> WAN lease bound on ether1
- `/interface bridge vlan print` -> expected VLAN membership on ether2, ether6, ether7, ether8
- `/ip firewall filter print stats` -> guest drop rules show hits when tested
- WireGuard handshake successful and SSH/WinBox reachable over VPN

Acceptance test matrix:

- internet from VLAN 20: pass required
- guest isolation from RFC1918: pass required
- admin access from ether7 VLAN 10: pass required
- admin access from WireGuard on Mac: pass required
- voice handset registration on VLAN 50: pass required

Rollback procedure and trigger criteria:

- If bootstrap management breaks, stop and recover via local admin port/console
- If firewall stage blocks required access, disable terminal drop or restore known-good backup
- If staged import fails due to object ordering, stop and correct before continuing

E. Operations runbook

Routine maintenance checklist:

- Review logs weekly
- Export config weekly
- Review WireGuard peer status after changes
- Revalidate guest and admin isolation after rule changes

Backup/restore drill steps:

- Store encrypted backup process in private repo only
- Test restore in lab/spare environment before treating as production-grade

Incident triage quick-start:

- If admin access from VLAN 20 is needed, connect WireGuard first
- If WireGuard fails, use ether7 emergency admin access
- If voice fails, verify VLAN 50 access path on ether6 and upstream 3CX reachability

Capacity and policy review cadence:

- Quarterly review of endpoint placement and whether Mac/Rodecaster should remain in VLAN 20 or move to a stricter trusted wired zone

F. Post-simulation review checklist

Treat result as:

- deployable candidate pending operator validation

Remaining unknowns that materially affect design or safety:

- ASUS per-SSID VLAN capability
- exact 3CX hosting model
- remote syslog endpoint
- backup destination and alerting channels
- final preferred placement of Mac Studio and Rodecaster Pro

`.rsc` install risks still not proven safe:

- no runtime import test against RouterOS 7.22 was performed here
- repeated imports will still create duplicate objects or ordering side effects
- production firewall behavior still needs live packet-path validation

Version-specific items still needing RouterOS review:

- exact 7.22 behavior for any stage replacement pattern
- queue and mangle interaction under real traffic load
- WireGuard rule insertion behavior in the final filter order on live hardware

Device-capability assumptions requiring real confirmation:

- ASUS AP VLAN tagging support in intended AP mode
- 3CX handset provisioning specifics on the chosen voice network

Secrets/local values that must stay out of tracked base scripts:

- admin password
- WireGuard private/public key pair details
- backup encryption secrets
- remote syslog target if operationally sensitive

Next action list:

1. Confirm Mac/Rodecaster placement preference (strict admin vs normal trusted user VLAN)
2. Confirm ASUS VLAN capability
3. Confirm 3CX hosting model
4. Fill local overlay with actual keys/passwords in private storage
5. Lab-import staged scripts on RouterOS 7.22 hardware or CHR before treating as final
