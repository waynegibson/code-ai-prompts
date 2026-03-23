# Input Snapshot

Prompt source:

- `setups/setup-mikrotik-router.md` (hardened prompt)

Canonical requirements source:

- `setups/mikrotik-rb5009-golden-requirements-7.22.md`

Key inputs used for this simulation:

- Router: RB5009UG+S+IN
- RouterOS target: 7.22
- Intent: deployable artifacts requested, but still simulation-reviewed
- Deployment path: clean-start
- WAN: Vumatel ONT, untagged DHCP/IPoE on ether1
- Port model: ether1-ether7 1G, ether8 2.5G, sfp-sfpplus1 10G
- AP trunk: ether8
- Admin fallback access: ether7
- Main access switch: ether2
- Voice access switch: ether6
- VLANs: 10 Admin, 20 Main/Trusted, 30 Guest, 40 IoT/Cameras, 50 Voice
- Management access: VLAN 10 and WireGuard admin VPN only
- NAT: masquerade only
- QoS: voice and interactive priority
- Secret handling: tracked example overlay plus local overlay

Known unresolved items carried into this simulation:

- ASUS AP per-SSID VLAN support still unconfirmed
- 3CX hosting location still unconfirmed
- Remote syslog target still TBD
- Backup destination and alerting channels still TBD
- Final endpoint placement for Mac Studio / Rodecaster may still need operator preference confirmation
