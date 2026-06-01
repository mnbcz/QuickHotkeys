
; File Explorer. Open right panel Details
; Ctrl+>
fileExplorer_OpenDetails(*){
  ; MsgBox "fileExplorer_OpenDetails"
  ; SendLevel 2
  Send("!+{p}")
}

; File Explorer. Open right panel Preview
; Ctrl+?
fileExplorer_OpenPreview(*){
  ; SendLevel 2
  Send("!{p}")
}

/**
 * Open Left Bar.
 */
fileExplorer_OpenLeftBar(*){

  ; MsgBox "fileExplorer_OpenLeftBar()"
  ; Fix - Open new window. 
  Sleep 400

  local HKey := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Modules\GlobalSettings\Sizer"
  ; Нулевая ширина бара. Бар скрыт.  
  local hiddenBarWith := "a00000000000000000000000ec030000"
  ; Default ширина бара.
  static barWith := "500100000100000000000000a0050000"

  local PageSpaceControlSizer := RegRead(HKey, "PageSpaceControlSizer")
  ; 23 нуля - это значение когда бар свёрнут.
  ; "a00000000000000000000000ec030000"
  if (PageSpaceControlSizer != hiddenBarWith){
    ; Бар не свёрнут.
    ; Запоминаем значение ширины бара.
    barWith := PageSpaceControlSizer
    ; Сворачиваем.
    RegWrite(hiddenBarWith, "REG_BINARY", HKey, "PageSpaceControlSizer")
  }else{
    ; Бар свёрнут.
    ; Разворачиваем.
    RegWrite(barWith, "REG_BINARY", HKey, "PageSpaceControlSizer")
  }

  local eh_Class := WinGetClass("A")
  if (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA"){
    Send("{F5}")
  }else {
    Sleep 10
    ; https://learn.microsoft.com/en-us/windows-hardware/drivers/debugger/bug-check-0x111---recursive-nmi
    PostMessage(0x111, 28931, , , "A")
  }
  ; В каталоге подняться на уровень вверх, и обратно, в этот же каталог.
  Send("!{Up}")
  Sleep(600)
  Send("{Backspace}")
}

