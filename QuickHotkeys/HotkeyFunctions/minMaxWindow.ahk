; #Include ../functions.ahk

global Wheel_ := Wheel()


minimizeMaximizeWindowByModAndWheel_SetHotkeys(hotkeysJsonItem){
  global hotkeyList

  local modsFromHotkeyDisplay := getModsFromHotkeyDisplay(hotkeysJsonItem.hotkeyDisplay)
  local modSymbols := Utils.joinArrayToString("", modsFromHotkeyDisplay.symbols)

  hotkeyList.maximizeWindow := modSymbols . "WheelUp"
  hotkeyList.minimizeWindow := modSymbols . "WheelDown"

  local hotkeyUpId := hotkeysJsonItem.id . "_up"
  local hotkeyDownId := hotkeysJsonItem.id . "_down"

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey hotkeyList.maximizeWindow, maximizeWindowByWheel, "On"
    Hotkey hotkeyList.minimizeWindow, minimizeWindowByWheel, "On"
    Modules.Hotkeys.assignedHotkeys[hotkeyUpId] := [hotkeyList.maximizeWindow, maximizeWindowByWheel, "On"]
    Modules.Hotkeys.assignedHotkeys[hotkeyDownId] := [hotkeyList.minimizeWindow, minimizeWindowByWheel, "On"]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeyUpId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeyUpId], maximizeWindowByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeyUpId)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeyDownId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeyDownId], minimizeWindowByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeyDownId)
    }
  }

}


minimizeWindowByWheel(ThisHotkey) {

  disableAllHotkeys()

  local mods := getModifiers(ThisHotkey)
 
  global Wheel_
  Wheel_.downStack := []

  ; Записываем в массив один клик колеса
  Wheel_.down()
  ; Если курсор на Дэсктопе (WorkerW), или на TaskBar (Shell_TrayWnd).
  if (MouseIsOverWindows(["WorkerW", "Shell_TrayWnd"], &winId)) {
    return
  }
  ; Курсор скорее всего на окне.

  ; BlockInput("On")
  ; Отключаем эти хоткеи, и подключаем к счётчикам кручения колеса.
  ; try {
  ;   Hotkey(ThisHotkey, minimizeWindowByWheel, "Off")
  ; }
  ; try{
  ;   Hotkey(hotkeyList.maximizeWindow, maximizeWindowByWheel, "Off")
  ; }

  Hotkey(ThisHotkey, (*) => Wheel_.down(), "On T2")
  Hotkey(hotkeyList.maximizeWindow, (*) => Wheel_.up(), "On T2")

  local winMinMax := WinGetMinMax("ahk_id " winId)
  local isFullScreen := isWindowFullScreen("A")

  ; BlockInput("Off")

  ; Окно в Full Screen, или развёрнуто на весь экран.
  if (isFullScreen || winMinMax) {
    ; Проверяем сколько было кручений колеса.
    ; Ждём пока колесо с первой прокрутки остановится. 120
    Wheel_.waitWheelStop(120)
    ; Если будут ещё кручения колеса, то они будут в этом массиве.
    Wheel_.downStack := []

    ; Ждём пока модификатор отожмётся
    ; While GetKeyState("LShift", "P") || GetKeyState("LWin", "P") ||
    ;   GetKeyState("LControl", "P") || GetKeyState("LAlt", "P") ||
    ;   GetKeyState("RButton", "P") {
    ;   Sleep(20)
    ; }
    While GetKeyState(mods[1], "P") || GetKeyState("RButton", "P") {
      Sleep(20)
    }

    ; Если было два кручения колеса.
    ; Одно было при старте функции.
    if (Wheel_.downStack.Length >= 1) {
      if (isFullScreen) {
        ; Сворачиваем на TaskBar.
        minimizeWindow(winId)
      } else if (winMinMax) {
        ; Сворачиваем на TaskBar.
        minimizeWindow(winId)
      }
    } else {
      ; Было одно кручение колеса.
      if (isFullScreen) {
        ; Окно в Full Screen. Выходим из Full Screen.
        Send("{F11}")
      } else if (winMinMax) {
        ; Окно развёрнуто на весь экран. Возвращаем к прежднему виду.
        WinRestore("ahk_id " winId)
      }
    }

  } else {
    ; Окно не развёрнуто на весь экран. Сворачиваем на TaskBar.
    minimizeWindow(winId)
  }

  
  ; Ждём остановки колеса
  Wheel_.waitWheelStop(200)
  
  ; BlockInput("On")
  ; Восстанавливаем хоткеи
  Hotkey(ThisHotkey, "Off")
  Hotkey(hotkeyList.maximizeWindow, "Off")

  ; Hotkey(ThisHotkey, minimizeWindowByWheel, "On")
  ; Hotkey(hotkeyList.maximizeWindow, maximizeWindowByWheel, "On")

  global stickyKeys_
  releaseModifiers_Timeout()
  try{
    stickyKeys_.modsPressed.Delete("sc15B")
  }

  enableAllHotkeys()

}


maximizeWindowByWheel(ThisHotkey) {

  ; local modsHotkeyStr := Modules.Hotkeys.assignedHotkeys["minimizeMaximizeWindowByModWheel_ToStart"]

  disableAllHotkeys()

  local mods := getModifiers(ThisHotkey)
  ; Расстояние до края экрана.
  local gapToEdge := 10

  if(!GetKeyState(mods[1], "P")){
    return
  }

  ; Отключаем эти хоткеи, и подключаем к счётчикам кручения колеса.
  ; try {
  ;   Hotkey(hotkeyList.minimizeWindow, minimizeWindowByWheel, "Off")
  ;   ; Hotkey(hotkeyList.maximizeWindow, maximizeWindowByWheel, "Off")
  ;   Hotkey(ThisHotkey, maximizeWindowByWheel, "Off")
  ; }

  Hotkey(hotkeyList.minimizeWindow, (*) => Wheel_.down(), "On T2")
  Hotkey(ThisHotkey, (*) => Wheel_.up(), "On T2")

  Wheel_.up()

  ; id окна где курсор
  MouseGetPos(&xCur, &yCur, &winId, &activeControl)
  
  local cursorIsOnEdge := false
  if (xCur <= gapToEdge || xCur >= A_ScreenWidth - gapToEdge){
    cursorIsOnEdge := true
  }
  if (yCur <= gapToEdge || yCur >= A_ScreenHeight - gapToEdge){
    cursorIsOnEdge := true
  }

  local isFullScreen := isWindowFullScreen("ahk_id " winId)

   ; Если курсор на Дэсктопе (WorkerW), или на TaskBar (Shell_TrayWnd).
  ; Разворачиваем окно из TaskBar.
  if (MouseIsOverWindows(["WorkerW", "Shell_TrayWnd"], &winId) || isFullScreen || cursorIsOnEdge) {
    ; Разворачиваем из TaskBar недавнее окно.
    restoreLastMinimizedWindow(true)
    ; Ждём остановки колеса
    Wheel_.waitWheelStop(160)
  } else {
    ; Курсор скорее всего на окне (не на дэсктопе).
    local winMinMax := WinGetMinMax("ahk_id " winId)
    ; isFullScreen := isWindowFullScreen("A")
    ; MsgBox % isFullScreen ? "Full Screen" : "Windowed"

    if not isFullScreen {
      ; Это окно не в Full Screen.
      ; Начать отсчёт кликов колеса вверх. Одно уже было.
      ; Ждём пока колесо с первой прокрутки остановится. 120
      Wheel_.waitWheelStop(120)
      ; Если будут ещё кручения колеса, то они будут в этом массиве.
      Wheel_.upStack := []

      While GetKeyState(mods[1], "P") || GetKeyState("RButton", "P") {
        Sleep(20)
      }

      if winMinMax {
        ; Окно развёрнуто на весь экран. Переходим в Full Screen.
        WinActivate "ahk_id " winId
        BlockInput("On")
        ; Send("{F11}")
        SendEvent("{F11}")
        BlockInput("Off")
      } else {
        ; Окно не развёрнуто на весь экран.
        ; Переходим в FullScreen если было два кручения колеса.
        if (Wheel_.upStack.Length >= 1) {
          WinActivate "ahk_id " winId
          BlockInput("On")
          ; Send("{F11}")
          SendEvent("{F11}")
          BlockInput("Off")

        } else {
          ; logF("1")
          ; Было одно кручение колеса.
          ; Разворачиваем на весь экран.
          WinMaximize("ahk_id " winId)
        }
      }

      ; BlockInput("On")
    } else {
      ; Это Full Screen.
    }

  }

  ; BlockInput("On")

  ; Восстанавливаем хоткеи
  Hotkey(hotkeyList.minimizeWindow, "Off")
  ; Hotkey(hotkeyList.maximizeWindow, "Off")
  Hotkey(ThisHotkey, "Off")

  ; Hotkey(hotkeyList.minimizeWindow, minimizeWindowByWheel, "On")
  ; Hotkey(hotkeyList.maximizeWindow, maximizeWindowByWheel, "On")
  ; Hotkey(ThisHotkey, maximizeWindowByWheel, "On")

  ; 5B  15B	 	d	1.61	LWin  
  global stickyKeys_
  releaseModifiers_Timeout()
  try{
    stickyKeys_.modsPressed.Delete("sc15B")
  }

  enableAllHotkeys()

}

; -------------------------------------------------------------------------------------


minimizeWindowBy_RButtonAndWheel(ThisHotkey) {

  global Wheel_
  local mods := getModifiers(ThisHotkey)
 
  ; Если курсор на Дэсктопе (WorkerW), или на TaskBar (Shell_TrayWnd).
  if (MouseIsOverWindows(["WorkerW", "Shell_TrayWnd"], &winId)) {
    return
  }

  ; Курсор скорее всего на окне.

  local winMinMax := WinGetMinMax("ahk_id " winId)
  local isFullScreen := isWindowFullScreen("A")

  ; Окно в Full Screen, или развёрнуто на весь экран.
  if (isFullScreen || winMinMax) {
    ; Проверяем сколько было кручений колеса.
    ; Ждём пока колесо с первой прокрутки остановится. 120
    Wheel_.waitWheelStop(120)
    ; Если будут ещё кручения колеса, то они будут в этом массиве.
    Wheel_.downStack := []

    ; Ждём пока модификатор отожмётся
    While GetKeyState(mods[1], "P") || GetKeyState("RButton", "P") {
      Sleep(20)
    }

    ; Если было два кручения колеса.
    ; Одно было при старте функции.
    if (Wheel_.downStack.Length >= 1) {
      if (isFullScreen) {
        ; Сворачиваем на TaskBar.
        minimizeWindow(winId)
      } else if (winMinMax) {
        ; Сворачиваем на TaskBar.
        minimizeWindow(winId)
      }
    } else {
      ; Было одно кручение колеса.
      if (isFullScreen) {
        ; Окно в Full Screen. Выходим из Full Screen.
        Send("{F11}")
      } else if (winMinMax) {
        ; Окно развёрнуто на весь экран. Возвращаем к прежднему виду.
        WinRestore("ahk_id " winId)
      }
    }

  } else {
    ; Окно не развёрнуто на весь экран. Сворачиваем на TaskBar.
    minimizeWindow(winId)
  }

  ; Ждём остановки колеса
  Wheel_.waitWheelStop(200)
  
}



maximizeWindowBy_RButtonAndWheel(ThisHotkey) {

  global Wheel_
  local mods := getModifiers(ThisHotkey)
  ; Расстояние до края экрана.
  local gapToEdge := 10

  ; id окна где курсор
  MouseGetPos(&xCur, &yCur, &winId, &activeControl)

  local isFullScreen := isWindowFullScreen("ahk_id " winId)

  local cursorIsOnEdge := false
  if (xCur <= gapToEdge || xCur >= A_ScreenWidth - gapToEdge){
    cursorIsOnEdge := true
  }
  if (yCur <= gapToEdge || yCur >= A_ScreenHeight - gapToEdge){
    cursorIsOnEdge := true
  }

  ; WinActivate winId

   ; Если курсор на Дэсктопе (WorkerW), или на TaskBar (Shell_TrayWnd).
  ; Разворачиваем окно из TaskBar.
  if (MouseIsOverWindows(["WorkerW", "Shell_TrayWnd"], &winId) || isFullScreen || cursorIsOnEdge) {
    ; Разворачиваем из TaskBar недавнее окно.
    restoreLastMinimizedWindow(true)
    ; Ждём остановки колеса
    ; BlockInput("Off")
    Wheel_.waitWheelStop(200)
    ; BlockInput("On")
  } else {
    ; Курсор скорее всего на окне (не на дэсктопе).
    local winMinMax := WinGetMinMax("ahk_id " winId)
    ; isFullScreen := isWindowFullScreen("A")
    ; MsgBox % isFullScreen ? "Full Screen" : "Windowed"

    if not isFullScreen {
      ; Это окно не в Full Screen.
      ; Начать отсчёт кликов колеса вверх. Одно уже было.
      ; Ждём пока колесо с первой прокрутки остановится. 120
      ; BlockInput("Off")
      Wheel_.waitWheelStop(120)
      ; Если будут ещё кручения колеса, то они будут в этом массиве.
      Wheel_.upStack := []

      ; Ждём пока модификатор отожмётся
      While GetKeyState(mods[1], "P") || GetKeyState("RButton", "P") {
        Sleep(20)
      }

      if winMinMax {
        ; Окно развёрнуто на весь экран. Переходим в Full Screen.
        WinActivate "ahk_id " winId
        BlockInput("On")
        Send("{F11}")
        BlockInput("Off")
      } else {
        ; Окно не развёрнуто на весь экран.
        ; Переходим в FullScreen если было два кручения колеса.
        if (Wheel_.upStack.Length >= 1) {
          WinActivate "ahk_id " winId
          BlockInput("On")
          Send("{F11}")
          BlockInput("Off")

        } else {
          ; logF("1")
          ; Было одно кручение колеса.
          ; Разворачиваем на весь экран.
          WinMaximize("ahk_id " winId)
        }
      }

      ; BlockInput("On")
    } else {
      ; Это Full Screen.
    }

  }
}



; ; Отключаем кручение колеса, и заменяем на Send(WheelDown).
; ; Защита от не одновременного нажатия клавиши и колеса.
; ; Когда клавиша отжимается быстрее чем начинает крутиться колесо.
; ; Добавляет залипание к клавишам, которые назначены вместе с колесом.
; ; Срабатывает на каждом клике колеса.
; ; $ - не срабатывать на Send().
; $WheelUp::
; $WheelDown::
; {
;   ; MsgBox("WheelUp")

;   global modKeyList
;   local StickyTimeoutForWheel := 300

;   ; https://www.autohotkey.com/docs/v1/lib/Send.htm#SendInput
;   ; A_PriorKey - Это меняет значение когда нажимаются кнопки, поэтому нужно сохранить в переменной.
;   ; A_PriorKey - Предыдущая любая кнопка.
;   ; Если предыдущая кнопка была hotkey (например Shift+z), то это значение будет последней нажатой
;   ; кнопки - z.
;   ; A_PriorKey - будет z, а не $z
;   local priorKey := A_PriorKey
;   local thisHotkeyName := StrReplace(A_ThisHotkey, "$")

;   ; Предыдущая клавиша (хоткей), такая же как и эта
;   if (A_ThisHotkey = A_PriorHotkey) {
;     ; Крутим колесо
;     Send("{" . thisHotkeyName . "}")
;     return
;   }

;   local lastPressedModsMap := getPressedModKeys()
;   local lastPressedMods := lastPressedModsMap["Keys"]

;   ; A_PriorKey = LControl, 5469 s. (0 ms.)
;   ; A_PriorKey = LShift, 8281 s. (2812 ms.)
;   ; A_PriorKey = LWin, 13313 s. (5032 ms.)
;   ; A_PriorKey = LAlt, 15922 s. (2609 ms.)

;   local priorKeyVK := Format("vk{:X}", GetKeyVK(priorKey))

;   ; local A_ThisHotkey_Replace := StrReplace(A_ThisHotkey, "$")
;   ; local A_ThisHotkey_Replace := StrReplace(A_ThisHotkey_Replace, "*")
;   ; local A_ThisHotkey_Replace := Format("vk{:X}", GetKeyVK(A_ThisHotkey_Replace))

;   ; vkA2 - LControl
;   ; Предыдущая клавиша была LControl, и время прошло не больше чем
;   if (lastPressedMods.Length = 1 &&
;     priorKeyVK = "vkA2" &&
;     lastPressedMods[1] = "vkA2" &&
;     A_TimeSincePriorHotkey < StickyTimeoutForWheel
;   ) {
;     ; MsgBox("T")
;     SendLevel(1)
;     Send("^{" . thisHotkeyName . "}")

;     return
;   }

;   ; vkA0 - LShift
;   ; A0  02A	 	u	0.12	LShift
;   if (lastPressedMods.Length = 1 &&
;     priorKeyVK = "vkA0" &&
;     lastPressedMods[1] = "vkA0" &&
;     A_TimeSincePriorHotkey < StickyTimeoutForWheel
;   ) {
;     SendLevel(1)
;     Send("+{" . thisHotkeyName . "}")
;     return
;   }

;   ; Предыдущая клавиша не модификатор, или прошёл таймаут:

;   Send("{" . thisHotkeyName . "}")

;   ; BlockInput("Off")

; }

