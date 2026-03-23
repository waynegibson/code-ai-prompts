# Stage 20 - interfaces and VLAN topology
# Ports
# ether1: WAN DHCP from ONT
# ether2: access VLAN 20 (trusted wired)
# ether8: trunk to AP (tagged VLANs 10,20,25,30,40,50,70)
# ether7: access VLAN 10 (admin)
# ether6: access VLAN 50 (voice switch)

# Add bridge ports
/interface bridge port
add bridge=bridge1 interface=ether2 pvid=20 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="Trusted wired access"
add bridge=bridge1 interface=ether8 frame-types=admit-only-vlan-tagged ingress-filtering=yes comment="AP trunk"
add bridge=bridge1 interface=ether6 pvid=50 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="Voice access"

# Create VLAN interfaces for routing/services
/interface vlan
add name=vlan20-wired interface=bridge1 vlan-id=20
add name=vlan25-wifi interface=bridge1 vlan-id=25
add name=vlan30-guest interface=bridge1 vlan-id=30
add name=vlan40-iot interface=bridge1 vlan-id=40
add name=vlan50-voice interface=bridge1 vlan-id=50
add name=vlan60-backup interface=bridge1 vlan-id=60
add name=vlan70-services interface=bridge1 vlan-id=70

# Bridge VLAN table
/interface bridge vlan
set [find where bridge=bridge1 vlan-ids=10] tagged=bridge1,ether8 untagged=ether7
add bridge=bridge1 vlan-ids=20 tagged=bridge1,ether8 untagged=ether2
add bridge=bridge1 vlan-ids=25 tagged=bridge1,ether8
add bridge=bridge1 vlan-ids=30 tagged=bridge1,ether8
add bridge=bridge1 vlan-ids=40 tagged=bridge1,ether8
add bridge=bridge1 vlan-ids=50 tagged=bridge1,ether8 untagged=ether6
add bridge=bridge1 vlan-ids=60 tagged=bridge1
add bridge=bridge1 vlan-ids=70 tagged=bridge1,ether8

# Enable VLAN filtering after table is in place
/interface bridge set [find name=bridge1] vlan-filtering=yes

# WAN DHCP client
/ip dhcp-client add interface=ether1 use-peer-dns=no add-default-route=yes default-route-distance=1 comment="Afrihost WAN"
