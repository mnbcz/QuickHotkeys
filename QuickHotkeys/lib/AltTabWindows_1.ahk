
class AltTabWindows_1 {

  /**
   * Возвращает окна из AltTab правильно, но в случайном порядке.
   * Возможно только первые два окна в правильном порядке.
   * @returns {Array} 
   */
  getAltTabWindows() {
    ; modernized, original by ophthalmos https://www.autohotkey.com/boards/viewtopic.php?t=13288
    static WS_EX_APPWINDOW := 0x40000 ; has a taskbar button
    static WS_EX_TOOLWINDOW := 0x80 ; does not appear on the Alt-Tab list
    static GW_OWNER := 4 ; identifies as the owner window

    ; Get the current monitor the mouse cusor is in.
    DllCall("GetCursorPos", "uint64*", &point := 0)
    hMonitor := DllCall("MonitorFromPoint", "uint64", point, "uint", 0x2, "ptr")

    AltTabList := []

    DetectHiddenWindows False     ; makes IsWindowVisible and DWMWA_CLOAKED unnecessary in subsequent call to WinGetList()
    for hwnd in WinGetList() {    ; gather a list of running programs

      ; Check if the window is on the same monitor.
      if hMonitor == DllCall("MonitorFromWindow", "ptr", hwnd, "uint", 0x2, "ptr") {

        ; Find the top-most owner of the child window.
        owner := DllCall("GetAncestor", "ptr", hwnd, "uint", GA_ROOTOWNER := 3, "ptr")
        owner := owner || hwnd ; Above call could be zero.

        ; Check to make sure that the active window is also the owner window.
        if (DllCall("GetLastActivePopup", "ptr", owner) = hwnd) {

          ; Get window extended style.
          es := WinGetExStyle(hwnd)

          ; Must appear on the Alt+Tab list, have a taskbar button, and not be a Windows 10 background app.
          if (!(es & WS_EX_TOOLWINDOW) || (es & WS_EX_APPWINDOW))
            AltTabList.push(hwnd)
        }
      }
    }

    return AltTabList
  }

}
