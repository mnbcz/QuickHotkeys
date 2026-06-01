; Прокручивает страницу в начало, или в конец, через колесо.

global scrollHorizontal_mod

/**
 * Назначение/отключение хоткея.
 * @param {Integer} isEnable 
 * @param {Object} hotkeysJsonItem 
 */
scrollHorizontal_SetHotkeys(hotkeysJsonItem){
  global hotkeyList, Modules
  ; Активные хоткей:
  hotkeyList.scrollHorizontalUp := hotkeysJsonItem.hotkeyModifiers . "WheelUp"
  hotkeyList.scrollHorizontalDown := hotkeysJsonItem.hotkeyModifiers . "WheelDown"
  
  local upHotkeyId := hotkeysJsonItem.id . "_ToStart"
  local downHotkeyId := hotkeysJsonItem.id . "_ToEnd"

  global scrollHorizontal_mod
  local mods := getModifiers(hotkeysJsonItem.hotkeyModifiers)
  scrollHorizontal_mod := mods[1]

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущие хоткеи.
    disablePrevHotkeys()
    ; Включаем активные хоткеи.
    Hotkey hotkeyList.scrollHorizontalDown, scrollHorizontalAll, "On"
    Hotkey hotkeyList.scrollHorizontalUp, scrollHorizontalAll, "On"
    Modules.Hotkeys.assignedHotkeys[downHotkeyId] := [hotkeyList.scrollHorizontalDown, scrollHorizontalAll, "On"]
    Modules.Hotkeys.assignedHotkeys[upHotkeyId] := [hotkeyList.scrollHorizontalUp, scrollHorizontalAll, "On"]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(downHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[downHotkeyId], scrollHorizontalAll, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(downHotkeyId)
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(upHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[upHotkeyId], scrollHorizontalAll, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(upHotkeyId)  
    }
  }

}

/**
 * Прокручивает страницу вверх.
 */
scrollHorizontalAll(ThisHotkey){

  global Wheel_
  
  BlockInput("On")
  
  Hotkey(ThisHotkey, "Off")
  ; Sleep 20
  
  Hotkey("WheelDown", emptyFunc, "On")
  Hotkey("WheelUp", emptyFunc, "On")
  Hotkey("*WheelDown", emptyFunc, "On")
  Hotkey("*WheelUp", emptyFunc, "On")
  
  Hotkey("*WheelDown", (*) => Wheel_.down(), "On T2")
  Hotkey("*WheelUp", (*) => Wheel_.up(), "On T2")

  Wheel_.downStack := []
  Wheel_.upStack := []
  Wheel_.timeStack := []

  if(RegExMatch(ThisHotkey, "WheelDown")){
    Wheel_.down()
  }
  if(RegExMatch(ThisHotkey, "WheelUp")){
    Wheel_.up()
  }

  while GetKeyState(scrollHorizontal_mod, "P"){
    ; Было кручение колеса вниз
    if(Wheel_.downStack.Length > 0){  
      SendLevel 0
      ; while Wheel_.downStack.Length {
      ;   SendEvent("+{WheelDown }" . )
      ;   Wheel_.downStack.Pop()
      ; }
      ; Debug().logF(Wheel_.downStack.Length . ", clickTime = " . Wheel_.getSpeed())

      local speed := 3
      ; local getSpeed := Wheel_.getSpeed() 
      ; if(getSpeed < 40 && getSpeed != 0){
      ;   speed := 6 
      ; }

      SendEvent("+{WheelDown " . speed . "}")
      Sleep 4
      Wheel_.downStack := []

      ; BlockInput("Off")
      ; Wheel_.downStack := []
      ; continue
    }
    ; Было кручение колеса вверх. 
    if(Wheel_.upStack.Length > 0){  
      ; BlockInput("On")
      SendLevel 0
      local speed := 3
      ; local getSpeed := Wheel_.getSpeed() 
      ; if(getSpeed < 40 && getSpeed != 0){
      ;   speed := 6
      ; }

      SendEvent("+{WheelUp " . speed . "}")
      Sleep 4
      ; BlockInput("Off")
      Wheel_.upStack := []
      ; continue
    }

    Sleep 1
  }

  
  Hotkey("WheelDown", emptyFunc, "Off")
  Hotkey("WheelUp", emptyFunc, "Off")
  Hotkey("*WheelDown", emptyFunc, "Off")
  Hotkey("*WheelUp", emptyFunc, "Off")
  
  Hotkey("*WheelDown", "Off")
  Hotkey("*WheelUp", "Off")
  Hotkey(ThisHotkey, "On")
  

  BlockInput("Off")
  Sleep 10
  ; Избавляемся от бага
  ; SendEvent("{Blind}{LControl Up}")
  ; SendEvent("{Blind}{LShift Up}")
  ; SendEvent("{Blind}{LAlt Up}")
  SetTimer releaseModifiers, -10
}



; Go to bottom of Page
scrollHorizontalDown(*){
  
  ; BlockInput("On")
  ; id window under mouse
  ; local mouseWinId
  ; Активируем окно над курсором
  ; MouseGetPos ,, &mouseWinId
  ; WinActivate(mouseWinId)
  ; SendEvent("+{WheelDown}")
  Send("+{WheelDown}")
  Sleep 4
  ; BlockInput("Off")
  ; Избавляемся от бага
  SendEvent("{LControl Up}")
  SendEvent("{LShift Up}")
  SendEvent("{LAlt Up}")
  ; SetTimer releaseModifiers, -10
  
}



; Go to bottom of Page
scrollHorizontalUp(*){
  
  ; BlockInput("On")
  ; id window under mouse
  ; local mouseWinId
  ; Активируем окно над курсором
  ; MouseGetPos ,, &mouseWinId
  ; WinActivate(mouseWinId)
  ; SendEvent("+{WheelUp}")
  Send("+{WheelUp}")
  
  Sleep 4
  ; BlockInput("Off")
  ; Избавляемся от бага
  SendEvent("{LControl Up}")
  SendEvent("{LShift Up}")
  SendEvent("{LAlt Up}")
  ; SetTimer releaseModifiers, -10
  
}