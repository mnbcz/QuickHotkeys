
#Include ../lib/DateFormat_Variants.ahk

hotStrings_EnableDisable(hotkeysJsonItem){
  global hotkeysActions
  global stickyKeys_

  if (hotkeysJsonItem.isEnable) {
    hotkeysActions.hotStrings := 1
    Hotkey "+sc3", emailKey, "On I1"
    ; На клавишу Backspace не назначен обработчик oneKeyPress().
    ; Назначаем тут.
    ; 08  00E	 	d	1.03	Backspace   
    Hotkey "scE", backSpaceKey, "On I1"

  }else{
    hotkeysActions.hotStrings := 0
    Hotkey "+sc3", emailKey, "Off"
    Hotkey "scE", backSpaceKey, "Off"
  }

  local dateFormat_Variants_ := DateFormat_Variants()
  local timeFormat_FunctionName := hotkeysJsonItem.list.value
  local timeFormat_Function := ObjBindMethod(dateFormat_Variants_, timeFormat_FunctionName)
  global hotStrings_
  ; /.
  hotStrings_.tokens["sc35sc34"] := {value: timeFormat_Function, length: 2}
  hotStrings_.tokens["@@"] := {value: hotkeysJsonItem.hotkeyDisplay, length: 2}

}

; @ - Shift+2.
; 32  003	h	d	6.22	2   
emailKey(*){
  global hotkeysActions
  global hotStrings_

  if(hotkeysActions.hotStrings){
    hotStrings_.add("@")
  }

  SendLevel 0
  Send "+{sc3}"

}

; 08  000E	 	d	1.03	Backspace   
backSpaceKey(*){
  global hotkeysActions
  global hotStrings_

  if(hotkeysActions.hotStrings){
    hotStrings_.add(0)
  }

  SendLevel 0
  Send "{BackSpace}"
}





