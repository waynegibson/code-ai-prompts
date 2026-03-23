# WireGuard Quick Start (RB5009 Sample)

This is a practical sample for your environment so you can see exactly how WireGuard admin access works.

Goal:

- Keep router management locked to VLAN 10 and VPN.
- Let your Mac manage the router without moving cables.
- Keep WAN management closed except WireGuard handshake.

Assumptions for this sample:

- RouterOS target: 7.22
- RB5009 ports: ether1 WAN, ether8 AP trunk, ether7 admin access fallback
- Router management IP on VLAN 10: 192.168.10.1
- WireGuard listen port: 51820/UDP
- WireGuard VPN subnet: 10.10.10.0/24

## 1) One-time router setup (sample)

Run on the router terminal (edit placeholders first):

/interface wireguard
add name=wg0 listen-port=51820 mtu=1420 private-key="REPLACE_ROUTER_PRIVATE_KEY"

/ip address
add address=10.10.10.1/24 interface=wg0 comment="WireGuard admin subnet"

/interface wireguard peers
add interface=wg0 public-key="REPLACE_MAC_PUBLIC_KEY" allowed-address=10.10.10.2/32 comment="Mac admin"

## 2) Firewall rules for WireGuard admin access

These rules allow only the VPN entry and then management over VPN.
Place them before your final input/forward drop rules.

/ip firewall filter
add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=51820 place-before=[find where comment="Drop WAN to router"] comment="WireGuard handshake"
add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=22,8291 place-before=[find where comment="Drop all other input"] comment="Mgmt from WireGuard"

add chain=forward action=accept in-interface=wg0 out-interface-list=LAN place-before=[find where comment="Drop all other forward"] comment="WG to LAN"
add chain=forward action=accept in-interface-list=LAN out-interface=wg0 connection-state=established,related place-before=[find where comment="Drop all other forward"] comment="LAN return to WG"

## 3) Mac WireGuard client sample

Install the WireGuard app on macOS, then create a tunnel profile using this sample:

[Interface]
PrivateKey = REPLACE_MAC_PRIVATE_KEY
Address = 10.10.10.2/32
DNS = 192.168.10.1

[Peer]
PublicKey = REPLACE_ROUTER_PUBLIC_KEY
Endpoint = REPLACE_PUBLIC_IP_OR_DDNS:51820
AllowedIPs = 10.10.10.0/24, 192.168.10.0/24
PersistentKeepalive = 25

Notes:

- Endpoint can be your public WAN IP or DDNS hostname.
- AllowedIPs above gives admin-plane access only.
- You can add more LAN subnets later if needed.

## 4) iPhone WireGuard sample (same concept)

Use the same values as the Mac profile but assign a different client VPN IP, for example:

- iPhone Address: 10.10.10.3/32
- Add second router peer entry with iPhone public key and allowed-address 10.10.10.3/32

## 5) Quick verification checklist

After connecting WireGuard on Mac:

1. Ping 10.10.10.1 (router wg0 IP).
2. Ping 192.168.10.1 (router admin gateway).
3. SSH to 192.168.10.1.
4. Open WinBox to 192.168.10.1.

If step 1 works but step 2 fails:

- Check forward rule order.
- Check AllowedIPs on client profile.

If handshake fails:

- Confirm UDP 51820 rule exists and is above WAN drop.
- Confirm endpoint public IP/DDNS is correct.
- Confirm both private/public keys match peer pairs.

## 6) Recommended operating model

For daily use:

- Keep Mac on VLAN 20 for normal work traffic.
- Start WireGuard only when doing router admin tasks.
- Keep ether7 as emergency local admin fallback port on VLAN 10.

This gives you strong security with low day-to-day friction.
