; Зумирует страницу, через колесо.

; Первый модификатор, который удерживается, чтобы крутить.
global zoomByWheel_mod

/**
 * Назначение/отключение хоткея.
 * @param {Integer} isEnable 
 * @param {Object} hotkeysJsonItem 
 */
zoomByWheel_SetHotkeys(hotkeysJsonItem){
  global hotkeyList, Modules
  ; Название id хоткея - ключ, и значение - хоткей:
  hotkeyList.zoomByWheelUp := hotkeysJsonItem.hotkeyModifiers . "WheelUp"
  hotkeyList.zoomByWheelDown := hotkeysJsonItem.hotkeyModifiers . "WheelDown"
  
  local upHotkeyId := hotkeysJsonItem.id . "_ToStart"
  local downHotkeyId := hotkeysJsonItem.id . "_ToEnd"

  global zoomByWheel_mod
  local mods := getModifiers(hotkeysJsonItem.hotkeyModifiers)
  zoomByWheel_mod := mods[1]

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущие хоткеи.
    disablePrevHotkeys()
    ; Включаем активные хоткеи.
    Hotkey hotkeyList.zoomByWheelDown, zoomByWheel, "On"
    Hotkey hotkeyList.zoomByWheelUp, zoomByWheel, "On"
    Modules.Hotkeys.assignedHotkeys[downHotkeyId] := [hotkeyList.zoomByWheelDown, zoomByWheel, "On"]
    Modules.Hotkeys.assignedHotkeys[upHotkeyId] := [hotkeyList.zoomByWheelUp, zoomByWheel, "On"]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(downHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[downHotkeyId], zoomByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(downHotkeyId)
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(upHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[upHotkeyId], zoomByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(upHotkeyId)  
    }
  }

}

; /**
;  * Зумирует страницу.
;  */
; zoomByWheel(ThisHotkey){

;   global Wheel_, hotkeyList
  
;   ; Debug().logF("zoomByWheel()")

;   ; BlockInput("On")
  
;   ; Hotkey(ThisHotkey, "Off")

;   ; try{
;   ;   Hotkey(hotkeyList.zoomByWheelDown, "Off")
;   ;   Hotkey(hotkeyList.zoomByWheelUp, "Off")
;   ; }

;   disableAllHotkeys()

;   ; Sleep 20
  
;   ; Hotkey("WheelDown", emptyFunc, "On")
;   ; Hotkey("WheelUp", emptyFunc, "On")
;   Hotkey("*WheelDown", emptyFunc, "On")
;   Hotkey("*WheelUp", emptyFunc, "On")
  
;   Hotkey("*WheelDown", (*) => Wheel_.down(), "On T2")
;   Hotkey("*WheelUp", (*) => Wheel_.up(), "On T2")

;   Wheel_.downStack := []
;   Wheel_.upStack := []
;   Wheel_.timeStack := []

;   if(RegExMatch(ThisHotkey, "WheelDown")){
;     Wheel_.down()
;   }
;   if(RegExMatch(ThisHotkey, "WheelUp")){
;     Wheel_.up()
;   }

;   while GetKeyState(zoomByWheel_mod, "P"){
;     ; Было кручение колеса вниз
;     if(Wheel_.downStack.Length > 0){  
;       SendEvent("^{WheelDown}")
;       ; Sleep 4
;       Wheel_.downStack := []
;       continue
;     }
;     ; Было кручение колеса вверх. 
;     if(Wheel_.upStack.Length > 0){  

;       SendEvent("^{WheelUp}")
;       ; Sleep 4
;       ; BlockInput("Off")
;       Wheel_.upStack := []
;       ; continue
;     }

;     Sleep 1
;   }

  
;   ; Hotkey("WheelDown", emptyFunc, "Off")
;   ; Hotkey("WheelUp", emptyFunc, "Off")
;   Hotkey("*WheelDown", emptyFunc, "Off")
;   Hotkey("*WheelUp", emptyFunc, "Off")
  
;   Hotkey("*WheelDown", "Off")
;   Hotkey("*WheelUp", "Off")

;   ; Hotkey(hotkeyList.zoomByWheelDown, "On")
;   ; Hotkey(hotkeyList.zoomByWheelUp, "On")

;   enableAllHotkeys()

;   ; Hotkey(ThisHotkey, "On")
  
;   ; BlockInput("Off")
;   Sleep 10
;   ; Избавляемся от бага
;   ; SendEvent("{Blind}{LControl Up}")
;   ; SendEvent("{Blind}{LShift Up}")
;   ; SendEvent("{Blind}{LAlt Up}")
;   SetTimer releaseModifiers, -10
; }

/**
 * Зумирует страницу.
 */
zoomByWheel(ThisHotkey){

  BlockInput("On")

  if(RegExMatch(ThisHotkey, "WheelDown")){
    SendEvent("^{WheelDown}")
  }
  if(RegExMatch(ThisHotkey, "WheelUp")){
    SendEvent("^{WheelUp}")
  }

  BlockInput("Off")
  Sleep 10
  ; Избавляемся от бага
  ; SendEvent("{LControl Up}")
  ; SendEvent("{LControl Up}")
  ; SendEvent("{Blind}{LShift Up}")
  ; SendEvent("{Blind}{LAlt Up}")
  SetTimer releaseModifiers, -10
}
