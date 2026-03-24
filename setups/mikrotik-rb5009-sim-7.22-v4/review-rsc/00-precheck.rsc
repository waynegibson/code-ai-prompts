# RB5009 precheck for clean-start staged deployment
:local board [/system resource get board-name]
:put ("Detected board: " . $board)
:if ([:find $board "RB5009"] = nil) do={
  :error "This script pack targets RB5009 class hardware only"
}

:put "Precheck passed"
:put "Confirm: WAN on ether1, AP access on ether8 (VLAN25), admin port on ether7, wired access on ether2+ether3, services on ether4+ether5, voice on ether6"
:put "Confirm VLAN plan: 10,20,25,30,40,50,60,70"
:put "Upload all .rsc files before running master install"
