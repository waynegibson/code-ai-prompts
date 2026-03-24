# Stage 90 - emergency rollback helpers

:put "Rollback options:"
:put "1) Disable strict forward drop temporarily"
:put "2) Restore from known-good backup"
:put "3) Last resort clean reset"

# Option 1 - identify and disable final drop rules manually
/ip firewall filter print where comment~"Drop all other"

# Option 2 - restore backup (edit name/password first)
# /system backup load name=rb5009-known-good.backup password="CHANGE_ME_BACKUP_PASSWORD"

# Option 3 - full clean reset (destructive)
# /system reset-configuration no-defaults=yes skip-backup=yes
