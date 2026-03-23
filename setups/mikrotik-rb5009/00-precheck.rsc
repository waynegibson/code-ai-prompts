# RB5009 precheck for clean-start staged deployment
:local board [/system resource get board-name]
:put ("Detected board: " . $board)
:if ($board !~ "RB5009") do={
  :error "This script pack targets RB5009 class hardware only"
}

:put "Precheck passed"
:put "Confirm: WAN on ether1, AP trunk on ether8, admin port on ether9, voice access on ether10"
:put "Upload all .rsc files before running master install"
