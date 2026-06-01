
copy_SetHotkey(hotkeysJsonItem){

  global hotkeyList
  ; hotkeyList.copy := "~" . hotkeysJsonItem.hotkeyDisplay
  local scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))

  hotkeyList.copy := "~LButton & " . scHotkeyDisplay
  hotkeyList.copy_bug_fix := "~" . scHotkeyDisplay . " & ~LButton"

  local copyFunc := copy.bind(scHotkeyDisplay)

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.copy, copyFunc, "On")    
    Hotkey(hotkeyList.copy_bug_fix, emptyFunc, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.copy, copyFunc, "On"]
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"] := [hotkeyList.copy_bug_fix, emptyFunc, "On"]

  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], copyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id . "_bug_fix") ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"], emptyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_bug_fix")  
    }
  }

}


paste_SetHotkey(hotkeysJsonItem){
  global hotkeyList
  local scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))
  hotkeyList.paste := "~LButton & " . scHotkeyDisplay
  hotkeyList.paste_bug_fix := "~" . scHotkeyDisplay . " & ~LButton"

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.paste, paste, "On")   
    Hotkey(hotkeyList.paste_bug_fix, emptyFunc, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.paste, paste, "On"]
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"] := [hotkeyList.paste_bug_fix, emptyFunc, "On"]

  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], paste, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id . "_bug_fix") ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"], emptyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_bug_fix")  
    }
  }

}


cut_SetHotkey(hotkeysJsonItem){
  global hotkeyList
  local scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))
  if(scHotkeyDisplay == "sc0"){
    return
  }
  hotkeyList.cut := "~LButton & " . scHotkeyDisplay
  hotkeyList.cut_bug_fix := "~" . scHotkeyDisplay . " & ~LButton"

  local cutFunc := cut.bind(hotkeysJsonItem.hotkeyDisplay)
  
  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.cut, cutFunc, "On")    
    Hotkey(hotkeyList.cut_bug_fix, emptyFunc, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.cut, cutFunc, "On"]
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"] := [hotkeyList.cut_bug_fix, emptyFunc, "On"]

  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], cutFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    if(Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id . "_bug_fix")){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_bug_fix"], emptyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_bug_fix")  
    }
  }
}


enter_SetHotkey(hotkeysJsonItem){
  global hotkeyList
  local scHotkeyDisplay := ""
  ; ` - sc029	
  if(hotkeysJsonItem.hotkeyDisplay == "``"){
    scHotkeyDisplay := "sc29"
  }else{
    ; Баг.
    ; Для символа `, sc код может не возвращаться, а возвращается "sc0".
    ; Поэтому вызываем эту функцию ещё раз. 
    scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))
    if(scHotkeyDisplay == "sc0"){
      Sleep 10
      scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))
      if(scHotkeyDisplay == "sc0"){
        MsgBox "Error, enter_SetHotkey: " . hotkeysJsonItem.hotkeyDisplay 
        return
      }
    }
  }
  
  hotkeyList.enter := "~LButton & " . scHotkeyDisplay
  hotkeyList.enter_bug_fix := "~" . scHotkeyDisplay . " & ~LButton"
  local hotkeyIdBugFix := hotkeysJsonItem.id . "_bug_fix"

  local enterFunc := enter.bind(scHotkeyDisplay)

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.enter, enterFunc, "On")    
    Hotkey(hotkeyList.enter_bug_fix, emptyFunc, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.enter, enterFunc, "On" ]
    Modules.Hotkeys.assignedHotkeys[hotkeyIdBugFix] := [hotkeyList.enter_bug_fix, emptyFunc, "On" ]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], enterFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeyIdBugFix) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeyIdBugFix], emptyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeyIdBugFix)  
    }
  }
}


backSpace_SetHotkey(hotkeysJsonItem){
  global hotkeyList
  local scHotkeyDisplay := Format("sc{:X}", GetKeySC(hotkeysJsonItem.hotkeyDisplay))
  hotkeyList.backSpace := "~LButton & " . scHotkeyDisplay
  hotkeyList.backSpace_bug_fix := "~" . scHotkeyDisplay . " & ~LButton"
  local hotkeyIdBugFix := hotkeysJsonItem.id . "_bug_fix"

  if (hotkeysJsonItem.isEnable) {
    disablePrevHotkeys()
    Hotkey(hotkeyList.backSpace, backSpace, "On")    
    Hotkey(hotkeyList.backSpace_bug_fix, emptyFunc, "On")    
    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id] := [hotkeyList.backSpace, backSpace, "On"]
    Modules.Hotkeys.assignedHotkeys[hotkeyIdBugFix] := [hotkeyList.backSpace_bug_fix, emptyFunc, "On"]
  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeysJsonItem.id) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id], backSpace, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id)  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp(hotkeyIdBugFix) ){
      Hotkey(Modules.Hotkeys.assignedHotkeys[hotkeyIdBugFix], emptyFunc, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeyIdBugFix)  
    }
  }
}



copy(key := "", hotkey := "", *){

  if(GetKeyState("LButton", "P")){
    if WinActive("ahk_class CabinetWClass") || WinActive("ahk_class WorkerW") {
      Send "{Blind}{LButton Up}"
      Send "^{Insert}"
    }else{
      Send "^{Insert}"
    }
  }
  KeyWait key
}

paste(*){
  Send "^{v}"
} 

cut(key, hotkey){
  ; BlockInput "On"
  Send "^{x}"
  ; BlockInput "Off"
  KeyWait key
  Send "{" . key . " Up}"
}


enter(key, hotkey){
  Send "{Enter}"
  if(key == "CapsLock"){
    ; Отжимаем состояние CapsLock (лампочка не горит)
    SetCapsLockState 0
  }
}

backSpace(*){
  Send "{BackSpace}"
}



