
; Первый модификатор, который удерживается.
global minimizeBackWindowsByWheel_mod
global minimizeBackWindowsByWheel_modSymbols

/**
 * Назначение/отключение хоткея.
 * @param {Integer} isEnable 
 * @param {Object} hotkeysJsonItem 
 */
minimizeBackWindowsByWheel_SetHotkeys(hotkeysJsonItem){
  global hotkeyList, Modules

  local modsFromHotkeyDisplay := getModsFromHotkeyDisplay(hotkeysJsonItem.hotkeyDisplay)
  local modSymbols := Utils.joinArrayToString("", modsFromHotkeyDisplay.symbols)

  ; Название id хоткея - ключ, и значение - хоткей:
  hotkeyList.minimizeBackWindowsByWheelDown := modSymbols . "WheelDown"
  hotkeyList.minimizeBackWindowsByWheelUp := modSymbols . "WheelUp"
  
  local upHotkeyId := hotkeysJsonItem.id . "_up"
  local downHotkeyId := hotkeysJsonItem.id . "_down"

  global minimizeBackWindowsByWheel_mod := modsFromHotkeyDisplay.names[1]
  global minimizeBackWindowsByWheel_modSymbols := modSymbols

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущие хоткеи.
    disablePrevHotkeys()
    ; Включаем активные хоткеи.
    ; Hotkey(minimizeBackWindowsByWheel_modSymbols . "WheelUp", emptyFunc, "On")
    ; Hotkey(minimizeBackWindowsByWheel_modSymbols . "WheelDown", emptyFunc, "On")

    Hotkey hotkeyList.minimizeBackWindowsByWheelDown, minimizeBackWindowsByWheel, "On"
    Hotkey hotkeyList.minimizeBackWindowsByWheelUp, minimizeBackWindowsByWheel, "On"
    Modules.Hotkeys.assignedHotkeys[downHotkeyId] := [hotkeyList.minimizeBackWindowsByWheelDown, minimizeBackWindowsByWheel, "On"]
    Modules.Hotkeys.assignedHotkeys[upHotkeyId] := [hotkeyList.minimizeBackWindowsByWheelUp, minimizeBackWindowsByWheel, "On"]

  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules

    ; Hotkey(minimizeBackWindowsByWheel_modSymbols . "WheelUp", emptyFunc, "Off")
    ; Hotkey(minimizeBackWindowsByWheel_modSymbols . "WheelDown", emptyFunc, "Off")

    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(upHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[upHotkeyId],minimizeBackWindowsByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(upHotkeyId)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(downHotkeyId) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[downHotkeyId], minimizeBackWindowsByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(downHotkeyId)
    }
  }

}



/**
 * Сворачивает/разворачивает все окна на дэсктопе, кроме активного.
 */
minimizeBackWindowsByWheel(ThisHotkey){

  global Wheel_, minimizeBackWindowsByWheel_modSymbols

  BlockInput "On"

  disableAllHotkeys()
  
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

  local activeWindow := WinExist("A")

  ; Окна на дэсктопе, кроме активного окна.
  local backWindowsOnDesktop := 0

  ; Окна которые были свёрнуты. Массив id окон.
  static minimizedWindows := []

  ; Нельзя блокировать после, потому-что кручение вверх будет отключено.
  BlockInput "Off"

  while GetKeyState(minimizeBackWindowsByWheel_mod, "P"){
    ; Было кручение колеса вниз
    if(Wheel_.downStack.Length > 0){  
      if(backWindowsOnDesktop == 0){
        backWindowsOnDesktop := filteredAltTabWindows(activeWindow)["opened"]
      }
      for _, backWindowOnDesktop in backWindowsOnDesktop{
        minimizeWindow(backWindowOnDesktop)
      }
      if(backWindowsOnDesktop.Length > 0){
        minimizedWindows := Utils.reverseArray(backWindowsOnDesktop)
      }
      Wheel_.waitWheelStop(300)
      Wheel_.downStack := []
      continue
    }

    ; Было кручение колеса вверх. 
    if(Wheel_.upStack.Length > 0){  

      for _, minimizedWindow in minimizedWindows{
        try{
          WinActivate(minimizedWindow)
        }
        if(activeWindow){
          ; setZOrderOfWindow(minimizedWindow, activeWindow)
        }
      }
      if(activeWindow){
        try{
          WinActivate(activeWindow)
        }
      }
      ; Sleep 4
      ; BlockInput("Off")
      Wheel_.waitWheelStop(300)
      Wheel_.upStack := []
      ; continue
    }

    Sleep 10
  }

  restoreHotkeys()

  ; ---------------------------------------------------------
  
  restoreHotkeys(){
  
    global Wheel_, minimizeBackWindowsByWheel_modSymbols

    Hotkey("*WheelDown", "Off")
    Hotkey("*WheelUp", "Off")

    Wheel_.downStack := []
    Wheel_.upStack := []
    Wheel_.timeStack := []

    enableAllHotkeys()
  
    Sleep 10
    ; Избавляемся от бага
    ; SendEvent("{Blind}{LControl Up}")
    ; SendEvent("{Blind}{LShift Up}")
    ; SendEvent("{Blind}{LAlt Up}")
    SetTimer releaseModifiers, -10
  }

}







