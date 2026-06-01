

hideTaskbar_EnableDisable(hotkeysJsonItem){
  global hotkeysActions
  global hideTaskbar_
  global Modules

  ; {symbols, names, key, scKey}
  local keyObj := getModsFromHotkeyDisplay(hotkeysJsonItem.hotkeyDisplay)
  local hk := Utils.joinArrayToString("", keyObj.symbols) . keyObj.scKey

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущий хоткей.
    disableHotkey()
    hotkeysActions.hideTaskbar := 1
    hideTaskbar_.taskbarData.corner := hotkeysJsonItem.list.value
    hideTaskbar_.startTrack()
    local assignedHotkeys := Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hk, hideTaskbar_toggle, "On I1"]
    Hotkey assignedHotkeys[1], assignedHotkeys[2], assignedHotkeys[3]   
    ; Исправляем баг, когда система делает Таскбар открытым,
    ; когда считается что это скрыто.
    local showTaskbarCallback := ObjBindMethod(hideTaskbar_, "showTaskbarCallback")
    WinEvent.Show(showTaskbarCallback, "ahk_class Shell_TrayWnd")
  }else{
    disableHotkey()
  }

  disableHotkey(){
    hotkeysActions.hideTaskbar := 0
    hideTaskbar_.stopTrack()
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      local assignedHotkey := Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id]
      Hotkey(assignedHotkey[1], assignedHotkey[2], "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    WinEvent.Stop("Show", "ahk_class Shell_TrayWnd")
  }

}

; Включает/отключает слушание Таскбара (курсора внизу).
hideTaskbar_toggle(*){
  global hideTaskbar_
  hideTaskbar_.toggle()
}



altTabOnTaskbar_EnableDisable(hotkeysJsonItem){
  global hotkeysActions
  global hideTaskbar_
  if (hotkeysJsonItem.isEnable) {
    hotkeysActions.altTabOnTaskbar := 1
    hideTaskbar_.altTab.corner := hotkeysJsonItem.list.value
    hideTaskbar_.altTab.distanceFromCorner := Integer(hotkeysJsonItem.hotkeyDisplay)
    hideTaskbar_.startTrackAltTab()
  }else{
    hideTaskbar_.stopTrackAltTab()
  }
}
