# Stage 50 - WireGuard admin VPN
:global CFG_WG_PRIVATE_KEY
:global CFG_WG_ADMIN_PUBLIC_KEY

:if ([:len "$CFG_WG_PRIVATE_KEY"] = 0 || "$CFG_WG_PRIVATE_KEY" = "CHANGE_ME_WG_PRIVATE_KEY") do={
	:error "Missing CFG_WG_PRIVATE_KEY. Import 00-site-overlay.local.rsc first."
}

:if ([:len "$CFG_WG_ADMIN_PUBLIC_KEY"] = 0 || "$CFG_WG_ADMIN_PUBLIC_KEY" = "CHANGE_ME_ADMIN_CLIENT_PUBLIC_KEY") do={
	:error "Missing CFG_WG_ADMIN_PUBLIC_KEY. Import 00-site-overlay.local.rsc first."
}

/interface wireguard
add name=wg0 listen-port=51820 mtu=1420 private-key="$CFG_WG_PRIVATE_KEY"

/ip address
add address=10.10.10.1/24 interface=wg0 comment="WireGuard admin subnet"

/interface wireguard peers
add interface=wg0 public-key="$CFG_WG_ADMIN_PUBLIC_KEY" allowed-address=10.10.10.2/32 comment="Admin laptop"

# Router management from WireGuard
/ip firewall filter
add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=51820 place-before=[find where comment="Drop WAN to router"] comment="WireGuard handshake"
add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=22,8291 place-before=[find where comment="Drop all other input"] comment="Mgmt from WireGuard"

# Optional: if you want full access from WG admin subnet
add chain=forward action=accept in-interface=wg0 out-interface-list=LAN place-before=[find where comment="Drop all other forward"] comment="WG to LAN"
add chain=forward action=accept in-interface-list=LAN out-interface=wg0 connection-state=established,related place-before=[find where comment="Drop all other forward"] comment="LAN return to WG"
