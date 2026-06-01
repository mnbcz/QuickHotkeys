


; Скрывает значки с рабочего стола.
; Win+Alt+D
; https://github.com/Hurstwood/Desktop-icons
; Keys chosen because win+d shows the the desktop and win+ctrl+d creates a new desktop.
; #!d::
hideDesktopIcons(*) {


  ; Desktop:
  ; Program Manager
  ; ahk_class Progman
  ; ahk_exe explorer.exe
  ; ahk_pid 13928
  ; ahk_id 132276

  ; Действует до ближайшего return.
  ; 2 - Распознавать имя заголовка в любом месте, с середины.
  ; 1 - С начала. Дефаулт.
  SetTitleMatchMode(2)
  ;https://stackoverflow.com/questions/53109281/what-is-the-windows-workerw-windows-and-what-creates-them
  local HWND
  try{
    HWND := ControlGetHwnd("SysListView321", "ahk_class WorkerW")
  }catch as err{
    try{
      ; Error: Target control not found.
      ; Бывает ошибка когда жесты проводить на дэсктопе, и дэсктоп портится.
      ; При клике на дэсктопе - издаётся звук.
      HWND := ControlGetHwnd("SysListView321", "ahk_class Progman")
    }catch as err{
      return
    }
  }

  ; Toggle between displaying and hiding the desktop icons
  if (DllCall("IsWindowVisible", "UInt", HWND)){
    WinHide("ahk_id " HWND)
  }else{
    WinShow("ahk_id " HWND)
  }
}


; Размещает окно над которым курсор, всегда наверху всех окон.
alwaysOnTop(*){

  local mouseWinId
  MouseGetPos ,, &mouseWinId
  WinSetAlwaysOnTop -1, mouseWinId
  ; Чтобы избавиться от бага
  WinActivate(mouseWinId)
  ; WinMoveBottom mouseWinId
  ; ExStyle := WinGetExStyle("My Window Title")
  ; if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST.
}


; Remove the window's caption, or add.
removeWindowCaption(*){

  local activeWinId := WinGetID('A')
  ; local ExStyle := WinGetExStyle(activeWinId)
  local ExStyle := WinGetStyle(activeWinId)
  ; 0xC or 0xC00000 - есть заголовок. 
  if (ExStyle & +0xC00000){
      ; Убираем заголовок
      WinSetStyle "-0xC00000", "ahk_id " activeWinId
      ; Убирает скруглённые углы, и полосу сверху.
      ; WinSetStyle "^0x40000", "ahk_id " activeWinId 
      WinSetStyle "-0x40000", "ahk_id " activeWinId 

      ; Adds border
      ; WinSetStyle "^0x800000", "ahk_id " activeWinId 
      ; MsgBox("-")
  }else{
      ; Отображаем заголовок
      WinSetStyle "+0xC00000", "ahk_id " activeWinId
      ; Убирает скруглённые углы, и полосу сверху.
      WinSetStyle "+0x40000", "ahk_id " activeWinId 
      ; MsgBox("+")
  }
}


