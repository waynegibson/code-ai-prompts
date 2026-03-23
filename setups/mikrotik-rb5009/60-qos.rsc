# Stage 60 - QoS for voice and interactive traffic
# Conservative policy for 1 Gbps WAN

/queue type
add name=pcq-upload kind=pcq pcq-classifier=src-address
add name=pcq-download kind=pcq pcq-classifier=dst-address

/ip firewall mangle
add chain=forward action=mark-packet new-packet-mark=voice passthrough=yes protocol=udp dst-port=5060,5061,10000-20000 comment="Voice SIP/RTP"
add chain=forward action=mark-packet new-packet-mark=interactive passthrough=yes protocol=tcp dst-port=443,22,8291 comment="Interactive"
add chain=forward action=mark-packet new-packet-mark=bulk passthrough=yes out-interface=ether1 comment="Bulk default"

/queue tree
add name=wan-root parent=ether1 max-limit=950M
add name=voice parent=wan-root packet-mark=voice priority=1 limit-at=150M max-limit=300M queue=pcq-upload
add name=interactive parent=wan-root packet-mark=interactive priority=2 limit-at=200M max-limit=450M queue=pcq-upload
add name=bulk parent=wan-root packet-mark=bulk priority=8 limit-at=50M max-limit=900M queue=pcq-upload
