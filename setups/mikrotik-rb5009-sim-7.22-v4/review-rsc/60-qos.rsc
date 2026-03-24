# Stage 60 - QoS for voice and interactive traffic
# Conservative policy for 1 Gbps WAN

/queue type
:if ([:len [find name=pcq-upload]] = 0) do={
    add name=pcq-upload kind=pcq pcq-classifier=src-address
}
:if ([:len [find name=pcq-download]] = 0) do={
    add name=pcq-download kind=pcq pcq-classifier=dst-address
}

/ip firewall mangle
:if ([:len [find comment="Voice SIP/RTP"]] = 0) do={
    add chain=forward action=mark-packet new-packet-mark=voice passthrough=no protocol=udp dst-port=5060,5061,10000-20000 comment="Voice SIP/RTP"
}
:if ([:len [find comment="Interactive"]] = 0) do={
    add chain=forward action=mark-packet new-packet-mark=interactive passthrough=no protocol=tcp dst-port=443,22,8291 comment="Interactive"
}
:if ([:len [find comment="Bulk default"]] = 0) do={
    add chain=forward action=mark-packet new-packet-mark=bulk packet-mark=no-mark passthrough=no out-interface=ether1 comment="Bulk default"
}

/queue tree
:if ([:len [find name=wan-root]] = 0) do={
    add name=wan-root parent=ether1 max-limit=950M
}
:if ([:len [find name=voice]] = 0) do={
    add name=voice parent=wan-root packet-mark=voice priority=1 limit-at=150M max-limit=300M queue=pcq-upload
}
:if ([:len [find name=interactive]] = 0) do={
    add name=interactive parent=wan-root packet-mark=interactive priority=2 limit-at=200M max-limit=450M queue=pcq-upload
}
:if ([:len [find name=bulk]] = 0) do={
    add name=bulk parent=wan-root packet-mark=bulk priority=8 limit-at=50M max-limit=900M queue=pcq-upload
}
