# Copy this file to 00-site-overlay.local.rsc and fill in real values.
# Keep the .local file out of version control.

:global cfgSiteName "RB5009-STUDIO"
:global cfgAdminPassword "CHANGE_ME_STRONG_PASSWORD"
:global cfgWgPrivateKey "CHANGE_ME_WG_PRIVATE_KEY"
:global cfgWgAdminPublicKey "CHANGE_ME_ADMIN_CLIENT_PUBLIC_KEY"
:global cfgSyslogRemote "CHANGE_ME_SYSLOG_REMOTE"

# Optional address-list seeds to apply manually after staged import:
# /ip firewall address-list add list=mgmt-trusted address=192.168.10.99 comment="Admin workstation"
# /ip firewall address-list add list=services-approved-wired address=192.168.20.X comment="Approved wired service client"
# /ip firewall address-list add list=backup-approved-wired address=192.168.20.Y comment="Approved wired backup client"
