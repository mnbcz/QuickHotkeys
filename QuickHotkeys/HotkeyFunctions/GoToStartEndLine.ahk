

GoToStartEndLine_SetHotkey(hotkeysJsonItem){
  if (hotkeysJsonItem.isEnable) {
    Hotkey "*<^Left", GoToStartLine, "On"
    Hotkey "*<^Right", GoToEndLine, "On"
  }else{
    Hotkey "*<^Left", GoToStartLine, "Off"
    Hotkey "*<^Right", GoToEndLine, "Off"
  }
}


GoToStartLine(*){

  local Shift := ""
  if(GetKeyState("Shift", "P")){
    Shift .= "+"
  }
  Send  Shift . "^{Left}"
  local CtrlWasUp := KeyWait("Left", "T0.3")
  if(!CtrlWasUp){
    Send Shift . "{Home}"
    KeyWait("Left")
  }
}


GoToEndLine(*){

  local Shift := ""
  if(GetKeyState("Shift", "P")){
    Shift .= "+"
  }
  Send Shift . "^{Right}"
  local CtrlWasUp := KeyWait("Right", "T0.3")
  if(!CtrlWasUp){
    Send Shift . "{End}"
    KeyWait("Right")
  }
}



