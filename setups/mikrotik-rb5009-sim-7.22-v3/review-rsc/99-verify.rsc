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
/ip firewall address-list print where list~"backup-approved-wired|services-approved"
/ip firewall address-list print where list~"mgmt-bruteforce|wg-mgmt-bruteforce|wan-port-scanners"

:put "=== VPN and QoS ==="
/interface wireguard print detail
/interface wireguard peers print detail
/queue tree print stats

:put "=== Management Surface ==="
/ip service print
/tool mac-server print
/tool mac-server mac-winbox print
/ip neighbor discovery-settings print

:put "=== Health ==="
/system resource print
/log print where topics~"critical|error|warning"

:put "=== Logging and Maintenance ==="
/system logging print
/system logging action print
/system script print
/system scheduler print
