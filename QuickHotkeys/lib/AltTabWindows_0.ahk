
/**
 * Version by Scan.
 */
class AltTabWindows_0 {

  /**
   * Это окно в AktTab?
   * @param hwnd 
   * @returns {Integer} 
   */
  isAltTab(hwnd){
    if (this.isVisible(hwnd)
      and this.styledRight(hwnd)
      and this.isAltTabWindow(hwnd)){
      return true
    }else{
      return false
    }
  }

  ; Возвращает список окон в AltTab.
  ; Это используется. Проверено.
  ; v0.21 by SKAN for ah2 on D51K/D51O @ autohotkey.com/r?t=99157
  ; https://www.autohotkey.com/boards/viewtopic.php?t=99157
  ;
  ; Для открытых окон - это возвращает в начале списка самое активное окно.
  ; Далее в списке следуют свёрнутые окна.
  ; Для свёрнутых окон - в начале будет самое давнее окно.
  getAltTabWindows(params*){

    Local hModule := DllCall("Kernel32\LoadLibrary", "str", "dwmapi", "ptr")
    Local list := []
    Local exMin := 0
    Local style := 0
    Local exStyle := 0
    Local hwnd := 0

    while(params.Length > 4){
      exMin := params.pop()
    }

    for , hwnd in WinGetList(params*){
      if (this.isVisible(hwnd)
        and this.styledRight(hwnd)
        and this.notMinimized(hwnd, exMin)
        and this.isAltTabWindow(hwnd)){
          list.Push(hwnd)
        }
    }

    DllCall("Kernel32\FreeLibrary", "ptr", hModule)
    return list

  }


  styledRight(hwnd){
    exStyle := WinGetExStyle(hwnd)

    return (exStyle & 0x8000000) ? false           ; WS_EX_NOACTIVATE
      : (exStyle & 0x40000) ? true                 ; WS_EX_APPWINDOW
        : (exStyle & 0x80) ? false                ; WS_EX_TOOLWINDOW
          : true
  }

  notMinimized(hwnd, exMin := 0){
    return exMin ? WinGetMinMax(hwnd) != -1 : true
  }

  isVisible(hwnd, cloaked := 0){

    DllCall("dwmapi\DwmGetWindowAttribute", "ptr", hwnd
      ; DWMWA_CLOAKED
      , "int", 14                   
      , "uintp", &cloaked
      ; sizeof uint
      , "int", 4                    
    )
    
    style := WinGetStyle(hwnd)
    ; WS_VISIBLE
    return (style & 0x10000000) and not cloaked         
  }


  isAltTabWindow(hwnd){

    exStyle := WinGetExStyle(hwnd)
    ; WS_EX_APPWINDOW
    if (exStyle & 0x40000){
      return true
    }

    while hwnd := DllCall("GetParent", "ptr", hwnd, "ptr"){

      if (this.isVisible(hwnd)){
        return false
      }

      exStyle := WinGetExStyle(hwnd)

      ; WS_EX_TOOLWINDOW & WS_EX_APPWINDOW
      if ((exStyle & 0x80) and not (exStyle & 0x40000)){
          return False
      }
    }

    return !hwnd
  }

}
