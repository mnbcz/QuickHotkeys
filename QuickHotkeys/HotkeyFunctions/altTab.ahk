
altTab_SetHotkey(hotkeysJsonItem){
  ; MsgBox "altTab_SetHotkey()"
  global hotkeyList
  ; A4  038	 	u	0.19	LAlt           	
  ; 09  00F	h	d	0.70	Tab  
  ; 1B  001	h	d	0.83	Escape   
  hotkeyList.altTab := "!scF"
  ; Это не нужно, ошибка.
  ; Так Tab не нажимается как отдельная клавиша.
  ; hotkeyList.altTab_bug_fix := "scF & sc38"

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.altTab, altTab, "On I1")    
    ; Hotkey(hotkeyList.altTab_bug_fix, emptyFunc, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.altTab, altTab, "On"]
    ; Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"] := [hotkeyList.altTab_bug_fix, emptyFunc, "On"]

  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], altTab, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    ; if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id . "_bug_fix") ){
    ;   Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"], emptyFunc, "Off")
    ;   Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_bug_fix")  
    ; }
  }
}


altTab(*){

  disableAllHotkeys()

  local activeWindowIdStart := 0
  try{
    activeWindowIdStart := WinGetID("A")
  }

  ; Нужно слать обязательно через Send(), иначе функция вызывается два раза.
  SendLevel 0
  ; Send "^!{Tab}"
  ; Send "^!{scF}"
  ; Открываем окно AltTab.
  Send "{Blind}{LCtrl Down}{LAlt Down}{scF Down}"
  ; Sleep 40
  Send "{scF Up}{LCtrl Up}"
  Send "{Blind}{LAlt Down}"

  ; Ждём когда AltTab оно откроется.
  ; ahk_class XamlExplorerHostIslandWindow - Окно AltTab.
  local altTabWinId := WinWait("ahk_class XamlExplorerHostIslandWindow", , 1)
  if(altTabWinId == 0){
    ; Debug().logF("WinWait Error")
    SendEvent "{LCtrl Up}" 
    SendEvent "{LShift Up}"
    SendEvent "{LAlt Up}" 
    return
  }

  ; Send "{Blind}{LCtrl Up}{LAlt Up}"


  ; MsgBox "XamlExplorerHostIslandWi  ndow"
  ; Теперь ждём когда оно закроется
  WinWaitClose("ahk_class XamlExplorerHostIslandWindow")
  ; Модификаторы почему-то залипают, поэтому отжимаем
  SendEvent "{LCtrl Up}" 
  SendEvent "{LShift Up}"
  SendEvent "{LAlt Up}" 

  ; Send "{LCtrl Down}{LCtrl Up}" 
  ; Send "{LShift Up}"
  ; Send "{LAlt Up}"

  enableAllHotkeys()

  ; BlockInput("On")
  ; Если стартовое окно было активно.
  ; Если в окне altTab был клик, чтобы не выбирать ничего, чтобы окно
  ; закрылось, то активируем стартовое окно.
  ; Потому-что фокус с окна убирается.
  if(activeWindowIdStart){
    local activeWindowId := 0 
    try{
      activeWindowId := WinGetID("A")
    }
    if(activeWindowId == 0){
      try{
        WinActivate "ahk_id " . activeWindowIdStart
      }
    }
  }
  ; BlockInput("Off")

}



