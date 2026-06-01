; #Include ../functions.ahk

global stickyKeys_ := stickyKeys()
global allVkKeys := getAllVkKeys()

stickyKeys_setHotkeys(hotkeysJsonItem){
  global stickyKeys_
  if (hotkeysJsonItem.isEnable) {
    stickyKeys_.onOffHotkeys("On")
  } else {
    stickyKeys_.onOffHotkeys("Off")
  }
}



/**
 * TODO: Это не работает на назначенных через этот скрипт хоткеях.
 */
class stickyKeys{

  ; Карта нажатых сейчас клавиш модификаторов. "sc2A", "sc136", ... - ключи.
  modsPressed := Map()

  ; Все существующие модификаторы.
  mods := Map("vk5B", "", "vk5C", "", "vkA0", "", "vkA1", "", 
  "vkA2", "", "vkA3", "", "vkA4", "", "vkA5", "")

  ; sc коды клавиш чисел: 1, 2, ... 0.
  numKeys := Map("vk30", "", "vk31", "", "vk32", "", "vk33", "", "vk34", "", 
  "vk35", "", "vk36", "", "vk37", "", "vk38", "", "vk39", "")

  ; Таймаут для залипания клавиш.
  stickyTimeout := 1000
  ; Это режим Модификаторы и клавиша? (была нажата клавиша после модификатора).
  ; Сбросится к false при таймауте.
  ; Это не нужно здесь устанавливать.
  modKeysKeyIsPressed := false  
  ; Это режим Win+Num? (Win+1,...).
  winNumMode := false
  ; Изменяется если кликнуть на списке окна внизу, над TaskBar, при режиме Win+Num,
  ; чтобы отжать Win+Num, и список закрылся.
  ; Функция залипания клавиш.
  WinNumIsPressed := true


  /**
   * Возвращает строку Down всех нажатых сейчас модификаторов:
   * {sc10 Down}{sc11 Down}.
   * @returns {String} 
   */
  getPressedMods_DownStr(){
    if(this.modsPressed.Count == 0){
      return ""
    }
    local retStr := ""
    for k, v in this.modsPressed{
      retStr := retStr . "{" . k . " Down}"
    }
    return retStr
  }

    /**
   * Возвращает строку Up всех нажатых сейчас модификаторов:
   * {sc10 Up}{sc11 Up}.
   * @returns {String} 
   */
  getPressedMods_UpStr(){
    if(this.modsPressed.Count == 0){
      return ""
    }
    local retStr := ""
    for k, v in this.modsPressed{
      retStr := retStr . "{" . k . " Up}"
    }
    return retStr
  }


  /**
  * Это вызывается когда модификатор удерживается.
  * Добавляет в массив this.modsPressed нажатые модификаторы.
  * @param ThisKey - sc10 - sc код нажатой клавиши модификатора.
   */
  modPress(ThisKey){

    
    ThisKey := StrReplace(ThisKey, "~")
    ThisKey := StrReplace(ThisKey, "*")
    
    ; Предыдущая нажатая клавиша. Например CapsLock.
    local priorKey := A_PriorKey
    ; sc код предыдущей нажатой клавиши.
    local priorKeyVk := Format("vk{:X}", GetKeyVK(priorKey))
    
    ; Debug().logF("modPress(), ThisKey = " . ThisKey . ", priorKeyVk = " . priorKeyVk)

    ; Эта нажатая клавиша это клавиша LWin или LAlt.
    if(ThisKey == "vk5B" || ThisKey == "vkA4"){
      ; Чтобы не открывалось меню.
      BlockInput "On"
      Send("{Blind}{vk07}")
      BlockInput "Off"
    }

    ; Чтобы много раз не вызывался этот метод modPress() при удержании LWin.
    ; Эта клавиша модификатор такая же как предыдущая, и прошло меньше
    ; 100 миллисекунд. Значит модификатор удерживается.
    if(ThisKey == priorKeyVk && A_TimeSincePriorHotkey < 100){
      ; Send("{Blind}{vkE8}")
      ; Так, будет мигать курсор при удержании Ctrl.
      ; Send("{Blind}{vk07}")
      return
    }

    ; Если предыдущая нажатая клавиша - какая-нибудь из клавиш модификаторов,
    ; и не прошёл таймаут.
    if(this.mods.Has(priorKeyVk) && (A_TimeSincePriorHotkey < this.stickyTimeout)){
      ; Добавить активную нажатую клавишу в список нажатых модификаторов.
      this.modsPressed.Set(ThisKey, "")
    }else{
        ; Если предыдущая нажатая клавиша это не клавиша модификатор, 
        ; или прошёл таймаут:
        ; Очистить массив нажатых модификаторов, и добавить активную клавишу.
        this.modsPressed := Map()
        this.modsPressed.Set(ThisKey, "")
    }

    ; Debug().logF("this.modsPressed:")
    ; Debug().logF(this.modsPressed)

  }



  ; Имитирует нажатие на Win+Num. Поступает клавиша Num.
  ; Num уже должно быть нажато.
  winNumPress(key) {
    ; Следим за нажатием на клавишу Num (1), и нажимаем программно.
    ; 2.
    local keyName := GetKeyName(key)

    TimeoutWinNumPress() {
      ; Send("{Blind}{LWin Up}")
      Send("{" key " Up}")
      Send("{LWin Up}")
      ; logF("Win Up")
      this.winNumMode := false
      ; MsgBox, Win Up
    }

    local isSendTimeout := false
    ; logF("winNumPress(), key = " . key)
    SendLevel(0)

    ; Send("{Blind}{LWin Down}")
    Send("{LWin Down}")

    ; Первое нажатие на число.
    ; Удерживаем чтобы окно открылось. Избавляемся от бага.
    ; Loop 6 - регулируется насколько долго нужно первый раз удерживать клавишу.
    ; 6 * 30 = 180
    Loop 7 {
      ; Send("{Blind}{" key " Down}")
      Send("{" key " Down}")
      Sleep 30
    }
    ; Send("{Blind}{" key " Up}")
    Send("{" key " Up}")

    ; Чтобы список успел открыться, и не зависал.
    Sleep(60)

    While this.winNumMode {

      if GetKeyState(keyName, "P") {
        ; Если клавиша Num удерживается.
        ; Нужно постоянно нажимать клавишу если клавиша удерживается.
        ; Send("{Blind}{" key " Down}")
        Send("{" key " Down}")

        ; logF("GetKeyState(), Send key Down = " . key)

        if (!WinExist("ahk_class TaskListThumbnailWnd")) {
          ; logF("!WinExist")
          TimeoutWinNumPress()
          Break
        }

        SetTimer(TimeoutWinNumPress, 0)
        ; logF("Key Down")
        isSendTimeout := False
      } else {
        ; Если клавиша Num отжата.
        ; Устанавливаем счётчик отжатия Win.
        ; Чтобы не вызывалось постоянно когда клавиша отжата.
        ; Когда клавиша отжата, вызывается только один раз.
        if (!isSendTimeout) {
          ; Send("{Blind}{" key " Up}")
          Send("{" key " Up}")
          ; logF("Key Up")
          SetTimer(TimeoutWinNumPress, -200)
          isSendTimeout := True
        }
      }
      Sleep(10)
    }

    Send("{LWin Up}")
    Send("{LControl Up}")
    Send("{LAlt Up}")
    Send("{LShift Up}")
    ; logF("GetKeyState(), End")
    return
  }


  /**
   * Вызывается когда нажимается клавиша, не модификатор.
   * Это вызывается даже если удерживается левый клик. 
  */
  oneKeyPress(ThisKey){
      
    ; MsgBox ThisKey 
    ; Debug().logF("ThisKey = " . ThisKey)

    static counter := 1

    ; https://www.autohotkey.com/docs/v1/misc/Remap.htm#actually
    ; SetKeyDelay, 0

    ; https://www.autohotkey.com/docs/v1/lib/Send.htm#SendInput
    ; A_PriorKey - Это меняет значение когда нажимаются клавиши, 
    ; поэтому нужно сохранить в переменной.
    ; A_PriorKey - Предыдущая любая клавиша.
    ; Если предыдущая клавиша была например Shift+z, то значение последней нажатой
    ; клавиши будет - z.
    ; A_PriorKey - будет z, а не $z
    
    ThisKey := StrReplace(ThisKey, "$")

    ; Предыдущая нажатая клавиша.
    local priorKey := A_PriorKey
    ; sc код предыдущей нажатой клавиши.
    ; local priorKeySc := Format("sc{:X}", GetKeySc(priorKey))
    local priorKeyVk := Format("vk{:X}", GetKeyVK(priorKey))

;     A4  038	 	u	0.19	LAlt            	
;     09  00F	s	d	0.14	Tab

    ; Debug().logF("ThisKey = " . ThisKey . ", priorKeyVk = " . priorKeyVk )

    ; Если предыдущая клавиша это клавиша модификатор.
    if(this.mods.Has(priorKeyVk)){

      ; Debug().logF("prev is mod")

      ; Таймаут не прошёл.
      if(A_TimeSincePriorHotkey < this.stickyTimeout){
          
        ; Клавиша модификатор, и клавиша, нажаты.
        this.modKeysKeyIsPressed := true

        ; Если модификатор, предыдущая клавиша, это Win, и эта клавиша это 1-9.
        if(this.modsPressed.Count == 1 && this.modsPressed.Has("vk5B")
        && this.numKeys.Has(ThisKey)){
          ; Включаем режим WinMode.
          ; Где требуется особые нажатия, а не просто нажать модификатор и клавишу.
          this.winNumMode := true
          ; log("Set this.winNumMode = True")
          this.winNumPress(ThisKey)
          ; return
        }else{
          ; Это не режим this.winNumMode.

          local sendKeys := this.getPressedMods_DownStr() . "{" . ThisKey . "}"  . this.getPressedMods_UpStr()
          ; local sendKeys := this.getPressedMods_DownStr() . "{" . ThisKey . " Down}" . "{" . ThisKey . " Up}" . this.getPressedMods_UpStr()
          ; Debug().logF("Send mod+key = " . sendKeys)
          
          SendLevel 1
          Send(sendKeys)                                                
          ; return

        }  
      }else{
        ; Таймаут прошёл.
        ; Тогда просто нажимаем на клавишу.
        this.modKeysKeyIsPressed := false
        this.winNumMode := false
        this.modsPressed := Map()
        SendLevel 0
        Send("{Blind}{" ThisKey "}")
        ; Debug().logF("Timeout from mod pressed expired")
        ; return
      }

      ; return
    }else{
      ; Предыдущая клавиша не модификатор.

      if((priorKeyVk == ThisKey) && this.modKeysKeyIsPressed && (A_TimeSincePriorHotkey < this.stickyTimeout)){
        ; Если предыдущая клавиша была например z, такая же как сейчас, 
        ; и включено Mod+key, и таймаут не прошёл,
        ; Нажать нажатые модификаторы с клавишей.
        ; Строим клавиши модификаторы для отправки.
        local sendKeys := this.getPressedMods_DownStr() . "{" . ThisKey . "}"  . this.getPressedMods_UpStr()
        SendLevel 1
        Send(sendKeys)
        ; Debug().logF("Same key, Send mod+key = = " . sendKeys)
        ; return
      }else{
        ; Предыдущая клавиша не та же самая, или Mod+Key отключено, 
        ; или прошёл таймаут.
        ; Это просто нажатие клавиши. 
        ; Отсылаем нажатие клавиши.
        this.winNumMode := false
        this.modKeysKeyIsPressed := false
        this.modsPressed := Map()
        ; Send %CapsLockValue%{%A_ThisHotkey_Replace%}
        SendLevel 0
        ; {Blind} - Чтобы учитывать нажатия клавиши Caps.
        Send("{Blind}{" ThisKey "}")
        ; Debug().logF("Only key = " . ThisKey)
      }
    }

    ; Debug().logF("this.modsPressed:")
    ; Debug().logF(this.modsPressed)

  }


  /**
   * Включает, или отключает Sticky хоткеи.
  ; https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes 
   * @param {String} onOff 
   */
  onOffHotkeys(onOff := "On"){

    global allVkKeys

    for _, sc in allVkKeys.mods {
      ; * - Чтобы при удержании других модификаторов, тоже срабатывало.
      Hotkey "~*" . sc, (sc) => this.modPress(sc), onOff
    }

    local callBack := ObjBindMethod(this, "oneKeyPress")

    for _, sc in allVkKeys.keys {
      ; Без $ будет бесконечная рекурсия.
      ; Hotkey "$" . sc, (*) => this.oneKeyPress(), onOff
      local options := onOff
      if(onOff == "On"){
        options := "On I0"
      }
      ; Hotkey(sc, (sc) => this.oneKeyPress(sc), options)
      Hotkey(sc, callBack, options)
    } 

  }

}




