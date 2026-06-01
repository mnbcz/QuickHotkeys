
; global _MinimizeMaximizeWindowsListener := MinimizeMaximizeWindowsListener()
; _MinimizeMaximizeWindowsListener.startListening()

global activateLastWindows_mod

; Switches between windows
activateLastWindows_SetHotkeys(hotkeysJsonItem){
  global hotkeyList
  local scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))
  global activateLastWindows_mod := hotkeysJsonItem.hotkeyDisplay
  ; 14  03A	h	d	2.59	CapsLock      
  hotkeyList.activateLastWindows := scHotkeyDisplay . " & sc3A"
  hotkeyList.activateLastWindows_bug_fix := "sc3A & " . scHotkeyDisplay

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.activateLastWindows, activateLastWindows, "On")         
    Hotkey(hotkeyList.activateLastWindows_bug_fix, emptyFunc, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.activateLastWindows, activateLastWindows, "On"]
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"] := [hotkeyList.activateLastWindows_bug_fix, emptyFunc, "On"]

  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], activateLastWindows, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id . "_bug_fix") ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"], emptyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_bug_fix")  
    }
  }
}



; Делает предыдущее окно активным
activateLastWindows10(ThisHotkey){

  ; MsgBox "activateLastWindows10()"

  ; BlockInput("On")

  ; MsgBox "activateLastWindows()"
  ; Отключаем этот хоткей, чтобы не вызывалась эта функция снова, при 
  ; удержании хоткея. 
  ; Из-за того что определено внизу скрипта #MaxThreadsPerHotkey 2
  ; Hotkey(ThisHotkey, activateLastWindows, "Off")

  ; Массив отфильтрованных всех окон, где убраны ложные
  local filteredAltTabWins := []
  ; Стартовое активное окно, которое было при нажатии на хоткей.
  local startWinId
  ; Окно которое было активировано этим скриптом, поднято. В данный момент активно.
  local activeWindowId

  ; Массив открытых окон
  local openedWindows := []
  ; Окна которые были активированы. На которых вызывалась функция WinActivate.
  local wasActivatedWindows := []
  ; Число прокрученных окон из списка окон 
  local countScroll := 1

  global Wheel_
  ; Если будут ещё кручения колеса, то они будут в этом массиве.
  Wheel_.downStack := []
  Wheel_.upStack := []

  global hotkeyList
  global Modules

  ; logF("activateLastWindows()")

  ; Запомнить все открытые окна, и их не сворачивать.
  ; 
  ; 1-ый режим - Переключение между последними открытыми окнами.
  ; Это будет бесконечно переключаться между последним открытым окном,
  ; будут открываться только последние 2 окна.
  ; 
  ; 2-ой режим - Чтобы не переключаться бесконечно, нужно первое активное окно
  ; запомнить, и игнорировать, чтобы можно было листать дальше.

  ; Убираем лишние окна.
  filteredAltTabWins := filteredAltTabWindows()

  ; Id активного окна.
  local startWinId
  try{
    startWinId := WinGetID('A')
  }catch as err{
    startWinId := filteredAltTabWins["all"][1].Get("winId")
  }

  ; Это поднимает последнее открытое окно, кроме активного сейчас.
  for k, winMap in filteredAltTabWins["all"]{  
    local winId := winMap.Get("winId") 
    ; Это окно равно стартовому окну?
    if(winId = startWinId){
      continue
    }
    try{
      WinActivate("ahk_id " winId)
    }
    ; Окно которое активно в данный момент
    activeWindowId := winId
    ; Добавляем активированное окно в массив активированных окон.
    wasActivatedWindows.Push(winId)
    ; MsgBox("countScroll = " . countScroll . ", activatedWinId = " . activatedWinId)
    countScroll++
    break
  }

  ; MsgBox(str)
  ; KeyWait("CapsLock")
  ; Ждём отжатия клавиши CapsLock:

  disableAllHotkeys()

  local callbackWheelDown := (*) => Wheel_.down()
  local callbackWheelUp := (*) => Wheel_.up()

  ; Включаем хоткеи кручения колеса.
  Hotkey("*WheelDown", callbackWheelDown, "On T2")
  Hotkey("*WheelUp", callbackWheelUp, "On T2")

  ; Крутим цикл пока CapsLock не отожмётся.
  while GetKeyState("CapsLock", "P"){
    ; While GetKeyState("LShift", "P"){
    if(Wheel_.upStack.Length >= 1){
      ; Было кручение колеса вверх   
      countScroll++
      ; MsgBox("countScroll = " . countScroll . ", activatedWinId = " . activatedWinId)
      ; Активируем следующее окно в списке
      if(countScroll <= filteredAltTabWins["all"].Length){
        local winMap := filteredAltTabWins["all"][countScroll]
        local winId := winMap.Get("winId") 
        try{
          WinActivate("ahk_id " winId)
        }
        ; Окно которое активно в данный момент
        activeWindowId := winId
        ; Добавляем активированное окно в массив активированных окон.
        wasActivatedWindows.Push(winId)
      }else{
        countScroll := 0
      }
      ; Ждём остановки колеса
      Wheel_.waitWheelStop(200)
    }

    if(Wheel_.downStack.Length >= 1){
      ; Было кручение колеса вниз   
      countScroll--
      if(countScroll <= 0){
          countScroll := filteredAltTabWins["all"].Length
      }
      ; Активируем предыдущее окно в списке
      if(countScroll <= filteredAltTabWins["all"].Length){
          local winMap := filteredAltTabWins["all"][countScroll]
          local winId := winMap.Get("winId") 
          try{
            WinActivate("ahk_id " winId)
          }
          ; Окно которое активно в данный момент
          activeWindowId := winId
          ; Добавляем активированное окно в массив активированных окон.
          wasActivatedWindows.Push(winId)
      }else{
          countScroll := 0
      }
      ; Ждём остановки колеса
      Wheel_.waitWheelStop(200)
    }

    Wheel_.downStack := []
    Wheel_.upStack := []

    Sleep(20)
  }

  ; CapsLock отжата, завершаем скрипт.

  ; Если из TaskBar были развёрнуты окна, сворачиваем их обратно.
  ; Перебираем массив окон которые были активированы.
  for(k, restoredWinId in wasActivatedWindows){
      ; Проверяем есть ли это окно в списке открытых окон
      if(!Utils.arrayHasValue(filteredAltTabWins["opened"], restoredWinId)){
          ; Это окно было развёрнуто из Таскбара.
          ; Это активное окно?
          if(activeWindowId != restoredWinId){
              ; Сворачиваем на TaskBar.
              minimizeWindow(restoredWinId)
          }
      }
  }

  Hotkey("*WheelDown", callbackWheelDown, "Off")
  Hotkey("*WheelUp", callbackWheelUp, "Off")

  enableAllHotkeys()

  ; Отжимаем состояние CapsLock (лампочка не горит)
  SetCapsLockState 0
  ; BlockInput("Off")

}


activateLastWindows(ThisHotkey){

  global activateLastWindows_mod

  local wheel := Wheel2()

  disableAllHotkeys()

  wheel.setWheelDownCallback(wheelDownCallback)
  wheel.setWheelUpCallback(wheelUpCallback)

  local wheelDownFunction := (*) => wheel.down()
  local wheelUpFunction := (*) => wheel.up()

  Hotkey "*WheelDown", wheelDownFunction, "On"
  Hotkey "*WheelUp", wheelUpFunction, "On"

  ; Окна на экране, при старте.
  local maximizedWindowsOnStart := 0
  local realAltTabWindows := getRealAltTabWindows(&maximizedWindowsOnStart)
  ; Debug.win(maximized)

  ; Ключ активированного окна, в массиве realAltTabWindows
  local activeWindowKey := 0
  local wheeCallbackPrevCallTime := 0

  LWinCapsLock()

  LWinCapsLock(){
    ; Активируем ближайшее недавнее окно.
    local nextWindow := getNextRealAltTabWindow(realAltTabWindows, &activeWindowKey)
    if(nextWindow){
      try{
        WinActivate("ahk_id " . nextWindow)
      }
    }
  }

  local capsLockIsPressed := true
  while(GetKeyState(activateLastWindows_mod, "P") || GetKeyState("CapsLock", "P")){
    
    if(GetKeyState("CapsLock", "P")){
      if(capsLockIsPressed == false){
        LWinCapsLock()
      }
      capsLockIsPressed := true
    }else{
      capsLockIsPressed := false
    }
    
    Sleep 10
  }


  ; Когда CapsLock отжато:

  ; Активное окно, и все окна которые были на экране, оставляем,
  ; а все остальные - сворачиваем.
  ; realAltTabWindows[activeWindowKey]
  for _, altTabWindow in realAltTabWindows{
    if(!Utils.arrayHasValue(maximizedWindowsOnStart, altTabWindow) &&
       altTabWindow != realAltTabWindows[activeWindowKey]
    ){
      minimizeWindow(altTabWindow)
    }
  }

  Hotkey "*WheelDown", wheelDownFunction, "Off"
  Hotkey "*WheelUp", wheelUpFunction, "Off"

  enableAllHotkeys()
  ; Отжимаем состояние CapsLock (лампочка не горит)
  SetCapsLockState 0

  ; ----------------------------------------
  ; Callbacks
  ; Запомнить все открытые окна. Их сворачивать не нужно.
  ; Окна которые были подняты из Таскбара, и не выбраны, нужно свернуть обратно.

  /**
   * Считает время прошедшее с момента последнего клика колеса.
   * Возвращает true, если нужно ни чего не делать, колесо ещё не остановилось.
   * @returns {Integer} 
   */
  isWheelWait(){
    if(A_TickCount - wheeCallbackPrevCallTime < 100){
      wheeCallbackPrevCallTime := A_TickCount
      return true
    }
    wheeCallbackPrevCallTime := A_TickCount
    return false
  }


  wheelDownCallback(*){
    ; Debug.log("wheelDownCallback()")
    if(isWheelWait()){
      return
    }
     local nextKey := activeWindowKey - 1
    if(realAltTabWindows.Has(nextKey)){
      try{
        WinActivate("ahk_id " . realAltTabWindows[nextKey])
      }
      activeWindowKey := nextKey
    }
  }

  wheelUpCallback(*){
    ; Debug.log("wheelUpCallback()")
    if(isWheelWait()){
      return
    }

    local nextKey := activeWindowKey + 1
    if(realAltTabWindows.Has(nextKey)){
      try{
        WinActivate("ahk_id " . realAltTabWindows[nextKey])
      }
      activeWindowKey := nextKey
    }
  }

}


; ; Делает предыдущее окно активным
; ; https://www.autohotkey.com/boards/viewtopic.php?f=6&t=59149
; activateLastWindows(ThisHotkey){

;   global _MinimizeMaximizeWindowsListener

;   ; Массив отфильтрованных всех окон, где убраны ложные
;   local filteredAltTabWins := []
;   ; Стартовое активное окно, которое было при нажатии на хоткей.
;   local startWinId
;   ; Окно которое было активировано этим скриптом, поднято. В данный момент активно.
;   local activeWindowId

;   ; Массив открытых окон
;   local openedWindows := []
;   ; Окна которые были активированы. На которых вызывалась функция WinActivate.
;   local wasActivatedWindows := []
;   ; Число прокрученных окон из списка окон 
;   local countScroll := 1

;   global Wheel_
;   ; Если будут ещё кручения колеса, то они будут в этом массиве.
;   Wheel_.downStack := []
;   Wheel_.upStack := []

;   global hotkeyList
;   global Modules

;   ; logF("activateLastWindows()")

;   ; Запомнить все открытые окна, и их не сворачивать.
;   ; 
;   ; 1-ый режим - Переключение между последними открытыми окнами.
;   ; Это будет бесконечно переключаться между последним открытым окном,
;   ; будут открываться только последние 2 окна.
;   ; 
;   ; 2-ой режим - Чтобы не переключаться бесконечно, нужно первое активное окно
;   ; запомнить, и игнорировать, чтобы можно было листать дальше.

;   ; Убираем лишние окна.
;   filteredAltTabWins := _altTabWindows.getMinimizedMaximizedWindows()

;   ; Id активного окна.
;   local startWinId
;   try{
;     startWinId := WinGetID('A')
;   }catch as err{
;     try{
;       startWinId := _MinimizeMaximizeWindowsListener.minimizedWindows[1]
;     }
;   }

;   ; Это поднимает последнее открытое окно, кроме активного сейчас.
;   for k, winMap in filteredAltTabWins["all"]{  
;     local winId := winMap.Get("winId") 
;     ; Это окно равно стартовому окну?
;     if(winId == startWinId){
;       continue
;     }
;     WinActivate("ahk_id " winId)
;     ; Окно которое активно в данный момент
;     activeWindowId := winId
;     ; Добавляем активированное окно в массив активированных окон.
;     wasActivatedWindows.Push(winId)
;     ; MsgBox("countScroll = " . countScroll . ", activatedWinId = " . activatedWinId)
;     countScroll++
;     break
;   }

;   ; MsgBox(str)
;   ; KeyWait("CapsLock")
;   ; Ждём отжатия клавиши CapsLock:

;   disableAllHotkeys()

;   local callbackWheelDown := (*) => Wheel_.down()
;   local callbackWheelUp := (*) => Wheel_.up()

;   ; Включаем хоткеи кручения колеса.
;   Hotkey("*WheelDown", callbackWheelDown, "On T2")
;   Hotkey("*WheelUp", callbackWheelUp, "On T2")

;   ; Крутим цикл пока CapsLock не отожмётся.
;   while GetKeyState("CapsLock", "P"){
;     ; While GetKeyState("LShift", "P"){
;     if(Wheel_.upStack.Length >= 1){
;       ; Было кручение колеса вверх   
;       countScroll++
;       ; MsgBox("countScroll = " . countScroll . ", activatedWinId = " . activatedWinId)
;       ; Активируем следующее окно в списке
;       if(countScroll <= filteredAltTabWins["all"].Length){
;         local winMap := filteredAltTabWins["all"][countScroll]
;         local winId := winMap.Get("winId") 
;         WinActivate("ahk_id " winId)
;         ; Окно которое активно в данный момент
;         activeWindowId := winId
;         ; Добавляем активированное окно в массив активированных окон.
;         wasActivatedWindows.Push(winId)
;       }else{
;         countScroll := 0
;       }
;       ; Ждём остановки колеса
;       Wheel_.waitWheelStop(200)
;     }

;     if(Wheel_.downStack.Length >= 1){
;       ; Было кручение колеса вниз   
;       countScroll--
;       if(countScroll <= 0){
;           countScroll := filteredAltTabWins["all"].Length
;       }
;       ; Активируем предыдущее окно в списке
;       if(countScroll <= filteredAltTabWins["all"].Length){
;           local winMap := filteredAltTabWins["all"][countScroll]
;           local winId := winMap.Get("winId") 
;           WinActivate("ahk_id " winId)
;           ; Окно которое активно в данный момент
;           activeWindowId := winId
;           ; Добавляем активированное окно в массив активированных окон.
;           wasActivatedWindows.Push(winId)
;       }else{
;           countScroll := 0
;       }
;       ; Ждём остановки колеса
;       Wheel_.waitWheelStop(200)
;     }

;     Wheel_.downStack := []
;     Wheel_.upStack := []

;     Sleep(20)
;   }

;   ; CapsLock отжата, завершаем скрипт.

;   ; Если из TaskBar были развёрнуты окна, сворачиваем их обратно.
;   ; Перебираем массив окон которые были активированы.
;   for(k, restoredWinId in wasActivatedWindows){
;       ; Проверяем есть ли это окно в списке открытых окон
;       if(!Utils.arrayHasValue(filteredAltTabWins["opened"], restoredWinId)){
;           ; Это окно было развёрнуто из Таскбара.
;           ; Это активное окно?
;           if(activeWindowId != restoredWinId){
;               ; Сворачиваем на TaskBar.
;               minimizeWindow(restoredWinId)
;           }
;       }
;   }

;   Hotkey("*WheelDown", callbackWheelDown, "Off")
;   Hotkey("*WheelUp", callbackWheelUp, "Off")

;   enableAllHotkeys()

;   ; Отжимаем состояние CapsLock (лампочка не горит)
;   SetCapsLockState 0
;   ; BlockInput("Off")

; }





; class MinimizeMaximizeWindowsListener {


;   minimizedWindows := []

;   __New() {
;     global _altTabWindows
;     local listWindows := _altTabWindows.getMinimizedMaximizedWindows()
;     this.minimizedWindows := listWindows.Get("minimized")
;   }

;   startListening(){
        
;     myGui := Gui()
;     myGui.Opt("+LastFound")
;     hWnd := WinExist()
;     DllCall("RegisterShellHookWindow", "UInt", hWnd)
;     MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
;     OnMessage(MsgNum, ShellMessage)

;     ShellMessage(wParam, lParam, msg, hwnd) {

;       ; HSHELL_GETMINRECT - срабатывает на закрытие, и открытие окна.
;       if (wParam == 5){
;         hwnd := NumGet(lParam + 0, "UPtr")
;         ; Title := WinGetTitle("ahk_id " hwnd)
;         ; Состояние окна - максимизировано (1, наверно развёрнуто на весь экран), 
;         ; минимизировано (-1, в трее), в обычном перемещаемом состоянии (0).
;         local status := WinGetMinMax("ahk_id " hwnd)
;         ; Окно сворачивается.
;         if (status == -1){
;           ; В массиве свёрнутых окон уже есть такое значение.
;           if(Utils.arrayHasValue(this.minimizedWindows, hwnd, &key)){
;             this.minimizedWindows.Delete(key)
;           }
;           this.minimizedWindows.InsertAt(1, hwnd)
;         }
;       }

;       ; Закрытие окна
;       ; if (wParam == 2){
;       ;   MsgBox "2"
;       ; }
;       ; Создание, открытие окна.
;       ; if (wParam == 1){
;       ;   MsgBox "1"
;       ; }

;       ; Перерисовка, листание вкладок, нажатие на закрыть на веб странице.
;       ; Выделение текста. Активация другого окна.
;       ; if (wParam == 6){
;       ;   MsgBox "6"
;       ; }

;     } 
;   }

; }
