; Move window, by wheel.

; Первый модификатор, который удерживается, чтобы крутить окно.
global moveWindowByWheel_mod

/**
 * Назначение/отключение хоткея.
 * @param {Integer} isEnable 
 * @param {Object} hotkeysJsonItem 
 */
moveWindowByWheel_SetHotkeys(hotkeysJsonItem){
  global hotkeyList, Modules
  ; Название id хоткея - ключ, и значение - хоткей:
  ; 14  03A	i	d	0.00	CapsLock   
  ; hotkeyList.moveWindowByWheel_Down := hotkeysJsonItem.hotkeyDisplay . " & WheelDown"
  ; hotkeyList.moveWindowByWheel_Up := hotkeysJsonItem.hotkeyDisplay . " & WheelUp"

  hotkeyList.moveWindowByWheel_Down := "sc3A & WheelDown"
  hotkeyList.moveWindowByWheel_Up := "sc3A & WheelUp"

  global moveWindowByWheel_mod := "sc3A"

  if (hotkeysJsonItem.isEnable) {
    ; Отключаем предыдущие хоткеи.
    disablePrevHotkeys()
    Hotkey hotkeyList.moveWindowByWheel_Down, moveWindowByWheel, "On"
    Hotkey hotkeyList.moveWindowByWheel_Up, moveWindowByWheel, "On"

    Modules.Hotkeys.assignedHotkeys["moveWindowByWheel_Down"] := [hotkeyList.moveWindowByWheel_Down, moveWindowByWheel, "On"]
    Modules.Hotkeys.assignedHotkeys["moveWindowByWheel_Up"] := [hotkeyList.moveWindowByWheel_Up, moveWindowByWheel, "On"]

  } else {
    disablePrevHotkeys()
  }

  ; Отключает предыдущие назначенные хоткеи.
  disablePrevHotkeys(){
    global Modules
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp("moveWindowByWheel_Down") ){
      Hotkey(Modules.Hotkeys.assignedHotkeys["moveWindowByWheel_Down"], moveWindowByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp("moveWindowByWheel_Down")  
    }
    if( Modules.Hotkeys.assignedHotkeys.HasOwnProp("moveWindowByWheel_Up") ){
      Hotkey(Modules.Hotkeys.assignedHotkeys["moveWindowByWheel_Up"], moveWindowByWheel, "Off")
      Modules.Hotkeys.assignedHotkeys.DeleteProp("moveWindowByWheel_Up")  
    }
  }

}



/**
 * 
 */
moveWindowByWheel(ThisHotkey){

  BlockInput "On"
  ; Debug().logF("moveWindowByWheel(), ThisHotkey = " . ThisHotkey)

  ; Чтобы не прокручивалась прокрутка окна, при кручении колеса. 
  global Wheel_, moveWindowByWheel_mod

  disableAllHotkeys()

  ; Координата куда передвинуть окно
  local newX := 0
  ; Координата куда передвинуть окно
  local newY := 0
  ; Ось на которой перемещается окно.
  local axis := "x"
  local speed := 0
  ; Скорость перемещения окна для быстрого перемещения. Default = 200. 
  local quickSpeed := 200
  ; Насколько увеличивать скорость перемещения окна.
  local increaseSpeedInterval := 4
  ; С каким интервалом вызывается таймер смещения окна
  local moveWindowTimerInterval := 1

  ; SetWinDelay -1

  ; Таймер уже стартован?
  local isRunning := false
  ; Таймер быстрого перемещения уже стартован?
  local isQuickRunning := false

  ; Уже вызывалась функция восстановления хоткеев?
  local isRestoreHotkeysInvoked := false

  local fastSlow_down_func := (*) => fastSlow_.down()
  local fastSlow_up_func := (*) => fastSlow_.up()

  local fastSlow_ := Wheel.FastSlow()
  fastSlow_.setCallback_GroupWheel(groupWheelCallback)
  ; fastSlow_.setCallback_Wheel(wheelCallback)

  Hotkey("sc3A & WheelDown", fastSlow_down_func, "On")
  Hotkey("sc3A & WheelUp", fastSlow_up_func, "On")

  if(RegExMatch(ThisHotkey, "WheelDown")){
    fastSlow_.down()
  }
  if(RegExMatch(ThisHotkey, "WheelUp")){
    fastSlow_.up()
  }

  local activeWindow := WinExist("A")
  if(activeWindow == 0){
    restoreHotkeys()
    return
  }

  WinGetPos(&winStartX, &winStartY, &winStartWidth, &winStartHeight, activeWindow) 

  ; Активная координата x окна.
  local activeWinX := winStartX
  ; Активная координата y окна.
  local activeWinY := winStartY

  ; Расстояние от края экрана до края окна, когда окно сдвинуто на самый край.
  ; Выступ окна.
  local gap := 40

  ; Вертикальные линии координат линий прилипания окна, если ширина окна, меньше
  ; ширины экрана.
  ; Линии с лева на право. 
  local xLines := [
    -(winStartWidth) + 10,
    -(winStartWidth) + gap,
    (A_ScreenWidth/2 - winStartWidth/2),
    (A_ScreenWidth - gap),
    A_ScreenWidth - 10
  ]

  ; Линии с верху вниз.
  local yLines := [
    -(winStartHeight) + 10,
    -(winStartHeight) + gap,
    0,
    A_ScreenHeight - gap,
    A_ScreenHeight - 10
  ]

  ; Если ширина окна больше ширины экрана.
  if(winStartWidth > A_ScreenWidth){
    ; Правый край окна прилипает к правому краю экрана.
    local rightScreenBorder := A_ScreenWidth - winStartWidth
    
    xLines := [
      -(winStartWidth) + 10,
      -(winStartWidth) + gap,
      rightScreenBorder]
      
    local xMinus := rightScreenBorder
    while true{
      xMinus := xMinus + A_ScreenWidth/2
      if(xMinus >= 0){
        xMinus := 0
        xLines.Push(xMinus)
        break
      }else{
        xLines.Push(xMinus)
      }
    }

    xLines.Push(A_ScreenWidth - gap)
    xLines.Push(A_ScreenWidth - 10)
    
    ; Debug().logF(xLines)
  }

  ; Нельзя блокировать после, потому-что кручение вверх будет отключено.
  BlockInput "Off"

  ; while GetKeyState(moveWindowByWheel_mod, "P"){   
  ;   Sleep 4
  ; }

  SetTimer waitCapsLockRelease_Timer, 4

  ; ---------------------------------------------------------
  
  waitCapsLockRelease_Timer(){
    if(!GetKeyState(moveWindowByWheel_mod, "P") && !GetKeyState("LCtrl", "P")){
      SetTimer waitCapsLockRelease_Timer, 0
      restoreHotkeys()
    }
  }


  restoreHotkeys(){

    if(isRestoreHotkeysInvoked == false){
      isRestoreHotkeysInvoked := true
    }else{
      return
    }

    Hotkey("sc3A & WheelDown", fastSlow_down_func, "Off")
    Hotkey("sc3A & WheelUp", fastSlow_up_func, "Off")

    ; Debug().logF("restoreHotkeys()")

    global Wheel_

    SetTimer moveWindow_Timer, 0
    speed := 0
    isRunning := false
    isQuickRunning := false
    isFirstStart_moveWindow_Timer := true
    activeWinX := 0
    activeWinY := 0

    ; SendEvent("{Blind}{" . moveWindowByWheel_mod . " Up}")
    
    enableAllHotkeys()
    
    SetCapsLockState("Off")
    BlockInput "Off"
    Sleep 10

  }


  /**
   * Вызывается при каждом клике колеса.
   * @param fastSlow 
   * @param args 
   */
  wheelCallback(fastSlow, args){
    if(args.upDown == "down"){
      speed := speed + increaseSpeedInterval
      moveWindowTo(args)
    }else{
      speed := speed - increaseSpeedInterval
      moveWindowTo(args)
    }
  }

  ; wheelCallback_downTimer(){

  ; }



  ; Вызывается когда колесо завершило кручение.
  groupWheelCallback(fastSlow, args){

    ; Debug().logF("groupWheelCallback()")
    ; Debug().logF(args)
    ; return

    if(isQuickRunning){
      return
    }

    if(args.upDown == "down"){
      if(args.type == "quick"){
        ; Отключаем таймер обычного перемещения.
        disableMoveWindow_Timer()
        moveWindowToRightQuick(args)
      }else{
        ; Стартуем обычное перемещение, только тогда, когда быстрое 
        ; перемещение завершило работу.
        if(isQuickRunning == false){
          ; disableMoveWindowQuick_Timer(false)
          wheelCallback(fastSlow, args)
        }
      }
    }

    if(args.upDown == "up"){
      if(args.type == "quick"){
        ; Отключаем таймер обычного перемещения.
        disableMoveWindow_Timer()
        moveWindowToLeftQuick(args)
      }else{
        ; Стартуем обычное перемещение, только тогда, когда быстрое 
        ; перемещение завершило работу.
        if(isQuickRunning == false){
          ; disableMoveWindowQuick_Timer(false)
          wheelCallback(fastSlow, args)
        }
      }
    }

  }


  /**
   * Перемещает окно быстро.
   * Устанавливает переменные:
   * - newY, newX - координаты куда передвинуть окно.
   * - axis - ось x, y.
   * - speed.
   * И стартует таймер moveWindowQuick_Timer.
   * @param args 
   */
  moveWindowToRightQuick(args){
    
    ; Debug().logF("moveWindowToRightQuick()")
    
    ; if(isCtrlPressed){
    if(GetKeyState("LCtrl", "P")){
      ; Окно сдвигается вертикально.
      ; Нужно сдвинуть окно вниз.
      ; Координата куда сдвинуть окно.
      for k, v in yLines{
        ; Если y координата окна ниже чем самая нижняя линия.
        if(activeWinY >= yLines[yLines.Length]){
          newY := yLines[yLines.Length]
          break
        }
        ; Оцениваем с верху в низ (с лева на право).
        ; - | - | - | - |
        if(activeWinY < v){
          newY := v
          break
        }
      }
  
      ; moveWindowVertically(newY, , true)
      ; SetTimer moveWindow_Timer.Bind(, newY, "y", 200, true), 20
      SetTimer moveWindowQuick_Timer, moveWindowTimerInterval
      isQuickRunning := true
      axis := "y"
      speed := quickSpeed
      moveWindowQuick_Timer()

    }else{
      ; Окно сдвигается горизонтально.
      ; Координата куда сдвинуть окно.
      for k, v in xLines{
        ; Если х координата окна правее чем самая правая линия.
        if(activeWinX >= xLines[xLines.Length]){
          newX := xLines[xLines.Length]
          break
        }
        ; - | - | - | - |
        if(activeWinX < v){
          newX := v
          break
        }
      }
  
      ; moveWindowHorizontally(newX, , true)
      ; SetTimer moveWindow_Timer.Bind(newX, , "x", 200, true), 20
      SetTimer moveWindowQuick_Timer, moveWindowTimerInterval
      isQuickRunning := true
      axis := "x"
      speed := quickSpeed
      moveWindowQuick_Timer()

    }
  }


  moveWindowToLeftQuick(args){
    ; Debug().logF("moveWindowToLeftQuick()")

    if(GetKeyState("LCtrl", "P")){
      ; Окно сдвигается вертикально.
      ; Нужно сдвинуть окно вверх.
      ; Координата куда сдвинуть окно.
      local reverseYLines := Utils.reverseArray(yLines)

      for k, v in reverseYLines{
        ; Если y координата окна выше чем самая верхняя линия.
        if(activeWinY <= reverseYLines[reverseYLines.Length]){
          newY := reverseYLines[reverseYLines.Length]
          break
        }
        ; Оцениваем снизу вверх (с лева на право здесь).
        ; - | - | - | - |
        if(activeWinY > v){
          newY := v
          break
        }
      }
  
      ; moveWindowVertically(newY, , true)
      ; SetTimer moveWindow_Timer.Bind(, newY, "y", 200, true), 2
      SetTimer moveWindowQuick_Timer, moveWindowTimerInterval
      isQuickRunning := true
      axis := "y"
      speed := quickSpeed
      moveWindowQuick_Timer()

    }else{
      ; Окно сдвигается горизонтально, влево.
      ; Координата куда сдвинуть окно.
      local reverseXLines := Utils.reverseArray(xLines)

      for k, v in reverseXLines{
        ; Если х координата окна левее чем самая левая линия.
        if(activeWinX <= reverseXLines[reverseXLines.Length]){
          newX := reverseXLines[reverseXLines.Length]
          break
        }
        ; - | - | - | - | -
        if(activeWinX > v){
          newX := v
          break
        }
      }

      ; moveWindowHorizontally(newX, , true)
      ; SetTimer moveWindow_Timer.Bind(newX, , "x", 200, true), 2
      SetTimer moveWindowQuick_Timer, moveWindowTimerInterval
      isQuickRunning := true
      axis := "x"
      speed := quickSpeed
      moveWindowQuick_Timer()

    }
  }


  /**
   * Увеличивает или уменьшает скорость кручения, устанавливает ось перемещения,
   * и стартует таймер moveWindow_Timer.
   * @param args 
   */
  moveWindowTo(args){
    
    if(GetKeyState("LCtrl", "P")){
      axis := "y"
    }else{
      axis := "x"  
    }

    if(isRunning == false){
      isRunning := true
      SetTimer moveWindow_Timer, moveWindowTimerInterval
      moveWindow_Timer()
    }

  }


  ; Ctrl было нажато? Default = false.
  local isCtrlWasPressed := false
  local isFirstStart_moveWindow_Timer := true

  /**
   * Таймер, должен вызываться каждые 2 секунды. 
   * Перемещает окно.
   * @param {Integer} newX 
   * @param {Integer} newY 
   * @param {String} axis 
   * @param {Integer} speed 
   * @param {Integer} isKeyStateIgnore 
   */
  ; moveWindow_Timer(newX := 0, newY := 0, axis := "x", speed := 200, isKeyStateIgnore := false){
  moveWindow_Timer(){
  
    ; CapsLock отжато.
    if(!GetKeyState(moveWindowByWheel_mod, "P")){
      ; if(isRunning){
        disableMoveWindow_Timer()
        restoreHotkeys()
        return
      ; }
    }

    if(isRunning == false){
      return
    }

    ; if(axis == "x"){
    if(!GetKeyState("LCtrl", "P")){
      ; Ctrl не удерживается. Возможно отжалось.

      if(isCtrlWasPressed){
        speed := 0
        isCtrlWasPressed := false
      }

      ; Изменяем координату x окна.
      activeWinX := activeWinX + speed
  
      ; Если окно слишком далеко влево.
      if(activeWinX < xLines[2]){
        activeWinX := xLines[2]
        speed := 0
      }
      ; Если окно слишком далеко вправо.
      if(activeWinX > xLines[xLines.Length - 1]){
        activeWinX := xLines[xLines.Length - 1]
        speed := 0
      }
    
      WinMove(activeWinX, , , , activeWindow) 
    }else{
      ; Ctrl удерживается.

      if(!isCtrlWasPressed){
        if(isFirstStart_moveWindow_Timer == false){
          speed := 0
        }
        isCtrlWasPressed := true
      }

      ; Изменяем координату x окна.
      activeWinY := activeWinY + speed

      ; Если окно слишком далеко влево.
      if(activeWinY < yLines[2]){
        activeWinY := yLines[2]
        speed := 0
      }
      ; Если окно слишком далеко вправо.
      if(activeWinY > yLines[yLines.Length - 1]){
        activeWinY := yLines[yLines.Length - 1]
        speed := 0
      }

      WinMove(, activeWinY, , , activeWindow) 

    }

    isFirstStart_moveWindow_Timer := false

  }



  disableMoveWindow_Timer(){
    ; isQuickRunning := false
    isRunning := false
    speed := 0
    ; Ctrl было нажато? Default = false.
    isCtrlWasPressed := false
    isFirstStart_moveWindow_Timer := true
    SetTimer moveWindow_Timer, 0
  }


/**
 * Таймер, должен вызываться каждые 2 секунды. 
 * Перемещает окно.
 * @param {Integer} newX 
 * @param {Integer} newY 
 * @param {String} axis 
 * @param {Integer} speed 
 * @param {Integer} isKeyStateIgnore 
 */
; moveWindow_Timer(newX := 0, newY := 0, axis := "x", speed := 200, isKeyStateIgnore := false){
  moveWindowQuick_Timer(){

    if(isQuickRunning == false){
      return
    }

    local isDisableMoveWindowQuick_Timer := false

    if(axis == "x"){
      
      if(activeWinX < newX){
        ; Окно нужно передвинуть вправо.
        activeWinX := activeWinX + quickSpeed
        if(activeWinX >= newX){
          activeWinX := newX
          isDisableMoveWindowQuick_Timer := true
          ; disableMoveWindowQuick_Timer()
        }
      }else{
        ; Окно нужно передвинуть влево.
        activeWinX := activeWinX - quickSpeed
        if(activeWinX <= newX){
          activeWinX := newX
          isDisableMoveWindowQuick_Timer := true
          ; disableMoveWindowQuick_Timer()
        }
      }

      WinMove(activeWinX, , , , activeWindow) 
    }else{
      ; Окно перемещается вертикально.
      
      if(activeWinY < newY){
        ; Окно нужно передвинуть вниз.
        activeWinY := activeWinY + quickSpeed
        if(activeWinY >= newY){
          activeWinY := newY
          isDisableMoveWindowQuick_Timer := true
          ; disableMoveWindowQuick_Timer()
        }
      }else{
        ; Окно нужно передвинуть вверх.
        activeWinY := activeWinY - quickSpeed
        if(activeWinY <= newY){
          activeWinY := newY
          isDisableMoveWindowQuick_Timer := true
          ; disableMoveWindowQuick_Timer()
        }
      }

      WinMove(, activeWinY, , , activeWindow) 
  
    }

    if(isDisableMoveWindowQuick_Timer){
      disableMoveWindowQuick_Timer()
    }

  }

  disableMoveWindowQuick_Timer(disableSpeed := true){
    ; isRunning := false
    SetTimer moveWindowQuick_Timer, 0
    ; Чтобы окно не продолжало перемещаться после быстрого перемещения,
    ; если колесо всё ещё крутится.
    Sleep 100
    isQuickRunning := false
    if(disableSpeed){
      speed := 0
    }
  }



}

 





