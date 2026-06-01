#Include ./minMaxWindow.ahk

; Устанавливает прозрачность у окна. 
; Сначала нажать Ctrl+Alt+RClick, не отжимая модификаторы, крутить колесо.
; ThisHotkey - ^!RButton
; Key - RButton
setTransparency(Key, ThisHotkey){ 
  
  ; Debug().logF("setTransparency(), Key = " . Key . ", ThisHotkey = " . ThisHotkey)

  ; Дефаулт прозрачность.
  local initTransparency := 230
  ; Значение прозрачности которое меняется, и сохраняется между вызовами.
  static transparency := initTransparency
  ; Насколько изменить значение прозрачности при кручении колеса
  local step := 2
  ; Крутилось ли колесо?
  local wheelIsClicked := 0

  ; logF("setTransparency()")

  local currentTransparency := WinGetTransparent("A")
  ; MsgBox("currentTransparency = " . currentTransparency)
  ; 255 - это полная непрозрачность.
  if (currentTransparency = 255 || currentTransparency = ""){
      ; Окно непрозрачно.
      ; Устанавливаем прозрачность окна.
      transparency := initTransparency
      WinSetTransparent(initTransparency, "A")
  }

  disableAllHotkeys()
  Hotkey("*RButton", emptyFunc, "On")


  ; Отключаем этот хоткей, и подключаем кручение колеса.
  ; Hotkey(ThisHotkey, setTransparency, "Off")
  ; Hotkey(ThisHotkey, "Off")
  Hotkey("*WheelDown", (*) => Wheel_.down(), "On")
  Hotkey("*WheelUp", (*) => Wheel_.up(), "On")

  ; Если будут кручения колеса, то они будут в этом массиве.
  global WheelUpStack := []
  global WheelDownStack := []

  ; Получаем модификаторы из строки, в массив
  local mods := getModifiers(ThisHotkey, false)

  ; Debug().logF(mods, "mods")

  ; Ждём отжатия любого модификатора
  while true{
    ; Проверяем отжат ли какой-нибудь модификатор.
    ; Если отжат, выходим из цикла.
    local isModsReleased := false
    for i, hotkeyMod in mods{
      if(GetKeyState(hotkeyMod, "P")){
          isModsReleased := false
      }else{
          isModsReleased := true
          break
      }
    }

    if(isModsReleased){
        break
    }

    if(Wheel_.upStack.Length > 0){
        transparency += step
        if(transparency > 255){
            transparency := 255
        }
        Wheel_.upStack := []
        WinSetTransparent(transparency, "A")
        wheelIsClicked := 1
    }

    if(Wheel_.downStack.Length > 0){
        transparency -= step
        Wheel_.downStack := []
        if(transparency < 0){
            transparency := 0
        }
        WinSetTransparent(transparency, "A")
        wheelIsClicked := 1
    }

    ; Ждём пока колесо с первой прокрутки остановится. 120
    Wheel_.waitWheelStop(120)
    Sleep(20)
  }

  ; Колесо не крутилось
  if(!wheelIsClicked){
    if (currentTransparency != 255 && currentTransparency != ""){
      ; Окно прозрачно.
      ; 255 - это полная непрозрачность.
      WinSetTransparent(255, "A")
    }
  }

  Hotkey("*WheelDown", (*) => Wheel_.down(), "Off")
  Hotkey("*WheelUp", (*) => Wheel_.up(), "Off")
  ; Hotkey(ThisHotkey, setTransparency, "On")
  ; Hotkey(ThisHotkey, "On")
  Hotkey("*RButton", emptyFunc, "Off")
  enableAllHotkeys()

  global stickyKeys_
  releaseModifiers_Timeout()
  ; A2  01D	 	d	1.77	LControl       	    	
  ; A0  02A	 	d	0.20	LShift         	     	
  ; A4  038	 	d	0.33	LAlt  
  try{
    stickyKeys_.modsPressed.Delete("sc15B")
    stickyKeys_.modsPressed.Delete("sc1D")
  }
  ; local t := true && false
  ; MsgBox(t)

} 

