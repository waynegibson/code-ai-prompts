# Stage 70 - logging, backups, maintenance
# Replace placeholders before production

# Local logging topics
/system logging
add topics=system action=memory
add topics=firewall action=memory
add topics=dhcp action=memory
add topics=critical action=memory

# Remote syslog target
/system logging action
add name=remote-syslog type=remote remote=192.168.10.50 remote-port=514 bsd-syslog=yes

/system logging
add topics=system action=remote-syslog
add topics=firewall action=remote-syslog
add topics=critical action=remote-syslog

# SNMP optional (restrict to admin VLAN)
/snmp set enabled=yes trap-version=3 trap-generators=temp-exception
/snmp community add name=readonly addresses=192.168.10.0/24 read-access=yes write-access=no

# Daily encrypted backup
/system script
add name=daily-encrypted-backup source={
  :local d [/system clock get date]
  :local fname ("rb5009-" . $d)
  /system backup save name=$fname password="CHANGE_ME_BACKUP_PASSWORD" encryption=aes-sha256
}

/system scheduler
add name=run-daily-backup interval=1d start-time=02:15:00 on-event=daily-encrypted-backup

# Weekly text export
/system script
add name=weekly-export source={
  :local d [/system clock get date]
  /export file=("rb5009-export-" . $d)
}

/system scheduler
add name=run-weekly-export interval=7d start-time=03:00:00 on-event=weekly-export
