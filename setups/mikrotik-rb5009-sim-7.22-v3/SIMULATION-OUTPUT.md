# MikroTik RB5009 RouterOS 7.22 Simulation v3

A. Requirements summary

Confirmed inputs:

- Platform: RB5009UG+S+
- RouterOS target: 7.22
- Deployment path: clean-start
- Intent: deployable artifacts requested
- WAN: DHCP/IPoE on ether1 from Vumatel ONT
- Trunk/access strategy:
  - ether8 trunk to AP (if supported)
  - ether7 emergency admin access on VLAN 10
  - ether2 access for trusted wired switch on VLAN 20
  - ether6 access for voice PoE switch on VLAN 50
- Security posture: hardened, deny-by-default, SSH/WinBox only from VLAN 10 and WireGuard
- Trust-zone VLAN plan:
  - VLAN 10 Admin
  - VLAN 20 Trusted Wired
  - VLAN 25 Trusted Wi-Fi
  - VLAN 30 Guest
  - VLAN 40 Media/IoT/Cameras
  - VLAN 50 PoE/Voice
  - VLAN 60 Backup/Storage
  - VLAN 70 Printers/Services

Assumptions:

- AP VLAN trunk support is uncertain; fallback is access-only AP mode with reduced SSID/VLAN segmentation.
- 3CX is cloud-hosted.
- Backup VLAN (60) exposure will use explicit allow rules only for approved VLAN20 endpoints.

Unresolved decisions and risks:

- Exact allowlist of VLAN20 devices allowed to reach VLAN60 is not finalized.
- Remote syslog endpoint is unknown.
- Backup target path and alerting destination are unknown.

B. Target architecture

Security zones and trust boundaries:

- VLAN 10: management and break-glass admin
- VLAN 20: trusted wired workstations and pro gear
- VLAN 25: trusted Wi-Fi clients, intentionally restricted from backup VLAN
- VLAN 30: guest internet-only
- VLAN 40: media and IoT/camera containment
- VLAN 50: PoE/voice services
- VLAN 60: backup/storage assets (highly restricted)
- VLAN 70: printer/services segment

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
  - bootstrap must establish VLAN10 admin access before production firewall stage
  - production firewall stage must include WireGuard insertion before terminal drops
  - VLAN60 and VLAN70 restrictions should be added before broad LAN->WAN rules

Install-safety summary:

- Bootstrap access safety: conditionally yes, if ether7 remains dedicated admin during rollout
- Stage ordering safety: acceptable for one-time controlled import
- Object dependency safety: acceptable for staged clean-start
- Rerun safety: no

C. RouterOS configuration (simulation)

Target RouterOS version: 7.22
Idempotency classification: staged clean-start only, not rerunnable without cleanup

1. Interfaces and VLANs

```routeros
/interface bridge add name=bridge1 vlan-filtering=no protocol-mode=rstp
/interface bridge port add bridge=bridge1 interface=ether7 pvid=10 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged
/interface bridge port add bridge=bridge1 interface=ether2 pvid=20 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged
/interface bridge port add bridge=bridge1 interface=ether6 pvid=50 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged
/interface bridge port add bridge=bridge1 interface=ether8 ingress-filtering=yes frame-types=admit-only-vlan-tagged
/interface vlan add name=vlan10-admin interface=bridge1 vlan-id=10
/interface vlan add name=vlan20-wired interface=bridge1 vlan-id=20
/interface vlan add name=vlan25-wifi interface=bridge1 vlan-id=25
/interface vlan add name=vlan30-guest interface=bridge1 vlan-id=30
/interface vlan add name=vlan40-iot interface=bridge1 vlan-id=40
/interface vlan add name=vlan50-voice interface=bridge1 vlan-id=50
/interface vlan add name=vlan60-backup interface=bridge1 vlan-id=60
/interface vlan add name=vlan70-services interface=bridge1 vlan-id=70
/interface bridge vlan add bridge=bridge1 vlan-ids=10 tagged=bridge1,ether8 untagged=ether7
/interface bridge vlan add bridge=bridge1 vlan-ids=20 tagged=bridge1,ether8 untagged=ether2
/interface bridge vlan add bridge=bridge1 vlan-ids=25 tagged=bridge1,ether8
/interface bridge vlan add bridge=bridge1 vlan-ids=30 tagged=bridge1,ether8
/interface bridge vlan add bridge=bridge1 vlan-ids=40 tagged=bridge1,ether8
/interface bridge vlan add bridge=bridge1 vlan-ids=50 tagged=bridge1,ether8 untagged=ether6
/interface bridge vlan add bridge=bridge1 vlan-ids=60 tagged=bridge1
/interface bridge vlan add bridge=bridge1 vlan-ids=70 tagged=bridge1,ether8
/interface bridge set [find name=bridge1] vlan-filtering=yes
```

2. Addressing and DHCP

```routeros
/ip address add address=192.168.10.1/24 interface=vlan10-admin
/ip address add address=192.168.20.1/24 interface=vlan20-wired
/ip address add address=192.168.25.1/24 interface=vlan25-wifi
/ip address add address=192.168.30.1/24 interface=vlan30-guest
/ip address add address=192.168.40.1/24 interface=vlan40-iot
/ip address add address=192.168.50.1/24 interface=vlan50-voice
/ip address add address=192.168.60.1/24 interface=vlan60-backup
/ip address add address=192.168.70.1/24 interface=vlan70-services
/ip dhcp-client add interface=ether1 use-peer-dns=no add-default-route=yes default-route-distance=1

/ip pool add name=pool-vlan10 ranges=192.168.10.10-192.168.10.99
/ip pool add name=pool-vlan20 ranges=192.168.20.10-192.168.20.199
/ip pool add name=pool-vlan25 ranges=192.168.25.10-192.168.25.199
/ip pool add name=pool-vlan30 ranges=192.168.30.10-192.168.30.199
/ip pool add name=pool-vlan40 ranges=192.168.40.10-192.168.40.199
/ip pool add name=pool-vlan50 ranges=192.168.50.10-192.168.50.49
/ip pool add name=pool-vlan60 ranges=192.168.60.10-192.168.60.49
/ip pool add name=pool-vlan70 ranges=192.168.70.10-192.168.70.49
```

3. Firewall policy highlights

```routeros
/interface list add name=WAN
/interface list add name=LAN
/interface list member add list=WAN interface=ether1
/interface list member add list=LAN interface=bridge1
/interface list member add list=LAN interface=vlan10-admin
/interface list member add list=LAN interface=vlan20-wired
/interface list member add list=LAN interface=vlan25-wifi
/interface list member add list=LAN interface=vlan30-guest
/interface list member add list=LAN interface=vlan40-iot
/interface list member add list=LAN interface=vlan50-voice
/interface list member add list=LAN interface=vlan60-backup
/interface list member add list=LAN interface=vlan70-services

/ip firewall filter remove [find]
/ip firewall filter add chain=input action=accept connection-state=established,related
/ip firewall filter add chain=input action=drop connection-state=invalid
/ip firewall filter add chain=input action=accept in-interface=vlan10-admin protocol=tcp dst-port=22,8291
/ip firewall filter add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=22,8291
/ip firewall filter add chain=input action=drop in-interface-list=WAN
/ip firewall filter add chain=input action=drop

/ip firewall filter add chain=forward action=accept connection-state=established,related
/ip firewall filter add chain=forward action=drop connection-state=invalid
/ip firewall filter add chain=forward action=accept in-interface=vlan10-admin
/ip firewall filter add chain=forward action=drop in-interface=vlan25-wifi out-interface=vlan60-backup comment="Block Wi-Fi to backup"
/ip firewall filter add chain=forward action=drop in-interface=vlan30-guest dst-address=10.0.0.0/8
/ip firewall filter add chain=forward action=drop in-interface=vlan30-guest dst-address=172.16.0.0/12
/ip firewall filter add chain=forward action=drop in-interface=vlan30-guest dst-address=192.168.0.0/16
/ip firewall filter add chain=forward action=drop in-interface=vlan40-iot out-interface=vlan10-admin
/ip firewall filter add chain=forward action=drop in-interface=vlan50-voice out-interface=vlan10-admin
/ip firewall filter add chain=forward action=drop in-interface=vlan70-services out-interface=vlan60-backup
/ip firewall filter add chain=forward action=accept in-interface=vlan20-wired out-interface=vlan60-backup src-address-list=backup-approved-wired comment="Allow only approved wired endpoints to backup"
/ip firewall filter add chain=forward action=accept in-interface-list=LAN out-interface-list=WAN
/ip firewall filter add chain=forward action=drop

/ip firewall nat add chain=srcnat action=masquerade out-interface-list=WAN
```

4. WireGuard management

```routeros
/interface wireguard add name=wg0 listen-port=51820 mtu=1420 private-key="FROM_LOCAL_OVERLAY"
/ip address add address=10.10.10.1/24 interface=wg0
/interface wireguard peers add interface=wg0 public-key="FROM_LOCAL_OVERLAY" allowed-address=10.10.10.2/32 comment="Admin endpoint"
/ip firewall filter add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=51820 place-before=[find where chain=input and action=drop]
/ip firewall filter add chain=forward action=accept in-interface=wg0 out-interface-list=LAN place-before=[find where chain=forward and action=drop]
```

5. SSID mapping (if AP trunk capable)

- MainWiFi -> VLAN 25
- GuestWiFi -> VLAN 30
- IoTWiFi -> VLAN 40
- VoiceWiFi -> VLAN 50 (optional)

Fallback (if AP not trunk capable):

- AP access-only to one VLAN (recommended VLAN 25)
- Keep guest/IoT separation on a separate AP or managed switching path

D. Validation and rollout plan

Critical acceptance checks:

- VLAN25 client cannot access VLAN60 backup host
- VLAN20 approved host can access VLAN60 backup host
- Guest VLAN30 blocked from RFC1918 ranges
- Voice VLAN50 registers to cloud 3CX and cannot access admin plane
- Management plane reachable from VLAN10 and WireGuard only

E. Post-simulation review checklist

- Confirm final `backup-approved-wired` address list entries
- Confirm AP trunk capability or choose fallback architecture explicitly
- Confirm remote syslog destination and backup upload workflow
- Lab-test RouterOS 7.22 command behavior before production import
