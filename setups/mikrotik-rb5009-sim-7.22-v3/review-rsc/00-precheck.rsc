# RB5009 precheck for clean-start staged deployment
:local board [/system resource get board-name]
:put ("Detected board: " . $board)
:if ($board !~ "RB5009") do={
  :error "This script pack targets RB5009 class hardware only"
}

:put "Precheck passed"
:put "Confirm: WAN on ether1, AP trunk on ether8, admin port on ether7, wired access on ether2, voice access on ether6"
:put "Confirm v3 VLAN plan: 10,20,25,30,40,50,60,70"
:put "Upload all .rsc files before running master install"
