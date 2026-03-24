# Stage 20 - interfaces and VLAN topology
# Ports
# ether1: WAN DHCP from ONT
# ether2: access VLAN 20 (trusted wired)
# ether3: access VLAN 20 (trusted wired office run)
# ether4: access VLAN 70 (services)
# ether5: access VLAN 70 (services)
# ether8: access VLAN 25 to AP
# ether7: access VLAN 10 (admin)
# ether6: access VLAN 50 (voice switch)

# Add bridge ports
/interface bridge port
add bridge=br-studio-lan interface=ether2 pvid=20 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="Trusted wired access"
add bridge=br-studio-lan interface=ether3 pvid=20 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="Trusted wired access (office run)"
add bridge=br-studio-lan interface=ether4 pvid=70 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="Services access (living run)"
add bridge=br-studio-lan interface=ether5 pvid=70 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="Services access (living run)"
add bridge=br-studio-lan interface=ether6 pvid=50 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="Voice access"
add bridge=br-studio-lan interface=ether8 pvid=25 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="AP access VLAN25"

# Create VLAN interfaces for routing/services
/interface vlan
add name=vlan20-wired interface=br-studio-lan vlan-id=20
add name=vlan25-wifi interface=br-studio-lan vlan-id=25
add name=vlan30-guest interface=br-studio-lan vlan-id=30
add name=vlan40-iot interface=br-studio-lan vlan-id=40
add name=vlan50-voice interface=br-studio-lan vlan-id=50
add name=vlan60-backup interface=br-studio-lan vlan-id=60
add name=vlan70-services interface=br-studio-lan vlan-id=70

# Bridge VLAN table
/interface bridge vlan
set [find where bridge=br-studio-lan vlan-ids=10] tagged=br-studio-lan untagged=ether7
add bridge=br-studio-lan vlan-ids=20 tagged=br-studio-lan untagged=ether2,ether3
add bridge=br-studio-lan vlan-ids=25 tagged=br-studio-lan untagged=ether8
add bridge=br-studio-lan vlan-ids=30 tagged=br-studio-lan
add bridge=br-studio-lan vlan-ids=40 tagged=br-studio-lan
add bridge=br-studio-lan vlan-ids=50 tagged=br-studio-lan untagged=ether6
add bridge=br-studio-lan vlan-ids=60 tagged=br-studio-lan
add bridge=br-studio-lan vlan-ids=70 tagged=br-studio-lan untagged=ether4,ether5

# Enable VLAN filtering after table is in place
/interface bridge set [find name=br-studio-lan] vlan-filtering=yes

# WAN DHCP client
/ip dhcp-client add name=client1 interface=ether1 use-peer-dns=no comment="Afrihost WAN"
