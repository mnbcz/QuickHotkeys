; Прокручивает страницу в начало, или в конец, через колесо.

/**
 * Назначение/отключение хоткея.
 * @param {Integer} isEnable 
 * @param {Object} hotkeysJsonItem 
 */
scrollToTopBottomByWheel_SetHotkeys(hotkeysJsonItem){
  global hotkeyList, Modules
  ; Активные хоткей:
  hotkeyList.scrollToStart := hotkeysJsonItem.hotkeyModifiers . "WheelUp"
  hotkeyList.scrollToEnd := hotkeysJsonItem.hotkeyModifiers . "WheelDown"
  
  local upHotkeyId := hotkeysJsonItem.id . "_ToStart"
  local downHotkeyId := hotkeysJsonItem.id . "_ToEnd"

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущие хоткеи.
    disablePrevHotkeys()
    ; Исправляем баг. Включаем изначальные хоткеи.
    Hotkey "^WheelDown", emptyFunc, "On"
    Hotkey "^WheelUp", emptyFunc, "On"

    Hotkey hotkeyList.scrollToStart, scrollToTopByWheel, "On"
    Hotkey hotkeyList.scrollToEnd, scrollToBottomByWheel, "On"
    Modules.Hotkeys.assignedHotkeys[upHotkeyId] := [hotkeyList.scrollToStart, scrollToTopByWheel, "On"]
    Modules.Hotkeys.assignedHotkeys[downHotkeyId] := [hotkeyList.scrollToEnd, scrollToBottomByWheel, "On"]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules

    try{
      Hotkey "^WheelDown", emptyFunc, "Off"
      Hotkey "^WheelUp", emptyFunc, "Off"
    }

    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(upHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[upHotkeyId], scrollToTopByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(upHotkeyId)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(downHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[downHotkeyId], scrollToBottomByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(downHotkeyId)
    }
  }

}

/**
 * Прокручивает страницу вверх.
 * https://www.autohotkey.com/docs/v2/lib/ControlClick.htm
 * https://www.autohotkey.com/docs/v2/lib/ControlSend.htm
 */
scrollToTopByWheel(ThisHotkey){

  ; InstallKeybdHook false, true
  ; SetKeyDelay -1
  ; Sleep 100

  ; Избавляемся от бага, когда зумируется.
  BlockInput("On")

  ; SendEvent "{vk07 Up}"
  ; SetTimer releaseModifiers, -1
  ; Sleep 20

  ; Debug().logF("scrollToTopByWheel")
  Wheel_.up()

  ; ; Активируем активный контрол.
  ; MouseGetPos , , , &activeControl, 3
  ; ; Debug().logF(OutputVarControl)
  ; ; ControlSend "{F6}", activeControl
  ; ; ControlClick activeControl
  ; ControlClick activeControl
  ; Sleep (100)

  ; id window under mouse
  local mouseWinId
  ; id Control under mouse
  local mouseControl
  ; Активируем окно над курсором
  MouseGetPos ,, &mouseWinId, &mouseControl
  try{
    WinActivate(mouseWinId)
    ; SetControlDelay -1
    ; ControlFocus mouseControl, mouseWinId
  }

  ; BlockInput("On")
  ; ControlClick mouseControl, mouseWinId,,,, 'NA'
  ; Send("^{Home}")
  SendEvent("^{Home}")
  ; Избавляемся от бага
  ; Sleep(2)
  ; Send("{LControl Up}")
  ; Sleep(2)
  ; BlockInput("Off")

  Wheel_.waitWheelStop(200)

  ; BlockInput("On")
  ; Send("^{Home}")
  SendEvent("^{Home}")
  ; BlockInput("Off")

  ; Send("{Blind}{LControl Up}")
  ; Send("{Blind}{LShift Up}")
  SetTimer releaseModifiers, -10

  BlockInput("Off")

  ; SetKeyDelay 10

  ; Hotkey ThisHotkey, emptyFunc, "Off"
  ; Hotkey ThisHotkey, scrollToTopByWheel, "On"
  ; Sleep(200)
}


; Go to bottom of Page
scrollToBottomByWheel(ThisHotkey){

  ; SetKeyDelay -1
  ; Sleep 100

  ; Send "{vk07 Up}"
  ; Send "{LCtrl Up}"
  ; Send "{LShift Up}"
  ; InstallKeybdHook false, true

  ; Избавляемся от бага, когда зумируется.
  BlockInput("On")

  ; Hotkey ThisHotkey, "Off"
  ; Hotkey ThisHotkey, emptyFunc, "On"

  Wheel_.up()
  ; Debug().logF("scrollToBottomByWheel")
  
  ; ; Активируем активный контрол.
  ; MouseGetPos , , , &activeControl, 3
  ; ; Debug().logF(OutputVarControl)
  ; ; ControlSend "{F6}", activeControl
  ; ControlClick activeControl
  ; Sleep (100)

  ; id window under mouse
  local mouseWinId
  ; id Control under mouse
  local mouseControl
  ; Активируем окно над курсором
  MouseGetPos ,, &mouseWinId, &mouseControl
  try{
    WinActivate(mouseWinId)
    ; SetControlDelay -1
    ; ControlFocus mouseControl, mouseWinId
  }

  ; ControlClick mouseControl, mouseWinId,,,, 'NA'
  ; BlockInput("On")
  ; Send("^{End}")
  SendEvent("^{End}")

  ; Избавляемся от бага
  ; Send("{LControl Up}")
  ; Sleep(200)
  ; BlockInput("Off")

  Wheel_.waitWheelStop(200)

  ; Send("{Blind}{LControl Up}")
  ; Send("{Blind}{LShift Up}")
  SetTimer releaseModifiers, -1
  ; SetKeyDelay 10

  BlockInput("Off")

  ; InstallKeybdHook true, true
  ; Hotkey ThisHotkey, emptyFunc, "Off"
  ; Hotkey ThisHotkey, scrollToBottomByWheel, "On"
}
