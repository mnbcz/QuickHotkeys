

closeTab(sc, ThisHotkey){
  
  local mods := getModifiers(ThisHotkey)
  ; BlockInput("On")
  ; Activate Window on hover
	MouseGetPos(, , &hWnd)
	WinActivate("ahk_id " hWnd)
  ; MsgBox "^{w}"
  if(GetKeyState(mods[1], "P")){
    SetKeyDelay -1
    BlockInput "On"
    SendEvent("^{w}")
    BlockInput "Off"
    SetKeyDelay 10
  }

  ; Отжимаем залипшие клавиши.
  releaseModifiers_Timeout()
  
  ; SetTimer timerCloseTab_ForLeftClick, -1
  
}


; timerCloseTab_ForLeftClick(){
;   global nextPrevTab_mod
;   global nextPrevTab_timer
;   ; Включаем левый клик для листания.
;   local vkMod := Format("vk{:x}", GetKeyVK(nextPrevTab_mod))
;   Hotkey vkMod . " & LButton", prevTabByLButton, "On"
;   ; Отключаем левый клик для листания, через 1 секунду.
;   SetTimer disableShiftLButton_Timer, nextPrevTab_timer
;   ; BlockInput("Off")
;   SetTimer releaseModifiers, -4
; }
