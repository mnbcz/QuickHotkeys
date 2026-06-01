

closeWindow(*){

  BlockInput("On")
	; Activate Window on hover
	MouseGetPos(, , &hWnd)
	WinActivate("ahk_id " hWnd)
	Send("!{F4}")
  BlockInput("Off")
	return
}
