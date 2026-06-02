#Include JSON_Dump.ahk

/**
 * Usage Examples:
 * Debug.log(value)
 * Debug.logT(value)
 * 
 */
class Debug {

  static logStr := ""
  static logPath := A_ScriptDir . "/log.txt"
  ; Время предыдущего вызова метода add()
  static prevLogTime := A_TickCount
  static functionSave := () => Debug.save()

  ; __New(logPath := "") {
  ;   if (!logPath) {
  ;     logPath := A_ScriptDir . "/log.txt"
  ;   }
  ;   Debug.logPath := logPath
  ;   Debug.prevLogTime := A_TickCount
  ;   Debug.functionSave := () => Debug.save()
  ; }

  
  /**
   * Добавляет строку лога к свойству Debug.logStr.
   * @param obj 
   * @param {String} name 
   */
  static add(obj, name := "") {

    local outStr := ""
    if(name != ""){
      outStr .= "Name=" . name . ", "
      outStr .= "Type=" . Type(obj) . ", "
    }

    local timeFromLastCall := A_TickCount - Debug.prevLogTime
    Debug.prevLogTime := A_TickCount

    outStr .= timeFromLastCall . " (ms.): "

    if (IsObject(obj)) {
      outStr .= "`n"
      outStr .= JSON_Dump.Dump(obj, 1)
      outStr .= "`n"
    } else {
      outStr .= obj . "`n"
    }

    Debug.logStr .= outStr

  }

  /**
   * Добавляет строку лога в файл лога.
   * */  
  static save(){
    if(Debug.logStr != ""){
      FileAppend(Debug.logStr, Debug.logPath)
      Debug.logStr := ""
    }
  }

  ; Добавляет строку в файл лога log.txt сразу.
  static log(obj, name := "") {
    Debug.logStr := ""
    Debug.add(obj, name)
    Debug.save()
  }

  ; Добавляет строку лога в свойство лог, и стартует сохранение
  ; в файл лога через таймаут 400.
  static logT(obj, name := "", timeoutToSave := -300){
    Debug.add(obj, name)
    SetTimer Debug.functionSave, timeoutToSave
  }


  /**
   * Данные о окнах.
   * @param windowIds - id окна, массив. Если не указано, активное окно.
   */
  static win(windowIds := 0){

    if(windowIds == 0){
      MouseGetPos(&x, &y, &windowIds)
      ; windowIds := WinGetID("A")
    }

    local windows := []
    if(Type(windowIds) != "Array"){
      windows.Push(windowIds)
    }else{
      windows := windowIds
    }

    local logStr := ""

    for _, window in windows{
      local ahk_class := ""
      local title := ""
      local ahk_exe := ""
      try{
        ahk_class := WinGetClass(window)
        title := WinGetTitle(window)
        ahk_exe := WinGetProcessName(window)
      }
      logStr .= "hWnd = " . window . ", ahk_class " . ahk_class . " ahk_exe " . ahk_exe . ", title = " . title . "`n"
    }

    Debug.log(logStr)
  }

}
