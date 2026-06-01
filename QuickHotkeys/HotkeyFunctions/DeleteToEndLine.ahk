
deleteToEndLine_SetHotkey(hotkeysJsonItem){
  if (hotkeysJsonItem.isEnable) {
    ; Hotkey "^BackSpace", DeleteToStartLine, "On I1"
    Hotkey "^sc153", deleteToEndLine, "On I1"
    
  }else{
    Hotkey "^sc153", deleteToEndLine, "Off"
  }
}


deleteToEndLine(*){
  Send "^{Delete}"
  local CtrlWasUp := KeyWait("Delete", "T0.3")
  if(!CtrlWasUp){
    ; Выделяем всё до конца строки.
    Send "+{End}"
    Send "{Delete}"
    KeyWait("Delete")
  }
}



