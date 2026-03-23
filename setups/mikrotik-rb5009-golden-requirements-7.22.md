# RB5009 Golden Requirements Form: RouterOS 7.22

Use this as the canonical filled example for the Cape Town RB5009 home-professional deployment.

```text
Mode (Full or Fast): Full
Deployment name/site: Cape Town Home Professional
User skill level (beginner, intermediate, advanced): intermediate
Allow recommended defaults where unspecified? (yes/no): yes
Deployment path (overlay-default or clean-start): clean-start
If overlay-default, describe current baseline state (IP, users, services, routing): N/A
Is this a simulation only, or intended to produce deployable artifacts? (simulation/deployable): deployable

1) Business intent and availability
- Router role (edge, branch, datacenter, lab): edge
- Critical services (apps or systems that must stay up): work internet, Zoom, streaming, 3CX handset/app connectivity, printer access
- Uptime target (for example 99.9 or 99.99): 99.9
- Maintenance window (allowed change times): Sun 01:00-04:00

2) Hardware and software
- Router model (for example RB5009UG+S+): RB5009UG+S+
- RouterOS target version/channel (exact version preferred, for example 7.22, otherwise stable/long-term): 7.22
- Single router or HA pair (two routers for redundancy): single router
- Available port speeds (example: ether1-7 are 1 Gbps, ether8 is 2.5 Gbps, SFP1 is 10 Gbps): ether1-ether7 are 1 Gbps, ether8 is 2.5 Gbps, sfp-sfpplus1 is 10 Gbps
- Hardware constraints (SFP type, PoE needs, ports in use, storage): Vumatel ONT on ether1, ASUS AP should use ether8 2.5 Gbps, voice handset needs PoE via downstream switch, SFP reserved/do not change unless explicitly requested

3) Topology and WAN
- Backbone (wired, wireless, hybrid): hybrid
- WAN pattern (single ISP, dual ISP failover, load balancing): single ISP
- ISP handoff details (ONT untagged or tagged VLAN, DHCP/static IP/PPPoE, MAC clone required?): Vumatel ONT, untagged, DHCP/IPoE, no MAC clone
- WAN IP assignment method (DHCP/dynamic [IPoE], static, PPPoE, other): DHCP/IPoE
- Multi-site or single-site: single-site
- Estimated devices now / in 12-24 months: 15 / 25

4) Network segmentation and addressing
- VLAN list and purpose (for example mgmt, corp, guest, IoT, voice): VLAN 10 Admin, VLAN 20 Main Wi-Fi and trusted user devices, VLAN 30 Guest, VLAN 40 IoT/Cameras, VLAN 50 Voice
- Gateway IP per VLAN (for example VLAN 10 -> 192.168.10.1/24): VLAN10->192.168.10.1/24, VLAN20->192.168.20.1/24, VLAN30->192.168.30.1/24, VLAN40->192.168.40.1/24, VLAN50->192.168.50.1/24
- DHCP scope per VLAN (start/end or subnet): VLAN10 .10-.99, VLAN20 .10-.199, VLAN30 .10-.199, VLAN40 .10-.199, VLAN50 .10-.49
- IPv4 subnets per VLAN/site: as above
- IPv6 needed? (yes/no + prefix delegation or static if known): no
- Inter-VLAN policy (what can talk to what): VLAN10 can access all; VLAN20 internet plus approved local services; VLAN30 internet only; VLAN40 internet only plus required camera services; VLAN50 internet plus 3CX services only

5) Routing
- Routing type (static, OSPF, BGP): static
- If OSPF/BGP, peers and policy notes: N/A

6) Security and compliance
- Security posture (baseline, hardened, regulated): hardened
- Compliance standard (PCI-DSS, SOC2, ISO 27001, internal): internal best practice
- Management access allowed from (IP ranges, VLAN, VPN only): VLAN10 and WireGuard admin VPN only
- Management protocols allowed (SSH, WinBox, API): SSH and WinBox only
- Threat protections needed (brute-force, scan blocking, DDoS controls): brute-force protection, scan blocking, deny-by-default WAN posture

7) Edge services
- NAT needs (masquerade, static NAT, inbound port forwards): masquerade only, no inbound port forwards
- VPN needs (WireGuard, IPsec, OpenVPN, site-to-site, remote users): WireGuard for admin remote access
- QoS needs (voice/video priority, critical app shaping): prioritize 3CX voice and Zoom/interactive traffic
- DHCP/DNS/NTP hosted on router or external systems: DHCP and DNS cache on router, NTP client to upstream sources
- Guest controls (client isolation, bandwidth cap, captive portal yes/no): client isolation yes, bandwidth cap optional/TBD, captive portal no

8) AP and trunk mapping
- Which router port is VLAN trunk to AP/switch (for example ether5): ether8
- Trunk native VLAN (untagged VLAN on trunk, if any): none preferred; all-tagged preferred if AP supports it
- SSID to VLAN mapping (for example HomeWiFi->20, GuestWiFi->30): MainWiFi->20, GuestWiFi->30, IoTWiFi->40, VoiceWiFi->50 only if AP supports per-SSID VLANs

9) Downstream device port mapping
- Any non-managed downstream devices connected directly to the router? (yes/no): yes
- If yes only:
  - Device name/type (for example Tenda VoIP router): Tenda SG108 unmanaged switch
  - Which router port will it use (for example ether6): ether2
  - Port mode required (access/untagged only, not trunk): access/untagged
  - VLAN for that port: VLAN 20
  - Should the device be isolated from other internal VLANs? (yes/no): no, follows VLAN 20 policy
  - Is downstream NAT allowed on that device? (yes/no): no
- Additional unmanaged device:
  - Device name/type: Tenda PoE switch
  - Which router port will it use: ether6
  - Port mode required: access/untagged
  - VLAN for that port: VLAN 50
  - Should the device be isolated from other internal VLANs? (yes/no): yes, voice-only access path
  - Is downstream NAT allowed on that device? (yes/no): no

10) Observability and operations
- Log destination (local, syslog, SIEM): local plus remote syslog
- Monitoring (SNMP, NetFlow/IPFIX, other): SNMP optional, no NetFlow required initially
- Backup policy (schedule, encryption, backup target): encrypted backup from private repo process, remote target TBD
- Alert channels (email, chat, NOC tooling): TBD
- Change control requirements (approvals, phased rollout): staged rollout with manual validation after each stage

11) Failure behavior and acceptance tests
- Required behavior if AP/trunk fails: wired admin access on ether7 must remain available; wireless clients fail without affecting router management
- Required behavior if WAN fails (single/dual WAN): internal VLAN services remain routed locally; internet unavailable; management from VLAN10 remains available
- Acceptance tests to pass (internet, DNS, VLAN isolation, guest isolation, VPN): WAN DHCP bound, DNS resolution works, guest blocked from RFC1918, admin reachable via VLAN10 and WireGuard, voice handset registers, printer reachable from approved VLAN only

12) Output preferences
- Output style (single script, modular blocks, heavily commented): modular blocks with concise comments
- Script safety target (one-time only, staged rerunnable if possible, explicitly idempotent if achievable): staged clean-start, one-time install; do not overstate idempotency
- Secret handling style (inline placeholders, tracked example overlay + local overlay, private repo only): tracked example overlay plus local overlay, private repo for real values
- Include lab version first? (yes/no): yes
- Include migration plan from existing config? (yes/no): no
- Any strict do-not-change constraints: do not alter SFP config by default; do not expose management on WAN; do not assume AP supports VLAN tagging without confirmation
```

## Known Remaining Gaps Even In This Golden Form

- ASUS AP VLAN capability still needs real-world confirmation
- 3CX hosting location should be confirmed explicitly
- Remote syslog target IP/hostname is still TBD
- Backup destination and alerting channels are still TBD
- This form is strong enough for version-targeted design on RouterOS 7.22, but final deployable artifacts still require command review against the exact 7.22 behavior used in production
