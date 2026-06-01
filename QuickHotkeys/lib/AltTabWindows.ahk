
/**
 * Нет зависимостей.
 * 
 * malcev (SKAN, I think Your algorithm is not right.) 
 * https://www.autohotkey.com/boards/viewtopic.php?style=2&p=440638
 * 
 * Если это не будет работать, то другое решение:
 * https://www.autohotkey.com/boards/viewtopic.php?f=6&t=122399
 * 
 * Использование: 
 * allWindows := AltTabWindows3().getAltTabWindows()
 *   for(_, win in allWindows){
 *       title := WinGetTitle(win) 
 *       ; Debug().logF(title)
 *   }
 */
class AltTabWindows {

  ; Возвращает окна из AltTab, массивом.
  getAltTabWindows() {
    local altTabWindows := []
    local windows := WinGetList()
    for (_, window in windows) {
      if (this.isAltTabWindow(window)) {
        altTabWindows.Push(window)
      }
    }
    return altTabWindows
  }

  /**
   * Возвращает карту открытых окон на дэсктопе, и свёрнутых в трее.
   * @param windows - Массив окон, которые нужно рассортировать.
   * @returns {Map} 
   */
  getMinimizedMaximizedWindows(windows := 0) {

    if (windows == 0) {
      windows := this.getAltTabWindows()
    }

    local ret := Map()
    ret["minimized"] := []
    ret["maximized"] := []

    for (_, window in windows) {
      ; Получаем состояние окна - максимизировано (1, наверно развёрнуто на весь экран),
      ; минимизировано (-1, в трее), в обычном перемещаемом состоянии (0).
      local winState := WinGetMinMax("ahk_id " . window)
      if (winState == -1) {
        ret["minimized"].Push(window)
      } else {
        ret["maximized"].Push(window)
      }
    }

    return ret
  }


  /**
   * Это окно в AltTab?
   * @param {Integer} hwnd - id окна.
   * @returns {Integer} 
   */
  isAltTabWindow(hwnd) {

    static WS_EX_APPWINDOW := 0x40000,
      WS_EX_TOOLWINDOW := 0x80,
      WS_EX_NOACTIVATE := 0x8000000,
      DWMWA_CLOAKED := 14,
      GA_PARENT := 1,
      GW_OWNER := 4

    if (!DllCall("IsWindowVisible", "uptr", hwnd)) {
      return false
    }

    local cloaked := 0
    DllCall("DwmApi\DwmGetWindowAttribute", "uptr", hwnd, "uint", DWMWA_CLOAKED, "uint*", &cloaked, "uint", 4)
    if cloaked {
      return false
    }

    local GetAncestorRet := DllCall("GetAncestor", "uptr", hwnd, "uint", GA_PARENT, "ptr")
    local GetDesktopWindowRet := DllCall("GetDesktopWindow", "ptr")
    if (this.realHwnd(GetAncestorRet) != this.realHwnd(GetDesktopWindowRet)) {
      return false
    }

    ;  WinGet, exStyles, ExStyle, ahk_id %hWnd%
    local exStyles := WinGetExStyle("ahk_id " . hwnd)

    ; Так определяется есть ли у стиля exStyles установка WS_EX_APPWINDOW
    if (exStyles & WS_EX_APPWINDOW) {
      return true
    }

    if (exStyles & WS_EX_TOOLWINDOW) or (exStyles & WS_EX_NOACTIVATE) {
      return false
    }

    loop {

      hwnd := DllCall("GetWindow", "uptr", hwnd, "uint", GW_OWNER, "ptr")
      if (!hwnd) {
        return true
      }

      ; Окно отображаемо?
      if DllCall("IsWindowVisible", "uptr", hwnd) {
        DllCall("DwmApi\DwmGetWindowAttribute", "uptr", hwnd, "uint", DWMWA_CLOAKED, "uint*", &cloaked, "uint", 4)
        if (!cloaked) {
          return false
        }
      }

      ; WinGet, exStyles, ExStyle, ahk_id %hwnd%
      exStyles := WinGetExStyle("ahk_id " . hwnd)

      ; Это WS_EX_TOOLWINDOW, или WS_EX_NOACTIVATE, и не WS_EX_APPWINDOW
      if ((exStyles & WS_EX_TOOLWINDOW) or (exStyles & WS_EX_NOACTIVATE))
        and !(exStyles & WS_EX_APPWINDOW) {
        return false
      }

    }
  }

  GetLastActivePopup(hwnd) {
    static GA_ROOTOWNER := 3
    hwnd := DllCall("GetAncestor", "uptr", hwnd, "uint", GA_ROOTOWNER, "ptr")
    hwnd := DllCall("GetLastActivePopup", "uptr", hwnd, "ptr")
    return hwnd
  }

  realHwnd(hwnd) {
    ; V1toV2: if 'var' is a UTF-16 string, use 'VarSetStrCapacity(&var, 8)'
    ; and replace all instances of 'var.Ptr' with 'StrPtr(var)'
    local var := Buffer(8, 0)
    NumPut("uint64", hwnd, var, 0)
    return NumGet(var, 0, "uint")
  }

}
