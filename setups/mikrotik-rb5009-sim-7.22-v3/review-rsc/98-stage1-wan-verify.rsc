# Stage 98 - stage 1 WAN and management verification

:put "=== Stage 1: WAN status ==="
/ip dhcp-client print detail where interface=ether1
/ip route print where dst-address="0.0.0.0/0"

:put "=== Stage 1: Connectivity tests ==="
/ping 1.1.1.1 count=5
:put "DNS test (cloudflare.com):"
:put [:resolve "cloudflare.com"]

:put "=== Stage 1: Management path ==="
/ip address print where interface=vlan10-admin
/ip firewall filter print stats where chain=input
/ip service print

:put "=== Stage 1: DHCP on key VLANs ==="
/ip dhcp-server print where name~"dhcp-vlan10|dhcp-vlan20|dhcp-vlan25|dhcp-vlan30|dhcp-vlan40|dhcp-vlan50|dhcp-vlan60|dhcp-vlan70"

:put "If WAN is not bound on ether1, power-cycle ONT and re-check dhcp-client state."
