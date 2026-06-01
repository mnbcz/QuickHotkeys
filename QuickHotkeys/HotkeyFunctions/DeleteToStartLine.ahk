

deleteToStartLine_SetHotkey(hotkeysJsonItem){
  if (hotkeysJsonItem.isEnable) {
    ; Hotkey "^BackSpace", DeleteToStartLine, "On I1"
    ; sc00E
    Hotkey "^sc00E", deleteToStartLine, "On I1"
    
  }else{
    Hotkey "^sc00E", deleteToStartLine, "Off I1"
  }
}


deleteToStartLine(*){

  Send "^{BackSpace}"
  local CtrlWasUp := KeyWait("BackSpace", "T0.3")
  if(!CtrlWasUp){
    Send "+{Home}"
    Send "{Delete}"
    KeyWait("BackSpace")
  }
}



