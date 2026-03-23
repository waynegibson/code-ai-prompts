# Master installer - stage 2 hardening and operations
# Purpose: apply VPN, QoS, logging/maintenance, and full verification
# Run only after successful Stage 1 WAN bring-up.
# /import file-name=master-install-stage2-hardening.rsc

:put "Starting Stage 2 hardening"
/import file-name=50-wireguard.rsc
/import file-name=60-qos.rsc
/import file-name=70-logging-backup-maintenance.rsc
/import file-name=99-verify.rsc

:put "Stage 2 complete - review verification output and logs"
