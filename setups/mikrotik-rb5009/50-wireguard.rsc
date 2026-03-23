# Stage 50 - WireGuard admin VPN
# Replace placeholders before use

/interface wireguard
add name=wg0 listen-port=51820 mtu=1420 private-key="CHANGE_ME_WG_PRIVATE_KEY"

/ip address
add address=10.10.10.1/24 interface=wg0 comment="WireGuard admin subnet"

/interface wireguard peers
add interface=wg0 public-key="CHANGE_ME_ADMIN_CLIENT_PUBLIC_KEY" allowed-address=10.10.10.2/32 comment="Admin laptop"

# Optional: if you want full access from WG admin subnet
/ip firewall filter
add chain=forward action=accept in-interface=wg0 out-interface-list=LAN comment="WG to LAN"
add chain=forward action=accept in-interface-list=LAN out-interface=wg0 connection-state=established,related comment="LAN return to WG"
