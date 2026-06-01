
; Открывает меню только при одиночном правом клике
; Это вызывается когда правый клик отжался.
; fixRButtonOpenMenu(*) {
;   if GetKeyState("LButton", "P") {
;     return
;   }
;   Click("R")
; }

; Время отжатия правого клика
; global RButtonReleaseTime := 0
; ; Правая кнопка мыши удерживается?
; global RButtonIsPressed := false

/**
 * Функция хоткея LButton, которая существует временно,
 * после отжатия правого клика.
 */
; LButtonWhenReleaseRButton_Hotkey(*){
;   if(RButtonIsPressed == false){
;     local timeFromRClick := A_TickCount - RButtonReleaseTime
;     if(timeFromRClick < 100){
;       Send "^{LButton}"
;     }
;     ; Debug().logF(timeClick)
;   }
; }


; LButtonWhenReleaseRButton_HotkeyDisable(){
;   try{
;     Hotkey "*LButton", LButtonWhenReleaseRButton_Hotkey, "Off"
;   }
; }

/**
 * Функция хоткея RButton.
 * Вызывается когда нажат правый клик.
 * @param ThisHotkey 
 */
fixRButtonOpenMenu(ThisHotkey){
  global Wheel_, hotGestures_
  
  ; global RButtonReleaseTime, RButtonIsPressed

  ; RButtonIsPressed := true
  ; try{
  ;   Hotkey "*LButton", "Off"
  ; }
  ; Hotkey "*LButton", LButtonWhenReleaseRButton_Hotkey, "On"

  try{

  ; Hotkey "*RButton Up", "Off"
  Hotkey "RButton", fixRButtonOpenMenu, "Off"
  Hotkey "LButton", emptyFunc, "On"

  ; Hotkey "RButton Up", emptyFunc, "On"

  ; id окна где кликнуто.
  local winIdStartClicking
  MouseGetPos , , &winIdStartClicking
  ; Debug().logF(winIdStartClicking)

  if(MouseIsOverWindows(["WorkerW"]) == false){
	  WinActivate("ahk_id " . winIdStartClicking)
  }

  Wheel_.downStack := []
  Wheel_.upStack := []

  Hotkey("*WheelDown", (*) => Wheel_.down(), "On T2")
  Hotkey("*WheelUp", (*) => Wheel_.up(), "On T2")

  ; Какой-нибудь хоткей сработал?, при записи жестов.
  ; Например: кручение колеса, левый клик.
  local isTriggeredHotkey := false
  global hotkeysActions 

  ; Start recording
  if(hotkeysActions.gestures){
    hotGestures_.Start() 
  }

  while GetKeyState("RButton", "P"){

    if(hotkeysActions.RButtonAndWheel != 0){

      ; Было кручение колеса вниз.
      if(Wheel_.downStack.Length > 0){  

        ; Останавливаем запись жестов. Это не жест.
        if(isTriggeredHotkey == false){
          isTriggeredHotkey := true
          if(hotkeysActions.gestures){
            hotGestures_.Stop()      
          }
        }

        if(hotkeysActions.RButtonAndWheel == "minimizeMaximizeWindow"){
          minimizeWindowBy_RButtonAndWheel("RButton")
        }
        if(hotkeysActions.RButtonAndWheel == "nextPrevTab"){
          nextTabByRButtonWheel(ThisHotkey)
          Wheel_.waitWheelStop()
        }

        Wheel_.downStack := []

      }

      ; Было кручение колеса вверх
      if(Wheel_.upStack.Length > 0){  

        ; Останавливаем запись жестов. Это не жест.
        if(isTriggeredHotkey == false){
          isTriggeredHotkey := true
          if(hotkeysActions.gestures){
            hotGestures_.Stop()      
          }
        }

        if(hotkeysActions.RButtonAndWheel == "minimizeMaximizeWindow"){
          maximizeWindowBy_RButtonAndWheel("RButton")
        }
        if(hotkeysActions.RButtonAndWheel == "nextPrevTab"){
          prevTabByRButtonWheel(ThisHotkey)
          Wheel_.waitWheelStop()
        }

        Wheel_.upStack := []

      }

    }

    ; Был нажат левый клик.
    if(GetKeyState("LButton", "P")){
      isTriggeredHotkey := true
      ; Stop recording
      if(hotkeysActions.gestures){
        hotGestures_.Stop() 
      }
      resetHotkeys()

      global linkClick_isEnable
      if(linkClick_isEnable){
        ; Курсор вида над ссылкой. 
        if(A_Cursor == "Unknown"){
          Send "^{LButton}"
          return
        }
      }

      move_window_with_left_right_mouse_button(ThisHotkey)
      return
    }

    ; Sleep 1
  }

  ; RButtonIsPressed := false
  ; RButtonReleaseTime := A_TickCount
  if(hotkeysActions.gestures){
    if(isTriggeredHotkey == false){  
      stopRecordingGesture(isTriggeredHotkey, winIdStartClicking)
    }
  }else{
    Click("R")
  }

  }catch as err{
    resetHotkeys()
  }

  resetHotkeys(){
    ; Чтобы избавиться от бага, открытие меню правого клика.
    Sleep 100
    Hotkey("*WheelDown", "Off")
    Hotkey("*WheelUp", "Off")
    Wheel_.downStack := []
    Wheel_.upStack := []
    
    ; Hotkey "*RButton Up", emptyFunc, "Off"
    Hotkey "RButton", fixRButtonOpenMenu, "On T2"
    Hotkey "LButton", emptyFunc, "Off"
    ; Hotkey "RButton Up", emptyFunc, "Off"
  }
  resetHotkeys()
  ; SetTimer LButtonWhenReleaseRButton_HotkeyDisable, -1000

}

; Hotkey "RButton", emptyFunc, "On"
Hotkey "RButton", fixRButtonOpenMenu, "On T2"
; Hotkey "RButton", fixRButtonOpenMenu, "On"
Modules.Hotkeys.assignedHotkeys["RButton"] := "RButton"

; RButton Up::{
;   MsgBox "RButton Up"
; }


/**
 * Назначает Hotkey(), или отключает Hotkey(), для перемещения окна
 * двумя кликами, или изменения размеров окна.
 * @param {Integer} isEnable 
 */
move_resize_window_with_left_right_mouse_button_setHotkeys(hotkeysJsonItem) {
  global Modules
  if (hotkeysJsonItem.isEnable) {
    ; HotIf !MouseIsOverWindows(["WorkerW", "XamlExplorerHostIslandWindow"])
    ; HotIf CursorIsNotOverDesktop

    Hotkey "~LButton & RButton", move_window_with_left_right_mouse_button, "On I2"
    ; RButton - это отключит нативную функцию - открыть меню правого клика.
    ; Hotkey "RButton & ~LButton", move_window_with_left_right_mouse_button, "On I2"
    ; Исправляем RButton меню.

    Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_LR"] := "~LButton & RButton"
    ; Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_RL"] := "RButton & ~LButton"
    ; Modules.Hotkeys.assignedHotkeys[hotkeysJsonItem.id . "_R"] := "RButton"

    ; HotIf
  } else {
    ; Error: Nonexistent hotkey variant (IfWin).
    ; HotIf CursorIsNotOverDesktop
    try{
      Hotkey "~LButton & RButton", "Off"
    }
    ; RButton - это отключит нативную функцию - открыть меню правого клика.
    ; Hotkey "RButton & ~LButton", "Off"
    ; Исправляем RButton меню.
    ; Hotkey "RButton", "Off"

    Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_LR")
    ; Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_RL")  
    ; Modules.Hotkeys.assignedHotkeys.DeleteProp(hotkeysJsonItem.id . "_R")  

  }

}


/**
 * Изменяет размеры окна. Не вызывается напрямую.
 * Вызывается из move_window_with_left_right_mouse_button().
 * @param ThisHotkey 
 * @returns {Any} 
 */
resize_window_with_left_right_mouse_button(ThisHotkey, cursorWinId, xLines, yLines) {

  ; XamlExplorerHostIslandWindow - окно AltTab.
  ; WorkerW - дэсктоп. 
  ; if (MouseIsOverWindows(["WorkerW", "XamlExplorerHostIslandWindow"])) {
  if (MouseIsOverWindows(["WorkerW"])) {
    return
  }

  ; Клавиша модификатор, при удержании которой, будет включаться прилипание 
  ; к краям. 
  local snapMod := "LShift"

  ; Это должно быть перед перетаскиванием окна - Move Window.
  ; m в начале - это мышь, курсор.
  ; w в начале - это окно.
  ; Расстояние, ширина, от курсора до края окна, которое всегда постоянно.
  local mWidth := 0
  ; Расстояние, высота, от курсора до края окна, которое всегда постоянно.
  local mHeight := 0
  local wNewWidth := 0
  local wNewHeight := 0

  ; Координата Х курсора относительно окна, в начале клика.
  local mStartX_RelWin 
  ; Координата Y курсора относительно окна, в начале клика.
  local mStartY_RelWin
  ; Координата x курсора, относительно экрана, в начале клика.
  local mStartX
  ; Координата y курсора, относительно экрана, в начале клика.
  local mStartY
  ; Ширина окна, в начале клика.
  local wStartWidth
  ; Высота окна, в начале клика.
  local wStartHeight
  ; Координата x окна, относительно экрана, в начале клика.
  local wStartX
  ; Координата y окна, относительно экрана, в начале клика.
  local wStartY

  ; Размеры окна, до разворачивания этого окна на всю высоту экрана.
  ; Чтобы вернуть к изначальным.
  static sizeWindowBeforeHeightMaximize := {
    x: 0,
    y: 0,
    width: 1717,
    height: 901
  }
  ; Размеры окна, до разворачивания этого окна на всю гирину экрана.
  ; Чтобы вернуть к изначальным.
  static sizeWindowBeforeWidthMaximize := {
    x: 0,
    y: 0,
    width: 1717,
    height: 901
  }

  Wheel_.downStack := []
  Wheel_.upStack := []
  
  Hotkey("*WheelDown", (*) => Wheel_.down(), "On T2")
  Hotkey("*WheelUp", (*) => Wheel_.up(), "On T2")

  ; Hotkey("*WheelDown", (*) => Wheel_.down(), "On")
  ; Hotkey("*WheelUp", (*) => Wheel_.up(), "On")

  ; Координаты курсора относительно экрана
  CoordMode("Mouse", "Screen")

  ; Получаем координаты курсора, относительно экрана, и ид окна.
  MouseGetPos(&mStartX, &mStartY)

  ; Окно развёрнуто на весь экран? = 1.
  if WinGetMinMax("ahk_id " cursorWinId) {
    ; MsgBox "T"
    ; Отжимаем состояние CapsLock (лампочка не горит)
    ; SetCapsLockState 0
    return
  }

  ; Получаем:
  ; 1, 2 - координаты левого верхнего угла окна.
  ; 3, 4 - ширина и высота окна.
  WinGetPos(&wStartX, &wStartY, &wStartWidth, &wStartHeight, "ahk_id " cursorWinId)

  mStartX_RelWin := mStartX - wStartX
  mStartY_RelWin := mStartY - wStartY

  ; Зона в окне где находится курсор.
  local cursorZone := getCursorZoneInWindow(mStartX_RelWin, mStartY_RelWin,
    wStartWidth, wStartHeight)
  
  ; Курсоры: 
  ; https://love2d.org/wiki/CursorType

  ; Вычисляем расстояния от курсора до краёв окна, которое всегда должно
  ; быть постоянным.
  if (cursorZone.zone9 == 1) {
    ; Курсор слева наверху.
    mWidth := mStartX_RelWin
    mHeight := mStartY_RelWin
    RestoreCursor()
    SetSystemCursor("SIZENWSE")
  }
  if (cursorZone.zone9 == 2) {
    mWidth := 0
    mHeight := mStartY_RelWin
    RestoreCursor()
    SetSystemCursor("sizens")
  }
  if (cursorZone.zone9 == 3) {
    ; Курсор справа сверху.
    ; Ширина от курсора, до правой стороны окна.
    mWidth := wStartX + wStartWidth - mStartX
    ; Высота от курсора, до верхней стороны окна.
    mHeight := mStartY - wStartY
    RestoreCursor()
    SetSystemCursor("SIZENESW")
  }

  if (cursorZone.zone9 == 4) {
    ; Ширина от курсора, до правой стороны окна.
    mWidth := wStartX + wStartWidth - mStartX
    ; Высота от курсора, до верхней стороны окна.
    mHeight := mStartY - wStartY
    RestoreCursor()
    SetSystemCursor("sizewe")
  }

  if (cursorZone.zone9 == 5) {
    ; Курсор справа внизу.
    ; Ширина от курсора, до правой стороны окна.
    mWidth := wStartX + wStartWidth - mStartX
    ; Высота от курсора, до нижней стороны окна.
    mHeight := wStartY + wStartHeight - mStartY
    RestoreCursor()
    SetSystemCursor("SIZENWSE")
  }

  if (cursorZone.zone9 == 6) {
    ; Курсор справа внизу.
    ; Ширина от курсора, до правой стороны окна.
    mWidth := wStartX + wStartWidth - mStartX
    ; Высота от курсора, до нижней стороны окна.
    mHeight := wStartY + wStartHeight - mStartY
    RestoreCursor()
    SetSystemCursor("sizens")
  }

  if (cursorZone.zone9 == 7) {
    ; Курсор слева внизу.
    ; Ширина от курсора, до левой стороны окна.
    mWidth := mStartX - wStartX
    ; Высота от курсора, до нижней стороны окна.
    mHeight := (wStartY + wStartHeight) - mStartY
    RestoreCursor()
    SetSystemCursor("SIZENESW")
  }

  if (cursorZone.zone9 == 8) {
    ; Первая колонка, в середине.
    mWidth := mStartX - wStartX
    mHeight := (wStartY + wStartHeight) - mStartY
    RestoreCursor()
    SetSystemCursor("sizewe")
  }

  if (cursorZone.zone9 == 9) {
    ; Середина. Вторая колонка, в середине.
    ; https://learn.microsoft.com/en-us/windows/win32/menurc/about-cursors
    if(cursorZone.zone4 == 2 || cursorZone.zone4 == 3){
      ; Ширина от курсора, до правой стороны окна.
      mWidth := wStartX + wStartWidth - mStartX
      RestoreCursor()
      SetSystemCursor("icons/toRightScroll.cur")
    }else{
      ; Ширина от курсора, до левой стороны окна.
      mWidth := mStartX - wStartX
      mHeight := (wStartY + wStartHeight) - mStartY
      RestoreCursor()
      SetSystemCursor("icons/toLeftScroll.cur")
    }
  }


  ; Крутим безконечный цикл, и проверяем кнопки - Shift, и
  ; левый клик.
  Loop
  {

    if (!GetKeyState("RButton", "P")) {
      ; Отжато правый клик.

      ; Send "{Blind}{LWin Up}"
      restoreResizeHotkeys()
      ; return move_window_with_left_right_mouse_button(ThisHotkey)
      return
    }else{
      ; Правый клик нажат.

      if (GetKeyState("LButton", "P")) {
        ; Левый клик нажат
        restoreResizeHotkeys()
        ; return move_window_with_left_right_mouse_button(ThisHotkey)
        return
      }
    }

    ; Ждём пока курсор сместится
    Sleep(10)

    if(Wheel_.upStack.Length > 0){

      ; Debug().logF("upStack")

      if(wStartWidth < A_ScreenWidth){
        sizeWindowBeforeWidthMaximize.x := wStartX
        sizeWindowBeforeWidthMaximize.y := wStartY
        sizeWindowBeforeWidthMaximize.width := wStartWidth
        sizeWindowBeforeWidthMaximize.height := wStartHeight
      }

      if(wStartWidth == A_ScreenWidth){
        restoreWindowToSizesBeforeWidthMaximize(&wStartX, &wStartY, &wStartWidth, &wStartHeight)
      }else{
        maximizeWidthOfWindow(&wStartX, &wStartY, &wStartWidth, &wStartHeight)
      }

      Wheel_.waitWheelStop(200)
      Wheel_.downStack := []
      Wheel_.upStack := []

      ; Обязательно выйти, или будут неправильные смещения курсора.
      restoreResizeHotkeys()
      return
    }


    if(Wheel_.downStack.Length > 0){

      ; Debug().logF("downStack")

      if(wStartHeight < A_ScreenHeight){
        sizeWindowBeforeHeightMaximize.x := wStartX
        sizeWindowBeforeHeightMaximize.y := wStartY
        sizeWindowBeforeHeightMaximize.width := wStartWidth
        sizeWindowBeforeHeightMaximize.height := wStartHeight
      }

      if(wStartHeight == A_ScreenHeight){
        restoreWindowToSizesBeforeHeightMaximize(&wStartX, &wStartY, &wStartWidth, &wStartHeight)
      }else{
        maximizeHeightOfWindow(&wStartX, &wStartY, &wStartWidth, &wStartHeight)
      }

      Wheel_.waitWheelStop(200)
      Wheel_.downStack := []
      Wheel_.upStack := []

      ; Обязательно выйти, или будут неправильные смещения курсора.
      restoreResizeHotkeys()
      return
    }

    ; Получаем новые координаты курсора
    MouseGetPos(&newMX, &newMY)

    if (cursorZone.zone9 == 1) {    
      ; Курсор слева наверху.
      wNewWidth := ((wStartX + wStartWidth) - newMX) + mWidth
      wNewHeight := ((wStartY + wStartHeight) - newMY) + mHeight

      local winNewY := newMY - mHeight
      local winNewX := newMX - mWidth

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(winNewX, winNewY, wNewWidth, wNewHeight, 
          xLines, yLines, {left: 1, top: 1, right: 0, bottom: 0})

        winNewX := snapArgs.winX
        winNewY := snapArgs.winY
        wNewWidth := snapArgs.winWidth
        wNewHeight := snapArgs.winHeight
      }

      WinMove(winNewX,
        winNewY,
        wNewWidth,
        wNewHeight,
        "ahk_id " cursorWinId
      )
    }

    if (cursorZone.zone9 == 2) {    
      wNewHeight := ((wStartY + wStartHeight) - newMY) + mHeight
      local winNewY := newMY - mHeight

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(wStartX, winNewY, wStartWidth, wNewHeight, 
          xLines, yLines, 
          {left: 0, top: 1, right: 0, bottom: 0})
        winNewY := snapArgs.winY
        wNewHeight := snapArgs.winHeight
      }

      WinMove(,
        winNewY,
        ,
        wNewHeight,
        "ahk_id " cursorWinId
      )
    }

    if (cursorZone.zone9 == 3) {    
      ; Курсор справа наверху.
      wNewWidth := newMX - wStartX + mWidth
      wNewHeight := wStartY + wStartHeight - newMY + mHeight

      local winNewX := wStartX
      local winNewY := newMY - mHeight

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(winNewX, winNewY, wNewWidth, wNewHeight, 
          xLines, yLines, {left: 0, top: 1, right: 1, bottom: 0})

        winNewX := snapArgs.winX
        winNewY := snapArgs.winY
        wNewWidth := snapArgs.winWidth
        wNewHeight := snapArgs.winHeight
      }

      WinMove(winNewX,
        winNewY,
        wNewWidth,
        wNewHeight,
        "ahk_id " cursorWinId
      )
    }

    if (cursorZone.zone9 == 4) {    

      wNewWidth := newMX - wStartX + mWidth

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(wStartX, wStartY, wNewWidth, wStartHeight, 
          xLines, yLines, {left: 0, top: 0, right: 1, bottom: 0})

        wNewWidth := snapArgs.winWidth
      }

      ; MsgBox wNewWidth . ", " . A_ScreenWidth
      WinMove(,
        ,
        wNewWidth,
        ,
        "ahk_id " cursorWinId
      )
    }

    if (cursorZone.zone9 == 5) {    
      ; Курсор справа внизу.
      wNewWidth := newMX - wStartX + mWidth
      wNewHeight := newMY - wStartY + mHeight

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(wStartX, wStartY, wNewWidth, wNewHeight, 
          xLines, yLines, {left: 0, top: 0, right: 1, bottom: 1})

        wNewWidth := snapArgs.winWidth
        wNewHeight := snapArgs.winHeight
      }

      WinMove(,
        ,
        wNewWidth,
        wNewHeight,
        "ahk_id " cursorWinId
      )
    }

    if (cursorZone.zone9 == 6) {    
      ; Курсор внизу.
      wNewHeight := newMY - wStartY + mHeight

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(wStartX, wStartY, wStartWidth, wNewHeight, 
          xLines, yLines, {left: 0, top: 0, right: 0, bottom: 1})

        wNewHeight := snapArgs.winHeight
      }

      WinMove(,
        ,
        ,
        wNewHeight,
        "ahk_id " cursorWinId
      )
    }

    if (cursorZone.zone9 == 7) {    
      ; Курсор слева внизу.

      wNewWidth := ((wStartX + wStartWidth) - newMX) + mWidth
      wNewHeight := (newMY + mHeight) - wStartY
      local wNewX := newMX - mWidth

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(wNewX, wStartY, wNewWidth, wNewHeight, 
          xLines, yLines, {left: 1, top: 0, right: 0, bottom: 1})

        wNewWidth := snapArgs.winWidth
        wNewHeight := snapArgs.winHeight
        wNewX := snapArgs.winX
      }

      WinMove(wNewX,
        ,
        wNewWidth,
        wNewHeight,
        "ahk_id " cursorWinId
      )
    }


    if (cursorZone.zone9 == 8) {    
      ; Первая колонка, в середине.

      wNewWidth := ((wStartX + wStartWidth) - newMX) + mWidth
      local wNewX := newMX - mWidth

      if(GetKeyState(snapMod, "P")){
        local snapArgs := getWinMoveArgsWithSnap_ForResize(wNewX, wStartY, wNewWidth, wStartHeight, 
          xLines, yLines, {left: 1, top: 0, right: 0, bottom: 0})

        wNewWidth := snapArgs.winWidth
        wNewX := snapArgs.winX
      }

      WinMove(wNewX,
        ,
        wNewWidth,
        ,
        "ahk_id " cursorWinId
      )
    }

    if (cursorZone.zone9 == 9) {
      ; Вторая колонка, в середине.
      if(cursorZone.zone4 == 2 || cursorZone.zone4 == 3){
        
        wNewWidth := newMX - wStartX + mWidth
        local winNewX := A_ScreenWidth/2 - wNewWidth/2

        if(GetKeyState(snapMod, "P")){
          local snapArgs := getWinMoveArgsWithSnap_ForResize(winNewX, wStartY, wNewWidth, wStartHeight, 
            xLines, yLines, {left: 1, top: 0, right: 1, bottom: 0})
  
          wNewWidth := snapArgs.winWidth
          winNewX := snapArgs.winX
        }
  
        ; MsgBox wNewWidth . ", " . A_ScreenWidth
        WinMove(winNewX,
          ,
          wNewWidth,
          ,
          "ahk_id " cursorWinId
        )

      }else{
  
        wNewWidth := ((wStartX + wStartWidth) - newMX) + mWidth
        local winNewX := A_ScreenWidth/2 - wNewWidth/2
        
        if(GetKeyState(snapMod, "P")){
          local snapArgs := getWinMoveArgsWithSnap_ForResize(winNewX, wStartY, wNewWidth, wStartHeight, 
            xLines, yLines, {left: 1, top: 0, right: 1, bottom: 0})

          wNewWidth := snapArgs.winWidth
          winNewX := snapArgs.winX
        }

        WinMove(winNewX,
          ,
          wNewWidth,
          ,
          "ahk_id " cursorWinId
        )

      }
    } ; Zone 9


  } ; Loop
  
  ; -------------------------------------------------------------

  restoreResizeHotkeys(){
    global Wheel_
    Wheel_.downStack := []
    Wheel_.upStack := []
    Hotkey("*WheelDown", "Off")
    Hotkey("*WheelUp", "Off")
  }

  ; Восстанавливает окно к размерам которые были до разворачивания окна 
  ; на всю высоту экрана.
  restoreWindowToSizesBeforeHeightMaximize(&wStartX, &wStartY, 
    &wStartWidth, &wStartHeight){
    ; Debug().logF("restoreWindowToSizesBeforeHeightMaximize()")
    wStartX := sizeWindowBeforeHeightMaximize.x
    wStartY := sizeWindowBeforeHeightMaximize.y
    wStartWidth := sizeWindowBeforeHeightMaximize.width
    wStartHeight := sizeWindowBeforeHeightMaximize.height
    
    WinMove(wStartX,
      wStartY,
      wStartWidth,
      wStartHeight,
      "ahk_id " cursorWinId
    )
  }

  ; Восстанавливает окно к размерам которые были до разворачивания окна
  ; на всю ширину экрана.
  restoreWindowToSizesBeforeWidthMaximize(&wStartX, &wStartY, 
    &wStartWidth, &wStartHeight){
    ; Debug().logF("restoreWindowToSizesBeforeWidthMaximize()")
    wStartX := sizeWindowBeforeWidthMaximize.x
    wStartY := sizeWindowBeforeWidthMaximize.y
    wStartWidth := sizeWindowBeforeWidthMaximize.width
    wStartHeight := sizeWindowBeforeWidthMaximize.height

    WinMove(wStartX,
      wStartY,
      wStartWidth,
      wStartHeight,
      "ahk_id " cursorWinId
    )
  }

  ; Развернуть окно во всю высоту экрана.
  maximizeHeightOfWindow(&wStartX, &wStartY, &wStartWidth, &wStartHeight){
    ; Debug().logF("maximizeHeightOfWindow()")
    wStartY := 0
    wStartHeight := A_ScreenHeight
    WinMove(,
      wStartY,
      ,
      wStartHeight,
      "ahk_id " cursorWinId
    )
  }

  ; Развернуть окно во всю ширину экрана.
  maximizeWidthOfWindow(&wStartX, &wStartY, &wStartWidth, &wStartHeight){
    ; Debug().logF("maximizeWidthOfWindow()")
    wStartX := 0
    wStartWidth := A_ScreenWidth
    WinMove(wStartX,
      ,
      wStartWidth,
      ,
      "ahk_id " cursorWinId
    )
  }

}


/**
 * Возвращает аргументы для функции WinMove(), с учётом линий прилипания, 
 * для изменения размеров окна.
 * @param winX - координата x окна, которая должна быть у окна изначально.
 * @param winY - координата y окна, которая должна быть у окна изначально.
 * @param winWidth - ширина окна, которая должна быть у окна изначально.
 * @param winHeight - высота окна, которая должна быть у окна изначально.
 * @param {Map} xLines - объект Map(), где ключи это вертикальные линии, x координаты, где нужно прилипать.
 * @param {Map} yLines - объект Map(), где ключи это горизонтальные линии, y координаты, где нужно прилипать.
 * @param {Object} side - какая сторона окна должна прилипать?
 * @param {Integer} snapDistance - расстояние в пикселях, когда начинается примагничевание.
 * @returns {Object} 
 */
getWinMoveArgsWithSnap_ForResize(winX := 0, winY := 0, winWidth := 0, winHeight := 0, 
  xLines := Map(), yLines := Map(), 
  side := {left: 1, top: 1, right: 0, bottom: 0}, 
  snapDistance := 20){
  
  local retObj := {
    winX: winX, winY: winY, winWidth: winWidth, winHeight: winHeight
  }

  ; Перебираем вертикальные линии
  for x, _ in xLines{
    ; Немного левее линии прилипания.
    local leftSnap := x - snapDistance
    ; Немного правее линии прилипания.
    local rightSnap := x + snapDistance
    ; Проверка левой стороны окна на прилипание.
    if(side.left){
      if(winX > leftSnap && winX < rightSnap){
        if(side.right){
          retObj.winWidth := retObj.winWidth
        }else{
          retObj.winWidth := retObj.winWidth - (x - winX)
        }

        retObj.winX := x
        ; break
      }
    }
    ; Проверка правой стороны окна на прилипание.
    if(side.right){
      if((winX + winWidth) > leftSnap && (winX + winWidth) < rightSnap){
        if(side.left){
          retObj.winWidth := x
        }else{
          retObj.winWidth := x - winX
        }
        ; break
      }
    }
  }

  ; Перебираем горизонтальные линии
  for y, _ in yLines{
    ; Немного выше линии прилипания.
    local topSnap := y - snapDistance
    ; Немного ниже линии прилипания.
    local bottomSnap := y + snapDistance
    ; Проверка верхней стороны окна на прилипание.
    if(side.top){
      if(winY > topSnap && winY < bottomSnap){
        retObj.winHeight := retObj.winHeight - (y - winY)
        retObj.winY := y
        ; break
      }
    }
    ; Проверка нижней стороны окна на прилипание.
    if(side.bottom){
      if((winY + winHeight) > topSnap && (winY + winHeight) < bottomSnap){
        retObj.winHeight := y - winY
        ; break
      }
    }
  }

  return retObj
}



/**
 * Возвращает аргументы для функции WinMove(), с учётом линий прилипания, 
 * для перемещения окна.
 * @param winX - координата x окна, которая должна быть у окна изначально.
 * @param winY - координата y окна, которая должна быть у окна изначально.
 * @param winWidth - ширина окна, которая должна быть у окна изначально.
 * @param winHeight - высота окна, которая должна быть у окна изначально.
 * @param {Map} xLines - объект Map(), где ключи это вертикальные линии, x координаты, где нужно прилипать.
 * @param {Map} yLines - объект Map(), где ключи это горизонтальные линии, y координаты, где нужно прилипать.
 * @param {Object} side - какая сторона окна должна прилипать?
 * @param {Integer} snapDistance - расстояние в пикселях, когда начинается примагничевание.
 * @returns {Object} 
 */
getWinMoveArgsWithSnap_ForMove(winX := 0, winY := 0, winWidth := 0, winHeight := 0, 
  xLines := Map(), yLines := Map(), 
  side := {left: 1, top: 1, right: 1, bottom: 1}, 
  snapDistance := 20){
  
  local retObj := {
    winX: winX, winY: winY, winWidth: winWidth, winHeight: winHeight
  }

  ; Перебираем вертикальные линии
  for x, _ in xLines{
    ; Немного левее линии прилипания.
    local leftSnap := x - snapDistance
    ; Немного правее линии прилипания.
    local rightSnap := x + snapDistance
    ; Проверка левой стороны окна на прилипание.
    if(side.left){
      if(winX > leftSnap && winX < rightSnap){
        ; if(side.right){
        ;   retObj.winWidth := retObj.winWidth
        ; }else{
        ;   retObj.winWidth := retObj.winWidth - (x - winX)
        ; }
        retObj.winX := x
        ; break
      }
    }
    ; Проверка правой стороны окна на прилипание.
    if(side.right){
      if((winX + winWidth) > leftSnap && (winX + winWidth) < rightSnap){
        ; if(side.left){
        ;   retObj.winWidth := x
        ; }else{
        ;   retObj.winWidth := x - winX
        ; }
        ; break
        retObj.winX := x - winWidth
      }
    }
  }

  ; Перебираем горизонтальные линии
  for y, _ in yLines{
    ; Немного выше линии прилипания.
    local topSnap := y - snapDistance
    ; Немного ниже линии прилипания.
    local bottomSnap := y + snapDistance
    ; Проверка верхней стороны окна на прилипание.
    if(side.top){
      if(winY > topSnap && winY < bottomSnap){
        ; retObj.winHeight := retObj.winHeight - (y - winY)
        retObj.winY := y
        ; break
      }
    }
    ; Проверка нижней стороны окна на прилипание.
    if(side.bottom){
      if((winY + winHeight) > topSnap && (winY + winHeight) < bottomSnap){
        ; retObj.winHeight := y - winY
        retObj.winY := y - winHeight
        ; break
      }
    }
  }

  return retObj
}


/**
 * Возвращает зону у окна, где находится курсор, объект вида:
 * {
    "zone4": 4,
    "zone9": 7
  }
    У zone4 - 4 зоны. Зоны нумеруются с 1. Сверху вправо, вниз, влево.
    У zone9 - 9 зон. 
 * @param xCur - x координата курсора, относительно окна.
 * @param yCur - y координата курсора, относительно окна.
 * @param windowWidth - ширина окна.
 * @param windowHeight - высота окна.
 * @param {Integer} xMiddleZoneWithPercent - процент ширины средней зоны у ширины окна. 
 * @param {Integer} yMiddleZoneHeightPercent - процент ширины средней зоны у высоты окна.
 * @returns {Object} 
 */
getCursorZoneInWindow(xCur, yCur, windowWidth, windowHeight, 
  xMiddleZoneWithPercent := 33, yMiddleZoneHeightPercent := 33){

  local retObj := {
    ; 1,2,3,4 - слева сверху, направо, вниз.
    zone4: 0,
    ; 9 - это зона в середине. 
    zone9: 0 
  }

  ; Процент координаты x, вертикальной линии 1, для зон 9.
  local zone9_XLine1 := (100 - xMiddleZoneWithPercent) / 2
  ; Процент координаты x, вертикальной линии 2, для зон 9.
  local zone9_XLine2 := 100 - ((100 - xMiddleZoneWithPercent) / 2)
  ; Процент координаты y, горизонтальной линии 1, для зон 9.
  local zone9_YLine1 := (100 - yMiddleZoneHeightPercent) / 2
  ; Процент координаты y, горизонтальной линии 2, для зон 9.
  local zone9_YLine2 := 100 - ((100 - yMiddleZoneHeightPercent) / 2)

  ; Процент x координаты курсора, от ширины окна.
  local xCurPercent := getPercentCoordinateOfCursor(xCur, windowWidth)
  ; Процент y координаты курсора, от высоты окна.
  local yCurPercent := getPercentCoordinateOfCursor(yCur, windowHeight)

  ; Для Зона4:
  if(xCurPercent <= 50){
    ; Левая сторона.
    if(yCurPercent <= 50){
      retObj.zone4 := 1
    }else{
      retObj.zone4 := 4
    }
  }else{
    ; Правая сторона.
    if(yCurPercent <= 50){
      retObj.zone4 := 2
    }else{
      retObj.zone4 := 3
    }
  }

  ; Для Зона9:
  if(xCurPercent <= zone9_XLine1){
    ; Первый столбец.

    if(yCurPercent <= zone9_YLine1){
      ; Первая строка.
      retObj.zone9 := 1
    }else if(yCurPercent <= zone9_YLine2){
      ; Вторая строка.
      retObj.zone9 := 8
    }else{
      ; Третяя строка.
      retObj.zone9 := 7
    }

  }else if(xCurPercent <= zone9_XLine2){
    ; Второй столбец.

    if(yCurPercent <= zone9_YLine1){
      ; Первая строка.
      retObj.zone9 := 2
    }else if(yCurPercent <= zone9_YLine2){
      ; Вторая строка.
      retObj.zone9 := 9
    }else{
      ; Третяя строка.
      retObj.zone9 := 6
    }

  }else{
    ; Третий столбец.

    if(yCurPercent <= zone9_YLine1){
      ; Первая строка.
      retObj.zone9 := 3
    }else if(yCurPercent <= zone9_YLine2){
      ; Вторая строка.
      retObj.zone9 := 4
    }else{
      ; Третяя строка.
      retObj.zone9 := 5
    }

  }
  
  return retObj

  ; -----------------------------------------------------------------
  /**
   * Возвращает процент координаты курсора, от ширины, или высоты окна.
   * @param xCur - x, или y координата относительно окна.
   * @param windowWidth - ширина, или высота окна.
   * @returns {Number} 
   */
  getPercentCoordinateOfCursor(xCur, windowWidth){
    return (xCur / windowWidth) * 100
  }
  
}




/**
 * Восстанавливает хоткеи, и курсор.
 * Требуется вызывать в конце работы функции перетаскивания окон.
 */
move_window_restoreHotkeys(cursorWinId := ""){
  RestoreCursor()
  ; try{
  ;   Hotkey "<^RButton", "On"
  ; }catch as err{
  ;   try{
  ;     Hotkey "^RButton", "On"
  ;   }
  ; }
  Hotkey "*RButton", emptyFunc, "Off"
  ; Hotkey "*LButton", emptyFunc, "Off"

  enableAllHotkeys()

  ; releaseModifiers()
  SetTimer releaseModifiers, -1

  ; SetTimer releaseModifiers, 20
  ; SetTimer releaseModifiers_disableTimer, -100

  ; Нужно обязательно вызвать два раза, а то не отжимается.
  SendEvent "{Blind}{LButton Up}"
  SendEvent "{Blind}{LButton Up}"
  global topTransparentNotClickableWindow
  topTransparentNotClickableWindow.Hide()

}

/**
 * Сдвигает окно, при одновременном нажатии левого и правого клика.
 * Логика работы:
 * Получить координаты мыши от экрана, и координаты окна, запомнить.
 * Крутить цикл, с паузой.
 * За это время курсор сдвигается. 
 * Получить активные координаты мыши от экрана,
 * и сравнить с преждними.
 * Сдвинуть окно на столько же.
 * @param ThisHotkey ~LButton & RButton, RButton & LButton
;  */
; move_window_with_left_right_mouse_button(ThisHotkey) {

;   ; MsgBox "RB" 
;   ; Unknown
;   if(ThisHotkey == "~LButton & RButton" && A_Cursor == "Unknown"){
;     ; Debug().logF(A_Cursor . ", " . ThisHotkey)
;     Send "^+{LButton}"
;     return
;   }

;   local cursorWinId
;   MouseGetPos(, , &cursorWinId)
;   ; Получаем состояние окна - максимизировано (1), минимизировано (-1, в трее),
;   ; В обычном перемещаемом состоянии (0) 
;   local winState := WinGetMinMax("ahk_id " cursorWinId)

;   ; Only if the window isn't maximized 
;   if (winState != 0){
;     ; Окно нельзя перемещать. Оно развёрнуто на весь экран.
;     return
;   }


;   try{
;     Hotkey "<^RButton", "Off"
;   }catch as err{
;     try{
;       Hotkey "^RButton", "Off"
;     }
;   }

;   if (MouseIsOverWindows(["WorkerW", "XamlExplorerHostIslandWindow"])) {
;     move_window_restoreHotkeys()
;     return
;   }

;   ; Сбрасываем активный курсор к дефаулт курсору. Чтобы не было багов.
;   RestoreCursor()
;   ; Устанавливаем курсор.
;   ; SIZENESW - стрелки изменить размер - слева снизу в право вверх.
;   ; SIZENWSE - стрелки изменить размер - справа снизу в лево вверх.
;   ; SIZEALL - стрелки во все стороны.
;   SetSystemCursor("SIZEALL")
;   ; SetSystemCursor("IDC_Cross")

;   ; Id окна, которое перетаскивается.
;   local Wid
;   ; Pause для кручения цикла.
;   local delay := 10
;   ; Предыдущие координаты мыши, и окна.
;   local prevCoord := {
;     mouse: {
;       x: 0,
;       y: 0
;     },
;     window: {
;       x: 0,
;       y: 0,
;       height: 100,
;       width: 600
;     }
;   }
;   ; Активные координаты мыши, и окна
;   local activeCoord := {
;     mouse: {
;       x: 0,
;       y: 0
;     },
;     window: {
;       x: 0,
;       y: 0,
;       height: 100,
;       width: 600
;     }
;   }

;   ; Switch to Screen coordinates.
;   CoordMode("Mouse", "Screen")
;   ; Makes the below move faster/smoother.
;   SetWinDelay(-1)

;   ; Устанавливает значения в объекты prevCoord, и activeCoord,
;   ; (предыдущие координаты курсора, и окна, отсчитывая от экрана, и 
;   ; активные координаты курсора, и окна).
;   initSetupCoord(*) {
;     ; Устанавливаем предыдущие координаты курсора:
;     local prevCoord_mouse_x, prevCoord_mouse_y
;     ; Wid - id окна над которым курсор.
;     MouseGetPos(&prevCoord_mouse_x, &prevCoord_mouse_y, &Wid)
;     prevCoord.mouse.x := prevCoord_mouse_x
;     prevCoord.mouse.y := prevCoord_mouse_y

;     ; Устанавливаем предыдущие координаты окна:
;     local prevCoord_window_x, prevCoord_window_y,
;       prevCoord_window_height, prevCoord_window_width
;     WinGetPos(&prevCoord_window_x, &prevCoord_window_y,
;       &prevCoord_window_width, &prevCoord_window_height, "ahk_id " . Wid)
;     prevCoord.window.x := prevCoord_window_x
;     prevCoord.window.y := prevCoord_window_y
;     prevCoord.window.height := prevCoord_window_height
;     prevCoord.window.width := prevCoord_window_width

;     ; Устанавливаем активные координаты курсора, и окна:
;     activeCoord.mouse.x := prevCoord.mouse.x
;     activeCoord.mouse.y := prevCoord.mouse.y
;     activeCoord.window.x := prevCoord.window.x
;     activeCoord.window.y := prevCoord.window.y
;     activeCoord.window.height := prevCoord.window.height
;     activeCoord.window.width := prevCoord.window.width
;   }

;   ; Устанавливает значения в объекты prevCoord, и activeCoord.
;   initSetupCoord()

;   ; Pause перед следующим получением координат, чтобы сдвинулся курсор.
;   Sleep(delay)

;   ; Устанавливает активные координаты курсора отсчитывая от экрана,
;   ; в переменные:
;   ; activeCoord.mouse.x
;   ; activeCoord.mouse.y
;   setActiveMouseCoord() {
;     local activeCoord_mouse_x, activeCoord_mouse_y
;     ; MouseGetPos(&activeCoord_mouse_x, &activeCoord_mouse_y, &Wid)
;     MouseGetPos(&activeCoord_mouse_x, &activeCoord_mouse_y)
;     activeCoord.mouse.x := activeCoord_mouse_x
;     activeCoord.mouse.y := activeCoord_mouse_y
;   }

;   ; Левая кнопка мыши была отжата?
;   local LButtonWasReleased := false
;   ; Это первый перебор в цикле когда нажата Ctrl?
;   ; Чтобы определить куда сдвигать окно, горизонтально, или вертикально.
;   local ctrlDrag_IsFirstLoop := true
;   ; Перемещать окно вертикально?, или горизонтально?, когда нажата Ctrl.
;   local isVertical := true

;   ; SetTimer loopFunc, 1
;   ; Крути цикл, и или вызываем функцию изменения размеров окна,
;   ; Когда LButton отжата, и нажата RButton.
;   ; Или перемещаем окно над которым курсор, 
;   ; или если нажата Ctrl, то перемещаем прямо, 
;   ; Если удерживается Ctrl, и нажата LButton, то вызываем рекурсию, 
;   ; эту функцию.
;   ; 
;   loop {

;     ; Когда левая кнопка мыши нажата.
;     if (GetKeyState("LButton", "P")) {

;       if (LButtonWasReleased) {
;         ; Стартует эту функцию перемещения окна рекурсивно.
;         return move_window_with_left_right_mouse_button(ThisHotkey)
;       }

;       setActiveMouseCoord()
;       ; Насколько сместился курсор от предыдущего цикла.
;       local dMouseX := activeCoord.mouse.x - prevCoord.mouse.x
;       local dMouseY := activeCoord.mouse.y - prevCoord.mouse.y
;       if (dMouseX == 0 && dMouseY == 0) {
;         ; Курсор не сместился.
;         continue
;       }
;       ; Устанавливаем координаты окна, куда сдвинуть окно.
;       if (dMouseX != 0) {
;         activeCoord.window.x := activeCoord.window.x + dMouseX
;       }
;       if (dMouseY != 0) {
;         activeCoord.window.y := activeCoord.window.y + dMouseY
;       }

;       ; Определяем как перемещать окно, вертикально, или горизонтально?
;       ; Устанавливаем флаг isVertical.
;       if (ctrlDrag_IsFirstLoop) {
;         if (Abs(dMouseX) < Abs(dMouseY)) {
;           isVertical := true
;         } else {
;           isVertical := false
;         }
;         ctrlDrag_IsFirstLoop := false
;       }

;       ; Если LCtrl нажато
;       if (GetKeyState("LCtrl", "P")) {
;         if (isVertical) {
;           activeCoord.window.x := prevCoord.window.x
;         } else {
;           activeCoord.window.y := prevCoord.window.y
;         }
;       }

;       ; Прилипание к линиям.
;       if (GetKeyState("LShift", "P")) {

;         ; x линии примагничивания, вертикальные.
;         local xLines := Map(0, "", A_ScreenWidth, "")
;         ; y линии примагничивания, горизонтальные.
;         local yLines := Map(0, "", A_ScreenHeight, "")

;         local moveWinArgs := getWinMoveArgsWithSnap_ForMove(
;           activeCoord.window.x,
;           activeCoord.window.y, 
;           activeCoord.window.width, 
;           activeCoord.window.height, xLines, yLines)

;           activeCoord.window.x := moveWinArgs.winX
;           activeCoord.window.y := moveWinArgs.winY

;           ; Debug().logF(activeCoord.window.height)

;       }


;       ; Новые координаты окна
;       WinMove(activeCoord.window.x,
;         activeCoord.window.y,
;         ,
;         ,
;         "ahk_id " Wid
;       )

;       ; Устанавливаем предыдущие координаты равные активным
;       prevCoord.mouse.x := activeCoord.mouse.x
;       prevCoord.mouse.y := activeCoord.mouse.y
;       prevCoord.window.x := activeCoord.window.x
;       prevCoord.window.y := activeCoord.window.y

;     }else{
;       ; Выполняется всегда когда левая кнопка мыши отжата.
;       LButtonWasReleased := true

;       ; Нажата RButton.
;       if (GetKeyState("RButton", "P")) {
;         ; return resize_window_with_left_right_mouse_button(ThisHotkey)
;         resize_window_with_left_right_mouse_button(ThisHotkey)
;         move_window_restoreHotkeys()
;         return
;       }

;       ; Отжата LCtrl
;       if (!GetKeyState("LCtrl", "P")) {
;         move_window_restoreHotkeys()
;         return
;       }

;     }
;     Sleep(delay)
;   } ; loop

; }



/**
 * 
 * @param ThisHotkey 
 * @param {Integer} cursorWinId - id окна где расположен курсор.
 * @param {Integer} xLines 
 * @param {Integer} yLines 
 * @returns {Any} 
 */
move_window_with_left_right_mouse_button(ThisHotkey, cursorWinId := 0, xLines := 0, yLines := 0) {

  global linkClick_isEnable
  if(linkClick_isEnable){
    ; Открывает ссылку в новой вкладке, и переходит туда.
    ; A_Cursor == Unknown - это курсор на ссылке.
    if(ThisHotkey == "~LButton & RButton" && A_Cursor == "Unknown"){
      ; Debug().logF(A_Cursor . ", " . ThisHotkey)
      Send "^+{LButton}"
      return
    }
  }

  ; Защита от багов.
  ; Чтобы вернуть хоткеи к прежднему состоянию в случае ошибки.
  try{

    ; Отключаем хоткеи.
    ; Кроме правого клика, или будет появляться меню.
    ; Нужно отключить хоткеи с Ctrl и Shift, или будут баги.
    ; Окно не будет перемещаться при нажатых Ctrl или Shift.
    ; printAllAssignedHotkeys()
    ; disableAllHotkeys(Map("RButton", ""))
    disableAllHotkeys()

    ; Отключаем меню правого клика.
    Hotkey "*RButton", emptyFunc, "On"
    ; Отключаем меню левого клика.
    ; Не устанавливать, а то будут баги, в случае ошибки, клик будет отключен.
    ; Hotkey "*LButton", emptyFunc, "On"

    ; Switch to Screen coordinates.
    CoordMode("Mouse", "Screen")
    ; Makes the below move faster/smoother.
    SetWinDelay(-1)

    ; Координата курсора x в начале клика, относительно экрана.
    local mStartX
    ; Координата курсора y в начале клика, относительно экрана.
    local mStartY
    if(cursorWinId == 0){
      MouseGetPos(&mStartX, &mStartY, &cursorWinId)
    }else{
      MouseGetPos(&mStartX, &mStartY)
    }

    ; Проверки, можно ли перемещать окно:

    ; Получаем состояние окна - максимизировано (1), минимизировано (-1, в трее),
    ; В обычном перемещаемом состоянии (0).
    local winState := WinGetMinMax("ahk_id " cursorWinId)

    ; Only if the window isn't maximized 
    if (winState != 0){
      ; Окно нельзя перемещать. Оно развёрнуто на весь экран.
      move_window_restoreHotkeys(cursorWinId)
      return
    }

    ; Курсор над Дэсктопом, или окном AltTab.
    if (MouseIsOverWindows(["WorkerW", "XamlExplorerHostIslandWindow"])) {
      move_window_restoreHotkeys(cursorWinId)
      return
    }

    global topTransparentNotClickableWindow
    topTransparentNotClickableWindow.Show()
    
    ; WinActivate "ahk_id " . cursorWinId

    ; Сбрасываем активный курсор к дефаулт курсору. Чтобы не было багов.
    RestoreCursor()
    ; Устанавливаем курсор.
    ; SIZENESW - стрелки изменить размер - слева снизу в право вверх.
    ; SIZENWSE - стрелки изменить размер - справа снизу в лево вверх.
    ; SIZEALL - стрелки во все стороны.
    SetSystemCursor("SIZEALL")
    ; SetSystemCursor("IDC_Cross")

    ; Pause для кручения цикла.
    local delay := 1
    
    ; Левая кнопка мыши была отжата?
    ; Флаг, позволяющий определить в цикле что левая кнопка мыши была 
    ; отжата недавно.
    ; Если левый клик снова нажмётся, то будет известно, что недавно
    ; левый клик был отжат.
    local LButtonWasReleased := false
    ; Перемещать окно вертикально?, или горизонтально?, когда нажата Ctrl.
    local isVertical := "none"

    ; Координата x окна в начале клика перемещения.
    local wStartX
    ; Координата y окна в начале клика перемещения.
    local wStartY
    ; Ширина окна в начале клика перемещения.
    local wStartWidth
    ; Высота окна в начале клика перемещения.
    local wStartHeight

    
    ; Получаем:
    ; 1, 2 - координаты левого верхнего угла окна.
    ; 3, 4 - ширина и высота окна.
    WinGetPos(&wStartX, &wStartY, &wStartWidth, &wStartHeight, "ahk_id " cursorWinId)

    ; Координата x курсора относительно окна
    local mStartX_OfWin := mStartX - wStartX
    ; Координата y курсора относительно окна
    local mStartY_OfWin := mStartY - wStartY

    if(xLines == 0){
      ; x линии примагничивания, вертикальные.
      ; A_ScreenWidth/2 - wStartWidth/2 - середина экрана.
      xLines := Map(0, "", A_ScreenWidth, "", A_ScreenWidth/2 - wStartWidth/2, "")
      ; y линии примагничивания, горизонтальные.
      yLines := Map(0, "", A_ScreenHeight, "")

      ; local start := A_TickCount
      local windowsOnDesktop := filteredAltTabWindows()["opened"]
      ; Debug().logF(A_TickCount - start)
      for k, windowOnDesktop in windowsOnDesktop{
        if(windowOnDesktop == cursorWinId){
          continue
        }
        ; Debug().logF(windowOnDesktop)
        WinGetPos(&windowOnDesktopX, &windowOnDesktopY, &windowOnDesktopWidth, 
          &windowOnDesktopHeight, "ahk_id " windowOnDesktop)
          
        xLines.Set(windowOnDesktopX, "")
        yLines.Set(windowOnDesktopY, "")
        xLines.Set(windowOnDesktopX + windowOnDesktopWidth, "")
        yLines.Set(windowOnDesktopY + windowOnDesktopHeight, "")

      }
    }

    ; Предыдущие координаты курсора, относительно экрана.
    static prevWinCoord := {
      x: mStartX - mStartX_OfWin,
      y: mStartY - mStartY_OfWin,
      isFirstCtrlPress: true,
      isDirectionEvaluated: false
    }

    Sleep(delay)

    ; Это первый цикл?
    ; True - если это первый проход цикла.
    local isFirstLoop := true

    ; SetTimer loopFunc, 1
    ; Крути цикл, и или вызываем функцию изменения размеров окна,
    ; Когда LButton отжата, и нажата RButton.
    ; Или перемещаем окно над которым курсор, 
    ; или если нажата Ctrl, то перемещаем прямо, 
    ; Если удерживается Ctrl, и нажата LButton, то вызываем рекурсию, 
    ; эту функцию.
    ; 
    loop {

      ; Когда левая кнопка мыши нажата.
      if (GetKeyState("LButton", "P")) {

        ; Левый клик недавно был отжат.
        if (LButtonWasReleased) {
          ; Стартует эту функцию перемещения окна рекурсивно.
          ; WinSetEnabled true, "ahk_id " . cursorWinId
          return move_window_with_left_right_mouse_button(ThisHotkey, cursorWinId, xLines, yLines)
        }

        ; Sleep 10

        ; Активная координата курсора x, относительно экрана.
        local newMX
        ; Активная координата курсора y, относительно экрана.
        local newMY

        ; Новые координаты курсора.
        MouseGetPos(&newMX, &newMY)

        ; Новые координаты которые должны быть у окна.
        local winNewX := newMX - mStartX_OfWin
        ; Новые координаты которые должны быть у окна.
        local winNewY := newMY - mStartY_OfWin

        ; Прилипание к линиям.
        if (GetKeyState("LShift", "P")) {
          local moveWinArgs := getWinMoveArgsWithSnap_ForMove(
            winNewX,
            winNewY, 
            wStartWidth, 
            wStartHeight, xLines, yLines)

          winNewX := moveWinArgs.winX
          winNewY := moveWinArgs.winY
        }

        ; Если LCtrl нажато.
        if (GetKeyState("LCtrl", "P")) {
          ; Когда нажимается Ctrl, это должно запомнить координаты окна,
          ; В следующем цикле это должно сравнить активные координаты где
          ; должно быть окно, с предыдущими.
          ; И сдвинуть окно вертикально, или горизонтально.
          ; Но кода отжимается левый клик, то нужно просто сразу определить
          ; направление.
          ; Сравнить с предыдущими координатами.

          ; Это первый цикл. Ctrl удерживалось до старта функции.
          if(isFirstLoop && prevWinCoord.isFirstCtrlPress == false){
            ; Это второй цикл когда нажато Ctrl.
            if(prevWinCoord.isDirectionEvaluated == false){
              ; Это второй цикл.
              ; Куда сместился курсор от предыдущего, когда было нажато Ctrl.
              local dMouseX := winNewX - prevWinCoord.x
              local dMouseY := winNewY - prevWinCoord.y
              if (Abs(dMouseX) < Abs(dMouseY)) {
                isVertical := true
              } else {
                isVertical := false
              }
              prevWinCoord.isDirectionEvaluated := true
            }
          }

          if(prevWinCoord.isFirstCtrlPress){
            ; Это первый цикл когда нажато Ctrl.
            prevWinCoord.isFirstCtrlPress := false
            ; Устанавливаем первые координаты.
            prevWinCoord.x := winNewX
            prevWinCoord.y := winNewY
          }else{
            ; Это второй цикл когда нажато Ctrl.
            if(prevWinCoord.isDirectionEvaluated == false){
              ; Это второй цикл.
              ; Куда сместился курсор от предыдущего, когда было нажато Ctrl.
              local dMouseX := winNewX - prevWinCoord.x
              local dMouseY := winNewY - prevWinCoord.y
              if (Abs(dMouseX) < Abs(dMouseY)) {
                isVertical := true
              } else {
                isVertical := false
              }
              prevWinCoord.isDirectionEvaluated := true
            }
          }

          if(prevWinCoord.isDirectionEvaluated){
            ; Debug().logF("isVertical = " . isVertical)
            if (isVertical) {
              winNewX := prevWinCoord.x
            } else {
              winNewY := prevWinCoord.y
            }
          }

          prevWinCoord.x := winNewX
          prevWinCoord.y := winNewY

        }else{
          ; Ctrl отжато.

          if(prevWinCoord.isFirstCtrlPress == false){
            ; 1, 2 - координаты левого верхнего угла окна.
            ; 3, 4 - ширина и высота окна.
            WinGetPos(&wStartX, &wStartY, &wStartWidth, &wStartHeight, "ahk_id " cursorWinId)
            MouseGetPos(&mStartX, &mStartY)
            ; Координата x курсора относительно окна
            mStartX_OfWin := mStartX - wStartX
            ; Координата y курсора относительно окна
            mStartY_OfWin := mStartY - wStartY

            ; Новые координаты которые должны быть у окна.
            winNewX := newMX - mStartX_OfWin
            ; Новые координаты которые должны быть у окна.
            winNewY := newMY - mStartY_OfWin
          }

          prevWinCoord.isFirstCtrlPress := true
          prevWinCoord.isDirectionEvaluated := false
          isVertical := "none"

        }

        ; Новые координаты окна
        WinMove(winNewX,
          winNewY,
          ,
          ,
          "ahk_id " . cursorWinId
        )

      }else{
        ; Выполняется когда левая кнопка мыши отжата.
        ; Это крутит цикл даже если левая кнопка мыши отжата,
        ; пока не отожмутся все клавиши.

        LButtonWasReleased := true

        prevWinCoord.isDirectionEvaluated := false
        isVertical := "none"

        ; Нажата RButton.
        if (GetKeyState("RButton", "P")) {
          ; return resize_window_with_left_right_mouse_button(ThisHotkey)
          resize_window_with_left_right_mouse_button(ThisHotkey, cursorWinId, xLines, yLines)
          continue
          ; move_window_restoreHotkeys(cursorWinId)
          ; return
        }

        ; Отжата LCtrl, и LShift.
        ; Выходим из этой функции перемещения окна.
        if (!GetKeyState("LCtrl", "P") && !GetKeyState("LShift", "P")) {
          move_window_restoreHotkeys(cursorWinId)
          return
        }

      }

      isFirstLoop := false
      ; Sleep(delay)
    } ; loop

  }catch as e{
    move_window_restoreHotkeys()
  }

}
