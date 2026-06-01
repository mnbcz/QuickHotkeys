
; Ддя браузера chrome, слушает открытие окна To exit Full Screen press Esc.
; И автоматически закрывает.

chromeCloseFullScreen_SetHotkey(hotkeysJsonItem){
  if (hotkeysJsonItem.isEnable) {
    ChromeCloseFullScreen.startListenShow()
  }else{
    ChromeCloseFullScreen.stopListenShow()
  }
}


class ChromeCloseFullScreen{

; ahk_class Chrome_WidgetWin_1
  ; static nameWindowToListen := "ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe"
  static nameWindowToListen := "ahk_class Chrome_WidgetWin_1"

  /**
   * Слушает открытие окна To exit Full Screen.
   */
  static startListenShow(){

    ; MsgBox "startListenShow"

    ; WinEvent.Show(createCallback, "Magnifier")
    WinEvent.Show(createCallback, ChromeCloseFullScreen.nameWindowToListen)
    ; WinEvent.Show(createCallback, "Open File ahk_class #32770")
    ; WinEvent.Create(createCallback, "Open File ahk_class #32770")
    ; WinEvent.Create(createCallback, "Open ahk_class #32770")

    createCallback(hWnd, eventObj, dwmsEventTime, args*){
      WinWait("ahk_id " . hWnd, , 2000)
      try{
        ; Debug.win(hWnd)
        local title := WinGetTitle("ahk_id " . hWnd)
        ; У окна To exit full screen pres ESC - заголовок пустая строка.
        if(title == ""){
          ; Debug.log("Close")

          ; Убеждаемся что размеры окна, и положение, соответствуют.
          ; Есть и другие важные окна с пустым заголовком.
          ; Это окно расширений.

          WinGetPos(&x, &y, &width, &height, "ahk_id " . hWnd)
          
          ; 7.76
          local wh := width / height 
          ; if (wh < 6 || wh > 9){
          if (wh < 6){
            return
          }

          local xExpect := (A_ScreenWidth / 2) - (width / 2) 
          if(x < xExpect - 10 || x > xExpect + 10){
            return
          }

          ; MsgBox "w = " . width . ", h = " . height . ", x = " . x . ", y = " . y

          WinClose("ahk_id " . hWnd)
        }
        ; WinWaitClose("ahk_id " . hWnd)
      }
    }

  }


  /**
   * Отключает слушание открытия окна To exit Full Screen.
   */
  static stopListenShow(){
     WinEvent.Stop("Show", ChromeCloseFullScreen.nameWindowToListen)
  }

}



