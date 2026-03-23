# Input Snapshot

Prompt source:

- `setups/setup-mikrotik-router.md` (hardened prompt)

Canonical requirements source:

- `setups/mikrotik-rb5009-golden-requirements-7.22.md`

Key inputs used for this simulation:

- Router: RB5009UG+S+
- RouterOS target: 7.22
- Intent: deployable artifacts requested, simulation-reviewed
- Deployment path: clean-start
- WAN: Vumatel ONT, untagged DHCP/IPoE on ether1
- Port model: ether1-ether7 1G, ether8 2.5G, sfp-sfpplus1 10G
- AP trunk: ether8 (fallback required if AP cannot trunk)
- Admin fallback access: ether7 (VLAN 10)
- Main wired switch: ether2 (VLAN 20 access)
- Voice switch: ether6 (VLAN 50 access)
- VLANs:
  - VLAN 10 Admin
  - VLAN 20 Trusted Wired
  - VLAN 25 Trusted Wi-Fi
  - VLAN 30 Guest
  - VLAN 40 Media/IoT/Cameras
  - VLAN 50 PoE/Voice
  - VLAN 60 Backup/Storage
  - VLAN 70 Printers/Services
- Endpoint mapping highlights:
  - Mac Studio, Rodecaster Pro -> VLAN 20
  - iPads/iPhones -> VLAN 25
  - Apple TV, Google TV, cameras -> VLAN 40
  - 3CX handset -> VLAN 50
  - Backup NAS/targets -> VLAN 60
  - Epson printer (Wi-Fi only) -> VLAN 70
- Management access: VLAN 10 and WireGuard admin VPN only
- NAT: masquerade only
- QoS: voice and interactive priority
- Secret handling: tracked example overlay plus local overlay
- Ops mode: unresolved ops dependencies are caveats (not blockers)

Known unresolved items carried into this simulation:

- ASUS AP per-SSID VLAN support still unconfirmed
- Remote syslog target still TBD
- Backup destination path and alert channels still TBD
- VLAN20 allowlist of specific devices permitted to reach VLAN60 still TBD
