# Stage 10 - bootstrap management baseline
/system identity set name="RB5009-Cape-Town"
/system clock set time-zone-name=Africa/Johannesburg

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set www-ssl disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set ssh disabled=no port=22
set winbox disabled=no port=8291

/ip ssh set strong-crypto=yes allow-none-crypto=no always-allow-password-login=no

# Set a strong admin password immediately
# Replace before use
/user set [find name="admin"] password="CHANGE_ME_STRONG_PASSWORD"

# Create bridge and temporary/admin access lane on ether9
/interface bridge add name=bridge1 vlan-filtering=no protocol-mode=rstp comment="Core bridge"
/interface bridge port add bridge=bridge1 interface=ether9 pvid=10 comment="Admin access port"

# Management VLAN interface on bridge
/interface vlan add name=vlan10-admin interface=bridge1 vlan-id=10
/ip address add address=192.168.10.1/24 interface=vlan10-admin comment="Admin gateway"

# Admin DHCP for initial access
/ip pool add name=pool-vlan10 ranges=192.168.10.10-192.168.10.99
/ip dhcp-server add name=dhcp-vlan10 interface=vlan10-admin address-pool=pool-vlan10 lease-time=8h disabled=no
/ip dhcp-server network add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=192.168.10.1

/ip dns set servers=1.1.1.1,8.8.8.8 allow-remote-requests=yes

# Minimal input policy to lock router management
/ip firewall filter
add chain=input action=accept connection-state=established,related comment="Allow established"
add chain=input action=drop connection-state=invalid comment="Drop invalid"
add chain=input action=accept protocol=icmp limit=10,20:packet comment="Allow limited ICMP"
add chain=input action=accept in-interface=vlan10-admin protocol=tcp dst-port=22,8291 comment="SSH/WinBox from admin VLAN"
add chain=input action=drop comment="Drop the rest"
