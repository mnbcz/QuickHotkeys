
#Include ../../Lib/ahk2_lib/WinEvent.ahk

class ListenWindows{

  ; Массив окон которые были активированы.
  ; В начале самое недавнее активное окно.
  focusedWindows := []

  ; Массив свёрнутых окон. Которые были свёрнуты на Таскбар.
  ; В начале самое недавнее активное окно.
  minimizedWindows := []
  cachedNonAltTabWindows := Map()
  AltTabWindows := {}

  __New() {
    global _altTabWindows
    this.AltTabWindows := _altTabWindows
    ; this.AltTabWindows := AltTabWindows()
    this.minimizedWindows := this.AltTabWindows.getMinimizedMaximizedWindows()['minimized']
  }

  startListenMinimize(){

    local minimizeCallback := ObjBindMethod(this, "minimizeCallback")
    WinEvent.Minimize(minimizeCallback)

    ; local openCallback := ObjBindMethod(this, "openCallback")
    ; WinEvent.Show(openCallback, WinTitle:="", Count:=-1, WinText:="", 
    ; "ahk_group notAltTab", "ahk_group notAltTab")

    ; local closeCallback := ObjBindMethod(this, "closeCallback")
    ; WinEvent.Close(closeCallback, , , , "ahk_group notAltTab", "ahk_group notAltTab")
    ; ; WinEvent.NotExist(closeCallback, , , , "ahk_group notAltTab", "ahk_group notAltTab")

  }


  startListenCreate(winTitle){
    local createCallback := ObjBindMethod(this, "createCallback")
    WinEvent.Create(createCallback, winTitle)
  }


  /**
   * Вызывается при сворачивании окна на Таскбар.
   * Добавляет/перемещает окно на верх массива this.minimizedWindows.
   * @param hWnd 
   * @param eventObj 
   * @param dwmsEventTime 
   * @param args 
   */
  minimizeCallback(hWnd, eventObj, dwmsEventTime, args*){
    ; this.log(hWnd, eventObj, dwmsEventTime, args)

    local ahk_class := ""
    local title := ""
    local ahk_exe := ""
    try{
      ahk_class := WinGetClass(hWnd)
      ; title := WinGetTitle(hWnd)
      ahk_exe := WinGetProcessName(hWnd)
    }

    if(ahk_class == ""){
      return
    }

    local winStr := "ahk_class " . ahk_class . " ahk_exe " . ahk_exe

    ; Такое окно уже есть в кэшированных скрытых окнах (не AltTab)?
    if(this.cachedNonAltTabWindows.Has(winStr)){
      return
    }

    ; Добавляем в кэшированные окна, если это не окно из AltTab.
    if(!this.AltTabWindows.isAltTabWindow(hWnd)){
      this.cachedNonAltTabWindows.Set(winStr, "")
      return
    }

    ; Если окно уже существует в списке свёрнутых окон, убираем из списка.
    ; И добавляем в начало списка.
    if(Utils.arrayHasValue(this.minimizedWindows, hWnd, &key)){      
      this.minimizedWindows.RemoveAt(key)
    }
    this.minimizedWindows.InsertAt(1, hWnd)

  }


}