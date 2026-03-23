# Master installer - staged clean-start deployment
# Upload all referenced files to router /files first, then run:
# /import file-name=master-install-clean-start.rsc

:put "Starting staged RB5009 deployment"
/import file-name=00-precheck.rsc
/import file-name=10-bootstrap-mgmt.rsc
/import file-name=20-interfaces-vlans.rsc
/import file-name=30-addressing-dhcp-dns.rsc
/import file-name=40-firewall-nat.rsc
/import file-name=50-wireguard.rsc
/import file-name=60-qos.rsc
/import file-name=70-logging-backup-maintenance.rsc
/import file-name=99-verify.rsc

:put "Deployment complete - review output and run acceptance tests"
