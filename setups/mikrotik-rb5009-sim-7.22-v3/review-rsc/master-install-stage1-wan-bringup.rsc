# Master installer - stage 1 WAN bring-up only
# Purpose: get management + VLAN baseline + WAN internet online first.
# Upload all referenced files to router /files first, then run:
# /import file-name=master-install-stage1-wan-bringup.rsc

:put "Starting Stage 1 WAN bring-up"
:if ([:len [/file find where name="00-site-overlay.local.rsc"]] = 0) do={
	:error "Missing 00-site-overlay.local.rsc. Copy 00-site-overlay.example.rsc and fill in local values first."
}
/import file-name=00-site-overlay.local.rsc
/import file-name=00-precheck.rsc
/import file-name=10-bootstrap-mgmt.rsc
/import file-name=20-interfaces-vlans.rsc
/import file-name=30-addressing-dhcp-dns.rsc
/import file-name=40-firewall-nat.rsc
/import file-name=98-stage1-wan-verify.rsc

:put "Stage 1 complete - verify WAN and management before continuing"
