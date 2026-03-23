# Stage 50 - WireGuard admin VPN
:global cfgWgPrivateKey
:global cfgWgAdminPublicKey

:if ([:len "$cfgWgPrivateKey"] = 0 || "$cfgWgPrivateKey" = "CHANGE_ME_WG_PRIVATE_KEY") do={
	:error "Missing cfgWgPrivateKey. Import 00-site-overlay.local.rsc first."
}

:if ([:len "$cfgWgAdminPublicKey"] = 0 || "$cfgWgAdminPublicKey" = "CHANGE_ME_ADMIN_CLIENT_PUBLIC_KEY") do={
	:error "Missing cfgWgAdminPublicKey. Import 00-site-overlay.local.rsc first."
}

/interface wireguard
add name=wg0 listen-port=51820 mtu=1420 private-key="$cfgWgPrivateKey"

/ip address
add address=10.10.10.1/24 interface=wg0 comment="WireGuard admin subnet"

/interface wireguard peers
add interface=wg0 public-key="$cfgWgAdminPublicKey" allowed-address=10.10.10.2/32 comment="Admin laptop"

# Router management from WireGuard
/ip firewall filter
add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=51820 place-before=[find where comment="Drop WAN to router"] comment="WireGuard handshake"
add chain=input action=add-src-to-address-list in-interface=wg0 protocol=tcp dst-port=22,8291 connection-state=new src-address-list=!wg-mgmt-bruteforce-stage1 address-list=wg-mgmt-bruteforce-stage1 address-list-timeout=1m place-before=[find where comment="Mgmt from WireGuard"] comment="WG mgmt brute-force stage1"
add chain=input action=add-src-to-address-list in-interface=wg0 protocol=tcp dst-port=22,8291 connection-state=new src-address-list=wg-mgmt-bruteforce-stage1 src-address-list=!wg-mgmt-bruteforce-stage2 address-list=wg-mgmt-bruteforce-stage2 address-list-timeout=5m place-before=[find where comment="Mgmt from WireGuard"] comment="WG mgmt brute-force stage2"
add chain=input action=add-src-to-address-list in-interface=wg0 protocol=tcp dst-port=22,8291 connection-state=new src-address-list=wg-mgmt-bruteforce-stage2 src-address-list=!wg-mgmt-bruteforce-stage3 address-list=wg-mgmt-bruteforce-stage3 address-list-timeout=1h place-before=[find where comment="Mgmt from WireGuard"] comment="WG mgmt brute-force stage3"
add chain=input action=add-src-to-address-list in-interface=wg0 protocol=tcp dst-port=22,8291 connection-state=new src-address-list=wg-mgmt-bruteforce-stage3 address-list=wg-mgmt-bruteforce-blacklist address-list-timeout=1d place-before=[find where comment="Mgmt from WireGuard"] comment="WG mgmt brute-force blacklist"
add chain=input action=drop in-interface=wg0 protocol=tcp dst-port=22,8291 src-address-list=wg-mgmt-bruteforce-blacklist place-before=[find where comment="Mgmt from WireGuard"] comment="Drop blacklisted WG mgmt sources"
add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=22,8291 place-before=[find where comment="Drop all other input"] comment="Mgmt from WireGuard"

# Default: WireGuard admin reaches management VLAN only.
add chain=forward action=accept in-interface=wg0 out-interface=vlan10-admin place-before=[find where comment="Drop all other forward"] comment="WG to admin VLAN only"
add chain=forward action=accept in-interface=vlan10-admin out-interface=wg0 connection-state=established,related place-before=[find where comment="Drop all other forward"] comment="Admin VLAN return to WG"

# Optional (commented): broaden WG access beyond management if explicitly needed.
# add chain=forward action=accept in-interface=wg0 out-interface-list=LAN place-before=[find where comment="Drop all other forward"] comment="WG to full LAN"
# add chain=forward action=accept in-interface-list=LAN out-interface=wg0 connection-state=established,related place-before=[find where comment="Drop all other forward"] comment="LAN return to WG"
