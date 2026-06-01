
; Клавиша модификатор для листания вкладок (LShift).
global nextPrevTab_mod
; Клавиша модификатор для листания вкладок, символ (^+).
global nextPrevTab_modSymbol

; Для функции SendEvent(). Для исправления бага.
; На функциях Send() это не работает.
; A_HotkeyModifierTimeout := 100

/**
 * Browser hotkeys: https://support.mozilla.org/en-US/kb/keyboard-shortcuts-perform-firefox-tasks-quickly#w_windows-tabs
 * @param {Object} hotkeysJsonItem 
 */
nextPreviousTabByWheel_SetHotkeys(hotkeysJsonItem){
  global hotkeyList
  hotkeyList.prevTabByWheel := hotkeysJsonItem.hotkeyModifiers . "WheelUp"
  hotkeyList.nextTabByWheel := hotkeysJsonItem.hotkeyModifiers . "WheelDown"

  local hotkeyUpId := hotkeysJsonItem.id . "_ToStart"
  local hotkeyDownId := hotkeysJsonItem.id . "_ToEnd"

  global nextPrevTab_mod
  local mods := getModifiers(hotkeysJsonItem.hotkeyModifiers)
  nextPrevTab_mod := mods[1]
  global nextPrevTab_modSymbol
  nextPrevTab_modSymbol := hotkeysJsonItem.hotkeyModifiers
  
  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    ; Hotkey hotkeyList.prevTabByWheel, scrollTabsBy_ModWheel, "On I2"
    ; Hotkey hotkeyList.nextTabByWheel, scrollTabsBy_ModWheel, "On I2"
    Hotkey hotkeyList.prevTabByWheel, scrollTabsBy_ModWheel, "On"
    Hotkey hotkeyList.nextTabByWheel, scrollTabsBy_ModWheel, "On"
    Modules.Hotkeys.assignedHotkeys[hotkeyUpId] := [hotkeyList.prevTabByWheel, scrollTabsBy_ModWheel, "On"]
    Modules.Hotkeys.assignedHotkeys[hotkeyDownId] := [hotkeyList.nextTabByWheel, scrollTabsBy_ModWheel, "On"]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeyUpId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeyUpId], scrollTabsBy_ModWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeyUpId)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeyDownId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeyDownId], scrollTabsBy_ModWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeyDownId)
    }
  }

}

/**
 * Shift+Wheel
 * @param ThisHotkey 
 * prevTabByWheel(ThisHotkey){
 * 
 */
scrollTabsBy_ModWheel(ThisHotkey){

  global nextPrevTab_mod
  ; MsgBox ThisHotkey

  global Wheel_

  Wheel_.downStack := []
  Wheel_.upStack := []

  disableAllHotkeys()

  ; Hotkey(nextPrevTab_modSymbol . "WheelDown", scrollTabsBy_ModWheel, "Off")
  ; Hotkey(nextPrevTab_modSymbol . "WheelUp", scrollTabsBy_ModWheel, "Off")
  ; Hotkey("RButton", "Off")

  Hotkey(nextPrevTab_modSymbol . "RButton", emptyFunc, "On")
  Hotkey(nextPrevTab_modSymbol . "LButton", emptyFunc, "On")

  Hotkey("*WheelDown", (*) => Wheel_.down(), "On T2")
  Hotkey("*WheelUp", (*) => Wheel_.up(), "On T2")

  ; Возвращает True если в строке ThisHotkey найдено подстрока WheelDown.
  ; Строка ThisHotkey не изменяется.
  if ThisHotkey ~= "WheelDown"{
    Wheel_.down()
  }
  if ThisHotkey ~= "WheelUp"{
    Wheel_.up()
  }

  while GetKeyState(nextPrevTab_mod, "P"){

    ; Было кручение колеса вниз
    if(Wheel_.downStack.Length > 0){  
      nextTabByRButtonWheel(ThisHotkey)
      Wheel_.waitWheelStop()
      Wheel_.downStack := []
    }

    ; Было кручение колеса вверх
    if(Wheel_.upStack.Length > 0){  
      prevTabByRButtonWheel(ThisHotkey)
      Wheel_.waitWheelStop()
      Wheel_.upStack := []
    }

    if(GetKeyState(nextPrevTab_mod, "P") && GetKeyState("LButton", "P")){
      ; SetTimer goToFirstTab, -1
      goToFirstTab()
      KeyWait "LButton"
      Sleep 100
    }
    if(GetKeyState(nextPrevTab_mod, "P") && GetKeyState("RButton", "P")){
      ; SetTimer goToLastTab, -1
      goToLastTab()
      KeyWait "RButton"
      Sleep 100
    }

    ; Sleep 10
  }

  resetHotkeys(){
    Hotkey("*WheelDown", "Off")
    Hotkey("*WheelUp", "Off")

    ; Hotkey(nextPrevTab_modSymbol . "WheelDown", scrollTabsBy_ModWheel, "On")
    ; Hotkey(nextPrevTab_modSymbol . "WheelUp", scrollTabsBy_ModWheel, "On")
    ; Hotkey("RButton", "On")
    enableAllHotkeys()

    Hotkey(nextPrevTab_modSymbol . "RButton", emptyFunc, "Off")
    Hotkey(nextPrevTab_modSymbol . "LButton", emptyFunc, "Off")
    ; Hotkey("*LButton", emptyFunc, "Off")
    ; Hotkey("RButton Up", emptyFunc, "Off")

    Wheel_.downStack := []
    Wheel_.upStack := []
  }
  resetHotkeys()

  ; Отжимаем залипшие клавиши.
  releaseModifiers_Timeout()

}



; /**
;  * Переходит на последнюю вкладку, при долгом удержании RButton.
;  */
; goToLastTab(){

;   local waitStart := A_TickCount
;   ; Нужна пауза, чтобы переходило на последнюю вкладку
;   Sleep 40
;   ; Send "{Blind}{LShift Down}"

;   global nextPrevTab_mod
;   ; Нужно проверять ещё и LShift, а то переходит на последнюю вкладку.
;   while GetKeyState("RButton", "P") && GetKeyState(nextPrevTab_mod, "P"){
;   ; while GetKeyState("RButton", "P"){
;     if(A_TickCount - waitStart > 400){
;       BlockInput("On")
;       SendEvent "^{9}"
;       BlockInput("Off")
;       KeyWait("RButton")
;       break  
;     }
;     Sleep 20
;   }
; }


/**
 * Переходит на последнюю вкладку, при долгом удержании RButton.
; */
; goToFirstTab(){
;   global nextPrevTab_mod

;   local waitStart := A_TickCount
;   ; Нужна пауза, чтобы переходило на последнюю вкладку
;   Sleep 40
;   Send "{Blind}{" . nextPrevTab_mod . " Down}"

;   ; Нужно проверять ещё и LShift, а то переходит на последнюю вкладку.
;   while GetKeyState("LButton", "P") && GetKeyState(nextPrevTab_mod, "P"){
;   ; while GetKeyState("RButton", "P"){
;     if(A_TickCount - waitStart > 400){
;       BlockInput("On")
;       SendEvent "^{1}"
;       BlockInput("Off")
;       KeyWait("LButton")
;       break  
;     }
;     Sleep 20
;   }
; }

/**
 * Переходит на первую вкладку.
 */
goToFirstTab(){
  BlockInput("On")
  ; SendEvent "^{1}"
  Send "^{1}"
  BlockInput("Off")
  ; Какой-то глюк, отключает листание.
  ; Sleep 30
}

/**
 * Переходит на последнюю вкладку.
 */
goToLastTab(){
  BlockInput("On")
  ; SendEvent "^{9}"
  Send "^{9}"

  ; SendEvent "{Blind}{RButton Up}"
  ; Send "{Blind}{RButton Up}"
  ; Sleep 60
  BlockInput("Off")
  ; Какой-то глюк, отключает листание.
}











