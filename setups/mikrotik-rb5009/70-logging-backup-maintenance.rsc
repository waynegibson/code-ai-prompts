# Stage 70 - logging, backups, maintenance
:global CFG_SYSLOG_REMOTE

# Local logging topics
/system logging
add topics=system action=memory
add topics=firewall action=memory
add topics=dhcp action=memory
add topics=critical action=memory

# Remote syslog target
:if ([:len "$CFG_SYSLOG_REMOTE"] > 0 && "$CFG_SYSLOG_REMOTE" != "CHANGE_ME_SYSLOG_REMOTE") do={
  /system logging action add name=remote-syslog type=remote remote="$CFG_SYSLOG_REMOTE" remote-port=514 bsd-syslog=yes
  /system logging add topics=system action=remote-syslog
  /system logging add topics=firewall action=remote-syslog
  /system logging add topics=critical action=remote-syslog
}

# Private-only note:
# Encrypted scheduled backups should be installed from the private repo or a
# local overlay so the backup password never appears in the public template.

# Weekly text export
/system script
add name=weekly-export source={
  /export file="rb5009-weekly-export"
}

/system scheduler
add name=run-weekly-export interval=7d start-time=03:00:00 on-event=weekly-export
