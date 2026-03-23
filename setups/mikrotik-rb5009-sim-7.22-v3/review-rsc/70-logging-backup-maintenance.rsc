# Stage 70 - logging, backups, maintenance
:global cfgSyslogRemote

# Local logging topics
/system logging
add topics=system action=memory
add topics=firewall action=memory
add topics=dhcp action=memory
add topics=critical action=memory
add topics=warning action=memory

# Remote syslog target
:if ([:len "$cfgSyslogRemote"] > 0 && "$cfgSyslogRemote" != "CHANGE_ME_SYSLOG_REMOTE") do={
  /system logging action add name=remote-syslog type=remote remote="$cfgSyslogRemote" remote-port=514 bsd-syslog=yes
  /system logging add topics=system action=remote-syslog
  /system logging add topics=firewall action=remote-syslog
  /system logging add topics=critical action=remote-syslog
  /system logging add topics=warning action=remote-syslog
}

# Private-only note:
# Encrypted scheduled backups should be installed from the private repo or a
# local overlay so the backup password never appears in the public template.
# Suggested pattern: private script name "private-encrypted-backup".

# Weekly text export
/system script
add name=weekly-export source={
  /export file="rb5009-weekly-export"
}

# Daily health check for basic operational drift.
/system script
add name=daily-health-check source={
  :local cpu [/system resource get cpu-load]
  :local freeMem [/system resource get free-memory]
  :local totalMem [/system resource get total-memory]
  :local freeHdd [/system resource get free-hdd-space]
  :local totalHdd [/system resource get total-hdd-space]

  :if ($cpu > 80) do={
    /log warning ("health-check: high CPU load " . $cpu . "%")
  }

  :if ($totalMem > 0 && (($freeMem * 100) / $totalMem) < 20) do={
    /log warning "health-check: low free memory (<20%)"
  }

  :if ($totalHdd > 0 && (($freeHdd * 100) / $totalHdd) < 20) do={
    /log warning "health-check: low free storage (<20%)"
  }
}

# Reminder if private encrypted backup automation is not present.
/system script
add name=backup-policy-reminder source={
  :if ([:len [/system script find where name="private-encrypted-backup"]] = 0) do={
    /log warning "backup-policy: private-encrypted-backup script is missing"
  }
}

/system scheduler
add name=run-weekly-export interval=7d start-time=03:00:00 on-event=weekly-export
add name=run-daily-health-check interval=1d start-time=03:10:00 on-event=daily-health-check
add name=run-backup-policy-reminder interval=1d start-time=03:20:00 on-event=backup-policy-reminder
