# Stage 70 - logging, backups, maintenance
:global cfgSyslogRemote

# Local logging topics
/system logging
:if ([:len [find where topics=system action=memory]] = 0) do={ add topics=system action=memory }
:if ([:len [find where topics=firewall action=memory]] = 0) do={ add topics=firewall action=memory }
:if ([:len [find where topics=dhcp action=memory]] = 0) do={ add topics=dhcp action=memory }

# Remote syslog target (only if cfgSyslogRemote is set to a real value)
:if ([:len "$cfgSyslogRemote"] > 0) do={
  :if ("$cfgSyslogRemote" != "CHANGE_ME_SYSLOG_REMOTE") do={
    :if ([:len [/system logging action find where name="remote-syslog"]] = 0) do={
      /system logging action add name="remote-syslog" target=remote remote="$cfgSyslogRemote" remote-port=514
    } else={
      /system logging action set [/system logging action find where name="remote-syslog"] target=remote remote="$cfgSyslogRemote" remote-port=514
    }
    :if ([:len [/system logging find where topics=system action="remote-syslog"]] = 0) do={ /system logging add topics=system action="remote-syslog" }
    :if ([:len [/system logging find where topics=firewall action="remote-syslog"]] = 0) do={ /system logging add topics=firewall action="remote-syslog" }
    :if ([:len [/system logging find where topics=critical action="remote-syslog"]] = 0) do={ /system logging add topics=critical action="remote-syslog" }
    :if ([:len [/system logging find where topics=warning action="remote-syslog"]] = 0) do={ /system logging add topics=warning action="remote-syslog" }
  }
}

# Private-only note:
# Encrypted scheduled backups should be installed from the private repo or a
# local overlay so the backup password never appears in the public template.
# Suggested pattern: private script name "private-encrypted-backup".

# Weekly text export
/system script
:if ([:len [find where name=weekly-export]] = 0) do={
  add name=weekly-export owner=admin policy=read,write source={
    /export file="rb5009-studio-weekly-export"
  }
} else={
  set [find where name=weekly-export] owner=admin policy=read,write
}

# Daily health check for basic operational drift.
:if ([:len [find where name=daily-health-check]] = 0) do={
  add name=daily-health-check owner=admin policy=read,write source={
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
} else={
  set [find where name=daily-health-check] owner=admin policy=read,write
}

# Reminder if private encrypted backup automation is not present.
:if ([:len [find where name=backup-policy-reminder]] = 0) do={
  add name=backup-policy-reminder owner=admin policy=read,write source={
    :if ([:len [/system script find where name="private-encrypted-backup"]] = 0) do={
      /log warning "backup-policy: private-encrypted-backup script is missing"
    }
  }
} else={
  set [find where name=backup-policy-reminder] owner=admin policy=read,write
}

/system scheduler
:if ([:len [find where name=run-weekly-export]] = 0) do={
  add name=run-weekly-export interval=7d start-time=03:00:00 on-event=weekly-export policy=read,write
} else={
  set [find where name=run-weekly-export] on-event=weekly-export policy=read,write
}
:if ([:len [find where name=run-daily-health-check]] = 0) do={
  add name=run-daily-health-check interval=1d start-time=03:10:00 on-event=daily-health-check policy=read,write
} else={
  set [find where name=run-daily-health-check] on-event=daily-health-check policy=read,write
}
:if ([:len [find where name=run-backup-policy-reminder]] = 0) do={
  add name=run-backup-policy-reminder interval=1d start-time=03:20:00 on-event=backup-policy-reminder policy=read,write
} else={
  set [find where name=run-backup-policy-reminder] on-event=backup-policy-reminder policy=read,write
}
