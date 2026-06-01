

holdingLeftRightKey_EnableDisable(hotkeysJsonItem){
  global hotkeysActions
  if (hotkeysJsonItem.isEnable) {
    hotkeysActions.holdingLeftRightKey := {}
    hotkeysActions.holdingLeftRightKey.timeout := Integer(hotkeysJsonItem.hotkeyDisplay)
  }else{
    hotkeysActions.holdingLeftRightKey := 0
  }
}


/**
 * Если клавиша нажимается быстро, отсылает эту клавишу.
 * Если клавиша удерживается долго, то отсылает Ctrl+Key.
 * @param leftOrRightKey - Клавиша.
 */
sendLeftOrRightKey_plus_Ctrl_whenHolding(leftOrRightKey){

 global hotkeysActions
  ; Удержание LeftRightKey отключено.
  if(hotkeysActions.holdingLeftRightKey == 0){
    Send "{" . leftOrRightKey . "}"
    return
  }

  ; Кэширование вызовов функций.
  static cash := {lastCallTime: 0}
  if(A_TickCount - cash.lastCallTime > 1000){
    cash.isExpire := true
  }else{
    cash.isExpire := false
  }
  cash.lastCallTime := A_TickCount

  if(cash.isExpire){
    try{
      ; local ahk_class := WinGetClass("A")
      local ahk_exe := WinGetProcessName("A")
      ; cash.ahk_class := ahk_class
      cash.ahk_exe := ahk_exe
    }
  }else{
    ; local ahk_class := cash.ahk_class
    local ahk_exe := cash.ahk_exe
  }

  if(!IsSet(ahk_exe)){
    sendKeyPress(leftOrRightKey)
    return
  }

  switch ahk_exe {
    case "firefox.exe", "chrome.exe", "zen.exe", "opera.exe", "msedge.exe":
      goto thisIsBrowser
    default:
      ; Это не браузер.
      sendKeyPress(leftOrRightKey)
      return
  }

  ; if(ahk_class != "Chrome_WidgetWin_1" && ahk_class != "MozillaWindowClass"){
  ; }
  ; Это браузер:

  thisIsBrowser:

  if(cash.isExpire){
    ; Курсор в поле?
    ; local cursorIsBlinking := GetCaretPosEx()
    local cursorIsBlinking := CaretExist()
    cash.cursorIsBlinking := cursorIsBlinking
  }else{
    local cursorIsBlinking := cash.cursorIsBlinking
  }

  ; Debug.log(cursorIsBlinking)
  ; Debug.log(GetCaretPosEx())
  
  ; Курсор в поле.
  if(cursorIsBlinking){
    sendKeyPress(leftOrRightKey)
    return
  }
  ; Курсор не в поле:

  local timeFromCtrlPress := A_TickCount
  local timeFromStartCtrlPress := timeFromCtrlPress

  ; Отсылаем ^{sc14B} с таймаутом, пока клавиша не отожмётся.
  while GetKeyState(leftOrRightKey, "P"){
    if(A_TickCount - timeFromCtrlPress > hotkeysActions.holdingLeftRightKey.timeout ){
      Send "^{" . leftOrRightKey . "}"
      ; Debug.log("Ctrl+arrl")
      timeFromCtrlPress := A_TickCount + 1200
    }
    Sleep 30
  }

  ; Клавиша была быстро отжата:
  if(timeFromCtrlPress == timeFromStartCtrlPress){
      ; Debug.log("arrl")
      Send "{" . leftOrRightKey . "}"
  }

  ; ===================================================================
  ; Functions.
  ; Отправляет обычное нажатие клавиши.
  sendKeyPress(leftOrRightKey){
    Send "{" . leftOrRightKey . "}"
    local isNoTimeout := KeyWait(leftOrRightKey, "T0.23")
    ; Клавиша быстро отжата.
    if(isNoTimeout){
      Send "{" . leftOrRightKey . " Up}"
      return
    }
    sendKeyUntilItWillBeRelease(leftOrRightKey)
    Send "{" . leftOrRightKey . " Up}"
  }

}

; 25  14B	h	d	1.25	Left 
sc14B(){
  global hotkeysActions
  global hotStrings_
  if(hotkeysActions.hotStrings){
    hotStrings_.add("sc14B")
  }
  sendLeftOrRightKey_plus_Ctrl_whenHolding("sc14B")
}

; 27  14D	s	u	0.12	Right          	
sc14D(){
  global hotkeysActions
  global hotStrings_
  if(hotkeysActions.hotStrings){
    hotStrings_.add("sc14D")
  }
  sendLeftOrRightKey_plus_Ctrl_whenHolding("sc14D")
}

; ===================================================================

holdingRepeatSymbols_EnableDisable(hotkeysJsonItem){
  global hotkeysActions
  if (hotkeysJsonItem.isEnable) {
    hotkeysActions.holdingRepeatSymbols := 1
    Hotkey "+scD", plusKey, "On I1"
  }else{
    hotkeysActions.holdingRepeatSymbols := 0
    try{
      Hotkey "+scD", plusKey, "Off"
    }
  }
  global holdingRepeatSymbols_numSymbols := Integer(hotkeysJsonItem.hotkeyDisplay)
}


; BD  00C	s	u	0.14	-              	
scC(){
  global hotkeysActions
  global hotStrings_
  if(hotkeysActions.hotStrings){
    hotStrings_.add("scC")
  }

  if(hotkeysActions.holdingRepeatSymbols == 0){
    Send "{scC}"
    return
  }

  global holdingRepeatSymbols_numSymbols
  local isNoTimeout := KeyWait("scC", "T0.3")
  if(!isNoTimeout){
    ; Клавиша долго удерживается.
    BlockInput "On"
    SendText Utils.strRepeat("-", holdingRepeatSymbols_numSymbols)
    BlockInput "Off"

    KeyWait("scC")
  }else{
    Send "{scC}"
  }
}


; BB  00D	h	d	0.27	=  
scD(){
  global hotkeysActions
  global hotStrings_
  if(hotkeysActions.hotStrings){
    hotStrings_.add("scD")
  }

  if(hotkeysActions.holdingRepeatSymbols == 0){
    Send "{scD}"
    return
  }

  global holdingRepeatSymbols_numSymbols
  local isNoTimeout := KeyWait("scD", "T0.3")
  if(!isNoTimeout){
    ; Клавиша долго удерживается.
    ; SetKeyDelay(0)
    BlockInput "On"
    SendText Utils.strRepeat("=", holdingRepeatSymbols_numSymbols)
    BlockInput "Off"

    KeyWait("scD")
  }else{
    Send "{scD}"
  }
}

; ++++
plusKey(*){

  global hotkeysActions
  global hotStrings_
  if(hotkeysActions.hotStrings){
    hotStrings_.add("+")
  }

  SendLevel 0
  if(hotkeysActions.holdingRepeatSymbols == 0){
    Send "+{scD}"
    return
  }

  global holdingRepeatSymbols_numSymbols
  local isNoTimeout := KeyWait("scD", "T0.3")
  if(!isNoTimeout){
    ; Клавиша долго удерживается.
    BlockInput "On"
    SendText Utils.strRepeat("+", holdingRepeatSymbols_numSymbols)
    BlockInput "Off"
    KeyWait("scD")
  }else{
    Send "+{scD}"
  }
}
    

; ===================================================================

holdingEsc_EnableDisable(hotkeysJsonItem){
  global hotkeysActions
  if (hotkeysJsonItem.isEnable) {
    hotkeysActions.holdingEsc := 1
  }else{
    hotkeysActions.holdingEsc := 0
  }
  global holdingEsc_timeout := Integer(hotkeysJsonItem.hotkeyDisplay)
}

; 1B  001	h	d	1.03	Escape  
sc1(*){

  global hotkeysActions
  global hotStrings_
  if(hotkeysActions.hotStrings){
    hotStrings_.add("sc1")
  }

  SendLevel 0
  ; Если Выключение компьютера клавишей Esc отключена,
  ; то просто нажимаем Esc.
  if(hotkeysActions.holdingEsc == 0){
    Send "{sc1}"
    return
  }

  global holdingEsc_timeout
  local timeoutSec := holdingEsc_timeout / 1000
  local isNoTimeout := KeyWait("sc1", "T" . timeoutSec)
  if(!isNoTimeout){
    ; Клавиша долго удерживается.    
    ; Send "{Blind}{Escape Up}"
    ; BlockInput "On"
    activateDesktop()
    Send "!{F4}"

    ; Ждём когда окно Выключить откроется.
    local shutDownWindow := WinWait("ahk_class #32770 ahk_exe explorer.exe", , 2)
    if(shutDownWindow == 0){
      SendEvent "{LCtrl Up}" 
      SendEvent "{LShift Up}"
      SendEvent "{LAlt Up}" 
      return
    }
    KeyWait("sc1")
    ; Sleep 16
    ; Send "{Down}"
    ; Sleep 16
    ; Send "{Down}"
    ; Sleep 80

    Sleep 20
    Send "{Up}"
    Sleep 80
    Send "{Tab}"
    ; BlockInput "Off"
  }else{
    ; Клавиша Esc удерживается не долго.
    Send "{sc1}"
  }
}


