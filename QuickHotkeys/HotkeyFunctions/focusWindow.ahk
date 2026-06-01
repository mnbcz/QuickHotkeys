

focusWindow_SetHotkey(hotkeysJsonItem){
  global hotkeyList
  hotkeyList.focusWindow := hotkeysJsonItem.hotkeyDisplay

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.focusWindow, focusWindow, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.focusWindow, focusWindow, "On"]
  }else{
    disablePrevHotkeys()
  }

   ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], focusWindow, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
  }
}



sendWindowToDown_SetHotkey(hotkeysJsonItem){
  global hotkeyList
  local scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))
  hotkeyList.sendWindowToDown := "~MButton & " . scHotkeyDisplay
  hotkeyList.copy_bug_fix := "~" . scHotkeyDisplay . " & ~MButton"
  local bug_fix_id := hotkeysJsonItem.id . "_bug_fix"

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.sendWindowToDown, sendWindowToDown, "On")
    Hotkey(hotkeyList.copy_bug_fix, emptyFunc, "On")
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.sendWindowToDown, sendWindowToDown, "On"]
    Modules.Hotkeys.assignedHotkeys[bug_fix_id] := [hotkeyList.copy_bug_fix, emptyFunc, "On"]
  }else{
    disablePrevHotkeys()
  }

   ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], sendWindowToDown, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(bug_fix_id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[bug_fix_id], emptyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(bug_fix_id)  
    }
  }
}




; Активирует окно над которым курсор.
focusWindow(*){
  local hwnd
  MouseGetPos , , &hwnd
  WinActivate("ahk_id" . hwnd)
}


; Активирует окно над которым курсор.
sendWindowToDown(*){

  local hwnd
  MouseGetPos , , &hwnd
  ; The effect is similar to pressing Alt+Esc.
  WinMoveBottom("ahk_id" . hwnd)
  
  KeyWait "LCtrl"
  SendEvent "{LCtrl Up}"

  ; Активируем самое верхнее окно:

  global _altTabWindows
  local allWindows := _altTabWindows.getAltTabWindows()

  for(_, win in allWindows){
      ; Получаем состояние окна - максимизировано (1), 
      ; минимизировано (-1, в трее),
      ; В обычном перемещаемом состоянии (0).
      local winState := WinGetMinMax("ahk_id " . win)
      if(winState == -1 || win == hwnd){
        continue
      }
      ; local title := WinGetTitle("ahk_id " . win)
      ; Debug().logF(title)
      WinActivate("ahk_id" . win)
      break
  }
}
