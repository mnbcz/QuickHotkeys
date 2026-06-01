
class HideTaskbar {
  
  mousePosition_callback_func := {}
  ; Скорость проверки курсора.
  mousePosition_callback_speed := 180


  ; checkIfCursorOut_callback_func := {}
  taskbar := "ahk_class Shell_TrayWnd ahk_exe explorer.exe"
  taskbarData := {x: 0, y: 1000, width: 1200, height: 40, 
    ; Таскбар отображается на экране?
    isShow: 1,
    ; Время когда курсор вышел за пределы Таскбара.
    cursorOutTime: 0,
    ; Вызывается функция отслеживания курсора каждые 100 миллисекунд?
    ; Включено отслеживание курсора?
    isTracking: 0,
    corner: "",
    ; Distance from corner.
    distanceFromCorner: 100,
    checkIfTaskbarOpen_callback_func: {},
    checkIfTaskbarOpen_callbackCallInterval: 4000
  }

  altTab := {
    ; Включено отслеживание курсора?
    isTracking: 0,
    corner: "",
    ; Distance from corner.
    distanceFromCorner: 40
  }

  __New() {
    CoordMode "Mouse", "Screen"
    this.mousePosition_callback_func := ObjBindMethod(this, "mousePosition_callback")
    ; this.checkIfCursorOut_callback_func := ObjBindMethod(this, "checkIfCursorOut_callback")
    
    try{
      WinGetPos(&winX, &winY, &winWidth, &winHeight, this.taskbar)
      this.taskbarData.x := winX
      this.taskbarData.y := winY
      this.taskbarData.width := winWidth
      this.taskbarData.height := winHeight
    }

  }

  hide(){
    try{
      WinHide(this.taskbar)
    }
    this.taskbarData.isShow := 0
    this.taskbarData.cursorOutTime := 0
  }

  show(){
    try{
      WinShow(this.taskbar)
    }
    this.taskbarData.isShow := 1
  }

  ; Чтобы начать отслеживание курсора на Таскбаре, вызвать эту функцию.
  startTrack(){
    this.hide()
    this.taskbarData.isTracking := 1
    try{
      SetTimer this.mousePosition_callback_func, 0
    }
    SetTimer this.mousePosition_callback_func, this.mousePosition_callback_speed
  
    this.taskbarData.checkIfTaskbarOpen_callback_func := ObjBindMethod(this, "checkIfTaskbarOpen_callback")
    SetTimer this.taskbarData.checkIfTaskbarOpen_callback_func, this.taskbarData.checkIfTaskbarOpen_callbackCallInterval

  }

  ; Чтобы остановить отслеживание курсора на Таскбаре, вызвать эту функцию.
  stopTrack(){
    this.show()
    this.taskbarData.isTracking := 0
    if(this.altTab.isTracking == 0){
      SetTimer this.mousePosition_callback_func, 0
    }
    try{
      SetTimer this.taskbarData.checkIfTaskbarOpen_callback_func, 0
    }
  }

  ; Чтобы начать отслеживание курсора, вызвать эту функцию.
  startTrackAltTab(){
    this.altTab.isTracking := 1
    SetTimer this.mousePosition_callback_func, this.mousePosition_callback_speed
  }

  ; Чтобы остановить отслеживание курсора, вызвать эту функцию.
  stopTrackAltTab(){
    this.altTab.isTracking := 0
    if(this.taskbarData.isTracking == 0){
      SetTimer this.mousePosition_callback_func, 0
    }
  }

  ; Включает отключает отслеживание курсора.
  toggle(){
    if(this.taskbarData.isTracking){
      this.stopTrack()
    }else{
      this.startTrack()
    }
  }

  ; Колбэк, который вызывается каждые 4 секунды, и проверяет, не открыт ли 
  ; ошибочно Таскбар, не установлено ли ошибочно свойство this.taskbarData.isShow.
  checkIfTaskbarOpen_callback(){
    ; if(this.taskbarData.isShow){
      try{
        MouseGetPos(&x, &y, &cursorsWin)
        local cursorsWin_ahk_class := WinGetClass(cursorsWin)
      }catch as err{
        return
      }

      ; Курсор вышел за пределы Таскбара:
      ; TaskListThumbnailWnd - это окно превью программы, сверху значка программы.
      if(y < A_ScreenHeight - this.taskbarData.height && 
        cursorsWin_ahk_class != "TaskListThumbnailWnd"){
        if(A_TickCount - this.taskbarData.cursorOutTime > 600){
          this.hide()
        }
      }
    ; }
  }

  ; Вызывается каждые 100 миллисекунд, и проверяет где находится курсор. 
  mousePosition_callback(){
    
    MouseGetPos(&x, &y, &cursorsWin)
    ; Debug.logT("x = " . x . ", y = " . y)

    if(this.taskbarData.isTracking){
      if(y >= A_ScreenHeight - 1 && GetKeyState("LCtrl", "P")){
        this.show()
      }else{
        switch this.taskbarData.corner {
          case  "BottomLeft":
            ; Курсор внизу экрана.
            if(y >= A_ScreenHeight - 1 && x <= this.taskbarData.distanceFromCorner){
              this.show()
            }
          case  "BottomRight":
            ; Курсор наверху экрана.
            if(y >= A_ScreenHeight - 1 && x >= A_ScreenWidth - this.altTab.distanceFromCorner){
              this.show()
            }
        }
      }
    }

    if(this.altTab.isTracking){
      switch this.altTab.corner {
        case  "altTabOnTaskbar_BottomLeft":
          if(y >= A_ScreenHeight - 1 && x <= this.altTab.distanceFromCorner){
            altTab("")
          }
        case  "altTabOnTaskbar_TopLeft":
          if(y <= 1 && x <= this.altTab.distanceFromCorner){
            altTab("")
          }
        case  "altTabOnTaskbar_TopRight":
          if(y <= 1 && x >= A_ScreenWidth - this.altTab.distanceFromCorner){
            altTab("")
          }
        case  "altTabOnTaskbar_BottomRight":
          if(y >= A_ScreenHeight - 1 && x >= A_ScreenWidth - this.altTab.distanceFromCorner){
            altTab("")
          }
      }
    }

    ; Когда курсор выйдет за границы Таскбара, выше, то Таскбар
    ; нужно скрыть.
    ; Не сразу. Назначаем время выхода за пределы Таскбара.
    ; И если таймаут прошёл, скрываем.

    ; Таскбар отображается.
    if(this.taskbarData.isTracking && this.taskbarData.isShow){
      local cursorsWin_ahk_class := WinGetClass(cursorsWin)
      ; Курсор вышел за пределы Таскбара:
      ; TaskListThumbnailWnd - это окно превью программы, сверху значка программы.
      if(y < A_ScreenHeight - this.taskbarData.height && 
        cursorsWin_ahk_class != "TaskListThumbnailWnd"){
        ; Время выхода курсора ещё не установлено.
        if(this.taskbarData.cursorOutTime == 0){
          this.taskbarData.cursorOutTime := A_TickCount
        }else{
          ; Курсор уже выходил один раз за пределы Таскбара.
          ; Проверяем таймаут.
          ; Курсор за пределами Таскбара больше таймаута.
          if(A_TickCount - this.taskbarData.cursorOutTime > 700){
            this.hide()
          }
        }
      }else{
        ; Курсор в пределах Таскбара.
        this.taskbarData.cursorOutTime := 0
      }
    }

  }

  ; Исправляем баг когда какая-то программа открывает Таскбар.
  showTaskbarCallback(hWnd, eventObj, dwmsEventTime, args*){
    ; Debug.log("showTaskbarCallback()")
    MouseGetPos(&x, &y, &cursorsWin)
    if(y < this.taskbarData.height){
      ; Debug.log("Error()")
      this.hide()
    }
  }

}

; Examples:

; hideTaskbar_ := HideTaskbar()
; hideTaskbar_.startTrack()


; ^#v::{
;   hideTaskbar_.toggle()
; }