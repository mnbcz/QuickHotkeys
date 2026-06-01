
/**
 * Move to next tab, by wheel.
 * @param ThisHotkey 
 */
nextTabByRButtonWheel(ThisHotkey){
  ; Чтобы избавиться от бага, перемещение вкладок.
  ; Shift не отжимается перед отправкой SendEvent().
  ; BlockInput("On")
  ; ;#IfWinActive ahk_class MozillaWindowClass || ahk_class Chrome_WidgetWin_1
  ; if (WinActive("ahk_class MozillaWindowClass") || WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe")){
  ;   ; Send("^{PgDn}")
  ;   SendEvent("^{PgDn}")
  ; }else{
  ;   ; If it's not a browser
  ;   SendEvent("^{Tab}")
  ; }
  ; BlockInput("Off")

  BlockInput("On")
  ; Это File Explorer
  if (WinActive("ahk_class CabinetWClass") || WinActive("ahk_class WorkerW")){
    SendEvent("^{Tab}")
  }else{
    SendEvent("^{PgDn}")
  }
  BlockInput("Off")

}


prevTabByRButtonWheel(ThisHotkey){
 
  ; BlockInput("On")
  ; if (WinActive("ahk_class MozillaWindowClass") || WinActive("ahk_class Chrome_WidgetWin_1 ahk_exe Code.exe")){
  ;   ; Send("^{PgUp}")
  ;   SendEvent("^{PgUp}")
  ; }else{
  ;   ; If it's not a browser
  ;   SendEvent("^+{Tab}")
  ; }
  ; BlockInput("Off")

  BlockInput("On")
  ; Это File Explorer
  if (WinActive("ahk_class CabinetWClass") || WinActive("ahk_class WorkerW")){
    SendEvent("^+{Tab}")
  }else{
    SendEvent("^{PgUp}")
  }
  BlockInput("Off")


}

