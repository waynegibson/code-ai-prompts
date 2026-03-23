# Stage 99 - verification checklist commands

:put "=== Interfaces ==="
/interface print
/interface bridge port print
/interface bridge vlan print
/interface vlan print

:put "=== Addressing and DHCP ==="
/ip address print
/ip dhcp-server print
/ip dhcp-server lease print

:put "=== Routing and WAN ==="
/ip dhcp-client print
/ip route print

:put "=== Firewall and NAT ==="
/ip firewall filter print stats
/ip firewall nat print stats

:put "=== VPN and QoS ==="
/interface wireguard print detail
/interface wireguard peers print detail
/queue tree print stats

:put "=== Health ==="
/system resource print
/log print where topics~"critical|error|warning"
