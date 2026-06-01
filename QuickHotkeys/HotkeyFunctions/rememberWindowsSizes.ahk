
rememberWindowsSizes_EnableDisable(hotkeysJsonItem){
  ; global hotkeysActions
  global Modules

  ; {symbols, names, key, scKey}
  local keyObj := getModsFromHotkeyDisplay(hotkeysJsonItem.hotkeyDisplay)
  local hk := Utils.joinArrayToString("", keyObj.symbols) . keyObj.scKey

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущий хоткей.
    disableHotkey()
    ; Назначаем новый.
    local assignedHotkey := Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hk, rememberWindowSize, "On I1"]
    Hotkey assignedHotkey[1], assignedHotkey[2], assignedHotkey[3]    
  }else{
    disableHotkey()
  }

  disableHotkey(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      local assignedHotkey := Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id]
      Hotkey(assignedHotkey[1], assignedHotkey[2], "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
  }

}

; Открывает окно запоминания размеров окна.
rememberWindowSize(*){
  global rememberWindowsSizes_
  rememberWindowsSizes_.openGui()
}

