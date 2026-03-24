# Stage 31 - optional static leases aligned to post-audit baseline
# Keep/update these values for your own environment.

/ip dhcp-server lease
add address=192.168.25.196 comment="ASUS TUF-BE6500 AP" mac-address=BC:FC:E7:34:30:84 server=dhcp-vlan25
add address=192.168.10.99 comment="Admin Mac Studio reserved" mac-address=9C:76:0E:33:2C:CA server=dhcp-vlan10
add address=192.168.25.197 comment=MOBILE-iPhone-A mac-address=8E:E0:89:7F:57:17 server=dhcp-vlan25
add address=192.168.25.193 comment=MOBILE-iPhone-B mac-address=06:B2:E5:8C:28:E6 server=dhcp-vlan25
add address=192.168.25.195 comment=MOBILE-iPad mac-address=4A:E4:9F:EC:61:A6 server=dhcp-vlan25
add address=192.168.25.198 comment=MOBILE-Watch-A mac-address=4A:0D:4E:13:D8:D7 server=dhcp-vlan25
add address=192.168.25.192 comment=MOBILE-Watch-B mac-address=92:53:D9:C5:D2:D5 server=dhcp-vlan25
