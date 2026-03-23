# Stage 40 - firewall and NAT

# Interface lists
/interface list add name=WAN
/interface list add name=LAN
/interface list member add list=WAN interface=ether1
/interface list member add list=LAN interface=bridge1
/interface list member add list=LAN interface=vlan10-admin
/interface list member add list=LAN interface=vlan20-main
/interface list member add list=LAN interface=vlan30-guest
/interface list member add list=LAN interface=vlan40-iot
/interface list member add list=LAN interface=vlan50-voice

# Address lists
/ip firewall address-list
add list=RFC1918 address=10.0.0.0/8
add list=RFC1918 address=172.16.0.0/12
add list=RFC1918 address=192.168.0.0/16

# INPUT chain
/ip firewall filter
add chain=input action=accept connection-state=established,related comment="Input established/related"
add chain=input action=drop connection-state=invalid comment="Input invalid"
add chain=input action=accept protocol=icmp limit=10,20:packet comment="Input ICMP"
add chain=input action=accept in-interface=vlan10-admin protocol=tcp dst-port=22,8291 comment="Mgmt from admin VLAN"
add chain=input action=accept in-interface=wg0 protocol=tcp dst-port=22,8291 comment="Mgmt from WireGuard"
add chain=input action=accept in-interface-list=WAN protocol=udp dst-port=51820 comment="WireGuard handshake"
add chain=input action=accept in-interface-list=LAN protocol=udp dst-port=53,67,68,123 comment="LAN DNS/DHCP/NTP"
add chain=input action=drop in-interface-list=WAN comment="Drop WAN to router"
add chain=input action=drop comment="Drop all other input"

# FORWARD chain
add chain=forward action=accept connection-state=established,related comment="Forward established/related"
add chain=forward action=drop connection-state=invalid comment="Forward invalid"

# Anti-spoof per VLAN
add chain=forward action=drop in-interface=vlan10-admin src-address=!192.168.10.0/24 comment="Anti-spoof VLAN10"
add chain=forward action=drop in-interface=vlan20-main src-address=!192.168.20.0/24 comment="Anti-spoof VLAN20"
add chain=forward action=drop in-interface=vlan30-guest src-address=!192.168.30.0/24 comment="Anti-spoof VLAN30"
add chain=forward action=drop in-interface=vlan40-iot src-address=!192.168.40.0/24 comment="Anti-spoof VLAN40"
add chain=forward action=drop in-interface=vlan50-voice src-address=!192.168.50.0/24 comment="Anti-spoof VLAN50"

# Inter-VLAN policy
add chain=forward action=accept in-interface=vlan10-admin comment="Admin can reach all"
add chain=forward action=drop in-interface=vlan20-main out-interface=vlan10-admin comment="Main blocked to admin"
add chain=forward action=drop in-interface=vlan20-main out-interface=vlan40-iot comment="Main blocked to IoT"
add chain=forward action=drop in-interface=vlan20-main out-interface=vlan50-voice comment="Main blocked to voice"
add chain=forward action=drop in-interface=vlan30-guest dst-address-list=RFC1918 comment="Guest blocked to private IP"
add chain=forward action=drop in-interface=vlan40-iot out-interface=vlan10-admin comment="IoT blocked to admin"
add chain=forward action=drop in-interface=vlan40-iot out-interface=vlan20-main comment="IoT blocked to main"
add chain=forward action=drop in-interface=vlan40-iot out-interface=vlan50-voice comment="IoT blocked to voice"
add chain=forward action=drop in-interface=vlan50-voice out-interface=vlan10-admin comment="Voice blocked to admin"
add chain=forward action=drop in-interface=vlan50-voice out-interface=vlan20-main comment="Voice blocked to main"
add chain=forward action=drop in-interface=vlan50-voice out-interface=vlan40-iot comment="Voice blocked to IoT"

# LAN to WAN allowed
add chain=forward action=accept in-interface-list=LAN out-interface-list=WAN comment="LAN to internet"

# Optional: fasttrack for established forward traffic (disabled by default)
# add chain=forward action=fasttrack-connection connection-state=established,related hw-offload=yes

# Default deny
add chain=forward action=drop comment="Drop all other forward"

# NAT
/ip firewall nat
add chain=srcnat action=masquerade out-interface-list=WAN comment="Masquerade LAN to WAN"
