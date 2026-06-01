; Прокручивает страницу в начало, или в конец, через колесо.

/**
 * Назначение/отключение хоткея.
 * @param {Integer} isEnable 
 * @param {Object} hotkeysJsonItem 
 */
scrollSelectByWheel_SetHotkeys(hotkeysJsonItem){
  global hotkeyList, Modules
  ; Активные хоткей:
  hotkeyList.scrollSelectToStart := hotkeysJsonItem.hotkeyModifiers . "WheelUp"
  hotkeyList.scrollSelectToEnd := hotkeysJsonItem.hotkeyModifiers . "WheelDown"
  
  local upHotkeyId := hotkeysJsonItem.id . "_ToStart"
  local downHotkeyId := hotkeysJsonItem.id . "_ToEnd"

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущие хоткеи.
    disablePrevHotkeys()
    ; Включаем активные хоткеи.
    Hotkey hotkeyList.scrollSelectToStart, scrollSelectUpByWheel, "On"
    Hotkey hotkeyList.scrollSelectToEnd, scrollSelectDownByWheel, "On"
    Modules.Hotkeys.assignedHotkeys[upHotkeyId] := [hotkeyList.scrollSelectToStart, scrollSelectUpByWheel, "On"]
    Modules.Hotkeys.assignedHotkeys[downHotkeyId] := [hotkeyList.scrollSelectToEnd, scrollSelectDownByWheel, "On"]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(upHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[upHotkeyId], scrollSelectUpByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(upHotkeyId)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(downHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[downHotkeyId], scrollSelectDownByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(downHotkeyId)
    }
  }

}

/**
 * Прокручивает страницу вверх.
 */
scrollSelectUpByWheel(*){

  BlockInput("On")
  ; id window under mouse
  local mouseWinId
  ; Активируем окно над курсором
  MouseGetPos ,, &mouseWinId
  WinActivate(mouseWinId)
  Send("{Blind}+^{Home}")
  ; Избавляемся от бага
  Send("{Blind}{LControl Up}")
  Send("{Blind}{LShift Up}")
  Sleep(100)
  BlockInput("Off")
}

; Go to bottom of Page
scrollSelectDownByWheel(*){

  BlockInput("On")
  ; id window under mouse
  local mouseWinId
  ; Активируем окно над курсором
  MouseGetPos ,, &mouseWinId
  WinActivate(mouseWinId)
  Send("{Blind}+^{End}")
  ; Избавляемся от бага
  ; Sleep(10)
  Send("{Blind}{LControl Up}")
  Send("{Blind}{LShift Up}")
  Sleep(100)
  BlockInput("Off")
}

