# Stage 40 - firewall and NAT

# Replace bootstrap firewall with production policy
/ip firewall filter remove [find]

# Interface lists
/interface list add name=WAN
/interface list add name=LAN
/interface list member add list=WAN interface=ether1
/interface list member add list=LAN interface=vlan10-admin
/interface list member add list=LAN interface=vlan20-wired
/interface list member add list=LAN interface=vlan25-wifi
/interface list member add list=LAN interface=vlan30-guest
/interface list member add list=LAN interface=vlan40-iot
/interface list member add list=LAN interface=vlan50-voice
/interface list member add list=LAN interface=vlan60-backup
/interface list member add list=LAN interface=vlan70-services

# Address lists
/ip firewall address-list
add list=RFC1918 address=10.0.0.0/8
add list=RFC1918 address=172.16.0.0/12
add list=RFC1918 address=192.168.0.0/16
add list=mgmt-trusted address=192.168.10.99 comment="Admin Mac Studio"

# INPUT chain
/ip firewall filter
add chain=input action=accept connection-state=established,related comment="Input established/related"
add chain=input action=drop connection-state=invalid comment="Input invalid"
add chain=input action=accept protocol=icmp limit=10,20:packet comment="Input ICMP"
add chain=input action=accept in-interface=vlan10-admin protocol=tcp dst-port=22,8291 src-address-list=mgmt-trusted comment="Trusted admin bypass"
add chain=input action=drop in-interface=vlan10-admin protocol=tcp dst-port=22,8291 src-address-list=mgmt-bruteforce-blacklist comment="Drop blacklisted mgmt sources"
add chain=input action=add-src-to-address-list address-list=mgmt-bruteforce-blacklist address-list-timeout=10m connection-limit=20,32 connection-state=new in-interface=vlan10-admin protocol=tcp dst-port=22,8291 comment="Detect mgmt brute-force"
add chain=input action=accept in-interface=vlan10-admin protocol=tcp dst-port=22,8291 comment="Mgmt from admin VLAN"
add chain=input action=accept in-interface-list=LAN protocol=udp dst-port=53,67,68,123 comment="LAN DNS/DHCP/NTP"
add chain=input action=drop in-interface=vlan30-guest comment="Block guest to router management"
add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=51820 comment="WireGuard handshake"
add chain=input action=accept in-interface=wg0 protocol=udp dst-port=53 comment="DNS from WireGuard admin (UDP)"
add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=53 comment="DNS from WireGuard admin (TCP)"
add chain=input action=drop in-interface-list=WAN comment="Drop WAN to router"
add chain=input action=add-src-to-address-list address-list=wg-mgmt-bruteforce-blacklist address-list-timeout=10m connection-limit=20,32 connection-state=new in-interface=wg0 protocol=tcp dst-port=22,8291 comment="Detect WG mgmt brute-force"
add chain=input action=drop in-interface=wg0 protocol=tcp dst-port=22,8291 src-address-list=wg-mgmt-bruteforce-blacklist comment="Drop blacklisted WG mgmt sources"
add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=22,8291 comment="Mgmt from WireGuard"
add chain=input action=drop comment="Drop all other input"

# FORWARD chain
add chain=forward action=accept connection-state=established,related comment="Forward established/related"
add chain=forward action=drop connection-state=invalid comment="Forward invalid"

# Anti-spoof per VLAN
add chain=forward action=drop in-interface=vlan10-admin src-address=!192.168.10.0/24 comment="Anti-spoof VLAN10"
add chain=forward action=drop in-interface=vlan20-wired src-address=!192.168.20.0/24 comment="Anti-spoof VLAN20"
add chain=forward action=add-src-to-address-list address-list=vlan25-spoof-sources address-list-timeout=1h in-interface=vlan25-wifi src-address=!192.168.25.0/24 comment="Track VLAN25 spoof sources"
add chain=forward action=drop in-interface=vlan25-wifi src-address=!192.168.25.0/24 comment="Anti-spoof VLAN25"
add chain=forward action=drop in-interface=vlan30-guest src-address=!192.168.30.0/24 comment="Anti-spoof VLAN30"
add chain=forward action=drop in-interface=vlan40-iot src-address=!192.168.40.0/24 comment="Anti-spoof VLAN40"
add chain=forward action=drop in-interface=vlan50-voice src-address=!192.168.50.0/24 comment="Anti-spoof VLAN50"
add chain=forward action=drop in-interface=vlan60-backup src-address=!192.168.60.0/24 comment="Anti-spoof VLAN60"
add chain=forward action=drop in-interface=vlan70-services src-address=!192.168.70.0/24 comment="Anti-spoof VLAN70"

# Inter-VLAN policy
add chain=forward action=accept in-interface=vlan10-admin comment="Admin can reach all"
add chain=forward action=drop in-interface=vlan20-wired out-interface=vlan10-admin comment="Wired blocked to admin"
add chain=forward action=drop in-interface=vlan25-wifi out-interface=vlan10-admin comment="Wi-Fi blocked to admin"
add chain=forward action=drop in-interface=vlan25-wifi out-interface=vlan60-backup comment="Wi-Fi blocked to backup"
add chain=forward action=accept in-interface=vlan25-wifi out-interface=vlan70-services src-address-list=services-approved-wifi comment="Allow approved Wi-Fi endpoints to services"
add chain=forward action=drop in-interface=vlan30-guest dst-address-list=RFC1918 comment="Guest blocked to private IP"
add chain=forward action=drop in-interface=vlan40-iot out-interface=vlan10-admin comment="IoT blocked to admin"
add chain=forward action=drop in-interface=vlan50-voice out-interface=vlan10-admin comment="Voice blocked to admin"
add chain=forward action=drop in-interface=vlan20-wired out-interface=vlan70-services comment="Wired blocked to services unless approved"
add chain=forward action=drop in-interface=vlan25-wifi out-interface=vlan70-services comment="Wi-Fi blocked to services unless approved"
add chain=forward action=drop in-interface=vlan70-services out-interface=vlan60-backup comment="Services blocked to backup"

# LAN to WAN allowed
add chain=forward action=accept in-interface-list=LAN out-interface-list=WAN comment="LAN to internet"

# WireGuard to admin management only
add chain=forward action=accept in-interface=wg0 out-interface=vlan10-admin comment="WG to admin VLAN only"
add chain=forward action=accept in-interface=vlan10-admin out-interface=wg0 connection-state=established,related comment="Admin VLAN return to WG"

# Safe defaults: keep allowlist-based wired exceptions disabled until entries are approved.
add chain=forward action=accept disabled=yes in-interface=vlan20-wired out-interface=vlan60-backup src-address-list=backup-approved-wired comment="Allow only approved wired endpoints to backup"
add chain=forward action=accept disabled=yes in-interface=vlan20-wired out-interface=vlan70-services src-address-list=services-approved-wired comment="Allow approved wired endpoints to services"

# Default deny
add chain=forward action=drop comment="Drop all other forward"

# NAT
/ip firewall nat
add chain=srcnat action=masquerade out-interface-list=WAN comment="Masquerade LAN to WAN"
