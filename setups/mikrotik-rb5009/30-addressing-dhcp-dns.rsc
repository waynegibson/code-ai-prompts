# Stage 30 - addressing, DHCP, DNS, NTP

# VLAN gateway IPs
/ip address
add address=192.168.20.1/24 interface=vlan20-main comment="Main VLAN gateway"
add address=192.168.30.1/24 interface=vlan30-guest comment="Guest VLAN gateway"
add address=192.168.40.1/24 interface=vlan40-iot comment="IoT VLAN gateway"
add address=192.168.50.1/24 interface=vlan50-voice comment="Voice VLAN gateway"

# DHCP pools
/ip pool
add name=pool-vlan20 ranges=192.168.20.10-192.168.20.199
add name=pool-vlan30 ranges=192.168.30.10-192.168.30.199
add name=pool-vlan40 ranges=192.168.40.10-192.168.40.199
add name=pool-vlan50 ranges=192.168.50.10-192.168.50.49

# DHCP servers
/ip dhcp-server
add name=dhcp-vlan20 interface=vlan20-main address-pool=pool-vlan20 lease-time=8h disabled=no
add name=dhcp-vlan30 interface=vlan30-guest address-pool=pool-vlan30 lease-time=4h disabled=no
add name=dhcp-vlan40 interface=vlan40-iot address-pool=pool-vlan40 lease-time=1d disabled=no
add name=dhcp-vlan50 interface=vlan50-voice address-pool=pool-vlan50 lease-time=8h disabled=no

# DHCP network options
/ip dhcp-server network
add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=192.168.20.1
add address=192.168.30.0/24 gateway=192.168.30.1 dns-server=192.168.30.1
add address=192.168.40.0/24 gateway=192.168.40.1 dns-server=192.168.40.1
add address=192.168.50.0/24 gateway=192.168.50.1 dns-server=192.168.50.1

# DNS cache and upstreams
/ip dns set allow-remote-requests=yes servers=1.1.1.1,9.9.9.9,8.8.8.8 cache-size=4096KiB cache-max-ttl=1d

# NTP client
/system ntp client set enabled=yes
/system ntp client servers add address=0.pool.ntp.org
/system ntp client servers add address=1.pool.ntp.org
