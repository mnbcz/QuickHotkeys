; #Include ../functions.ahk

global stickyKeys_ := stickyKeys()
global allScKeys := getAllScKeys()

stickyKeys_setHotkeys(hotkeysJsonItem){
  global stickyKeys_
  if (hotkeysJsonItem.isEnable) {
    stickyKeys_.onOffHotkeys("On")
    try{
      stickyKeys_.stickyTimeout := Integer(hotkeysJsonItem.hotkeyDisplay)
    }catch as err{
      stickyKeys_.stickyTimeout := 1000
    }
  } else {
    stickyKeys_.onOffHotkeys("Off")
  }
}


/**
 * Залипание клавиш.
 */
class stickyKeys{

  ; Карта нажатых сейчас клавиш модификаторов. "sc2A", "sc136", ... - ключи.
  modsPressed := Map()

  ; Все существующие модификаторы.
  ; A2  01D	 	d	1.77	LControl       	    	
  ; A0  02A	 	d	0.20	LShift         	     	
  ; A4  038	 	d	0.33	LAlt           	
  ; 07  000	i	d	0.00	not found      	    	
  ; A4  038	 	u	0.12	LAlt       
  mods := Map("sc2A", "", "sc136", "", "sc1D", "", "sc11D", "", 
  "sc15B", "", "sc15C", "", "sc38", "", "sc138", "")

  ; sc коды клавиш чисел: 1, 2, ... 0.
  numKeys := Map("sc2", "", "sc3", "", "sc4", "", "sc5", "", "sc6", "", 
  "sc7", "", "sc8", "", "sc9", "", "scA", "", "scB", "")


  ; Таймаут для залипания клавиш.
  stickyTimeout := 1000
  ; Это режим Модификаторы и клавиша? (была нажата клавиша после модификатора).
  ; Сбросится к false при таймауте.
  ; Это не нужно здесь устанавливать.
  isStickyActivated := false  
  ; Это режим Win+Num? (Win+1,...).
  winNumMode := false
  ; Изменяется если кликнуть на списке окна внизу, над TaskBar, при режиме Win+Num,
  ; чтобы отжать Win+Num, и список закрылся.
  ; Функция залипания клавиш.
  WinNumIsPressed := true

  ; Предыдущие нажатые клавиши. 
  priorKeys := []

  __New() {
    
  }

  /**
   * Возвращает строку Down всех нажатых сейчас модификаторов:
   * {sc10 Down}{sc11 Down}.
   * @returns {String} 
   */
  getPressedMods_DownStr(mods := 0){
    if(this.modsPressed.Count == 0){
      return ""
    }
    local retStr := ""
    if(mods == 0){
      mods := this.modsPressed
    }
    for k, v in mods{
      retStr := retStr . "{" . k . " Down}"
    }
    return retStr
  }

    /**
   * Возвращает строку Up всех нажатых сейчас модификаторов:
   * {sc10 Up}{sc11 Up}.
   * @returns {String} 
   */
  getPressedMods_UpStr(mods := 0){
    if(this.modsPressed.Count == 0){
      return ""
    }
    local retStr := ""
    if(mods == 0){
      mods := this.modsPressed
    }
    for k, v in mods{
      retStr := retStr . "{" . k . " Up}"
    }
    return retStr
  }


  /**
   * Добавляет клавишу, в массив нажатых клавиш.
   * @param key 
   */
  addKeyToPriorKeys(key){
    this.priorKeys.Push(key)
    if(this.priorKeys.Length > 20){
      try{
        this.priorKeys.RemoveAt(1)
      }
    }
  }
  
  /**
  * Это вызывается когда модификатор удерживается.
  * Добавляет в массив this.modsPressed нажатые модификаторы.
  * @param ThisKey - sc10 - sc код нажатой клавиши модификатора.
   */
  modPress(ThisKey){

    ; Debug.log("modPress = " . ThisKey)

    ThisKey := StrReplace(ThisKey, "~")
    ThisKey := StrReplace(ThisKey, "*")

    this.addKeyToPriorKeys(ThisKey)

    ; Предыдущая нажатая клавиша. Например CapsLock.
    local priorKey := A_PriorKey
    ; sc код предыдущей нажатой клавиши.
    local priorKeySc := Format("sc{:X}", GetKeySC(priorKey))

    ; sc15B - LWin
    ; sc15C - RWin
    ; sc38 - LAlt
    ; sc138 - RAlt
    ; Эта нажатая клавиша это клавиша LWin или LAlt.
    if(ThisKey == "sc15B" || ThisKey == "sc38"){
      ; Чтобы не открывалось меню.
      BlockInput "On"
      Send("{Blind}{vk07}")
      BlockInput "Off"
    }

    ; Чтобы много раз не вызывался этот метод modPress() при удержании LWin.
    ; Эта клавиша модификатор такая же как предыдущая, и прошло меньше
    ; 100 миллисекунд. Значит модификатор удерживается.
    if(ThisKey == priorKeySc && A_TimeSincePriorHotkey < 100){
      ; Send("{Blind}{vkE8}")
      ; Так, будет мигать курсор при удержании Ctrl.
      ; Send("{Blind}{vk07}")
      return
    }

    ; Если предыдущая нажатая клавиша - какая-нибудь из клавиш модификаторов,
    ; и не прошёл таймаут.
    if(this.mods.Has(priorKeySc) && (A_TimeSincePriorHotkey < this.stickyTimeout)){
      ; Добавить активную нажатую клавишу в список нажатых модификаторов.
      this.modsPressed.Set(ThisKey, "")
    }else{
        ; Если предыдущая нажатая клавиша это не клавиша модификатор, 
        ; или прошёл таймаут:
        ; Очистить массив нажатых модификаторов, и добавить активную клавишу.
        this.modsPressed := Map()
        this.modsPressed.Set(ThisKey, "")
    }

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

    this.addKeyToPriorKeys(ThisKey)

    ; global hotStrings_
    ; Debug.logT(hotStrings_.typedSymbols)

    ; https://www.autohotkey.com/docs/v1/misc/Remap.htm#actually
    ; SetKeyDelay, 0

    ; https://www.autohotkey.com/docs/v1/lib/Send.htm#SendInput
    ; A_PriorKey - Это меняет значение когда нажимаются клавиши, 
    ; поэтому нужно сохранить в переменной.
    ; A_PriorKey - Предыдущая любая клавиша.
    ; Если предыдущая клавиша была например Shift+z, то значение последней нажатой
    ; клавиши будет - z.
    ; A_PriorKey - будет z, а не $z

    ; Предыдущая нажатая клавиша.
    local priorKey := A_PriorKey
    ; sc код предыдущей нажатой клавиши.
    local priorKeySc := Format("sc{:X}", GetKeySC(priorKey))

;     A4  038	 	u	0.19	LAlt            	
;     09  00F	s	d	0.14	Tab

    ; Исправление бага, кода из-за чего-то не правильно определяется предыдущая клавиша.
    ; Если уже где-то назначено & хоткей, то предыдущая клавиша будет равна активной. 
    if(ThisKey == priorKeySc){
      if(this.priorKeys.Length > 1){
        priorKeySc := this.priorKeys[this.priorKeys.Length - 1]
      }
    }

    ; Debug().logF("ThisKey = " . ThisKey . ", priorKeySc = " . priorKeySc)

    ; Если предыдущая клавиша это клавиша модификатор.
    if(this.mods.Has(priorKeySc)){ 
    
      ; Время которое прошло с момента нажатия предыдущей клавиши.
      ; Не прошёл таймаут.
      if(A_TimeSincePriorHotkey < this.stickyTimeout){
      
        ; Отмечаем что сейчас включено залипание.
        this.isStickyActivated := true

        ; Если модификатор, предыдущая клавиша, это Win, и эта клавиша это 1-9.
        if(this.modsPressed.Count == 1 && this.modsPressed.Has("sc15B")
        && this.numKeys.Has(ThisKey)){
          ; Включаем режим WinMode.
          ; Где требуется особые нажатия, а не просто нажать модификатор и клавишу.
          this.winNumMode := true
          ; log("Set this.winNumMode = True")
          this.winNumPress(ThisKey)

        }else{
          ; Это не режим this.winNumMode.
          ; Нажимаем хоткей, и отправляем зарегистрированным хоткеям.
          local sendKeys := this.getPressedMods_DownStr() . "{" . ThisKey . "}" . this.getPressedMods_UpStr()
          SendLevel 2
          SendEvent(sendKeys)
          ; Send(sendKeys)

        }
      }else{
        ; Таймаут прошёл.
        ; Тогда просто нажимаем на клавишу.
        sendOneKey(ThisKey)
      }
    }else{
      ; Предыдущая клавиша не модификатор.

      if(this.isStickyActivated){

        ; Если предыдущая клавиша была такая же как сейчас (например z).
        if(priorKeySc == ThisKey) {

          ; Таймаут не прошёл.
          if(A_TimeSincePriorHotkey < this.stickyTimeout){
            local sendKeys := this.getPressedMods_DownStr() . "{" . ThisKey . "}"  . this.getPressedMods_UpStr()
            SendLevel 2
            SendEvent(sendKeys)
          }else{
            sendOneKey(ThisKey)
          }

        }else{
          ; Предыдущая клавиша не та же самая (не z).
          sendOneKey(ThisKey)
        }

      }else{
          sendOneKey(ThisKey)
      }
    }
  ; 
    ; -----------------------------------------------------------------
    ; Functions:
    /**
     * Нажимает на клавишу.
     * @param key 
     */
    sendOneKey(key){
      global hotkeysActions
      this.isStickyActivated := false
      this.winNumMode := false
      this.modsPressed := Map()

      global oneKeyFunctions
      ; Для этой клавиши назначена функция?
      if(oneKeyFunctions.Has(key)){
        %key%()
      }else{
        ; Для этой клавиши не назначена функция:        
        ; Автозамена включена?
        if(hotkeysActions.hotStrings){
          ; 20  039	 	d	0.83	Space  
          ; Если нажат пробел:
          if(key == "sc39"){
            SendLevel 0
            global hotStrings_
            local matchValue := hotStrings_.match()
            ; Debug.log(matchValue)
            ; Debug.log(this.last60symbols)
            ; Было совпадение.
            if(matchValue){
              local textReplace := matchValue[2].value
              ; /.
              if(matchValue[1] == "sc35sc34"){
                textReplace := textReplace()
              }
              Send "{BackSpace " . matchValue[2].length . "}"
              SendText textReplace . " "
              hotStrings_.add(0)
              return
            }
          }
        }
         _sendOneKey(key)
      }
    }

    _sendOneKey(key){
      SendLevel 0
      ; {Blind} - Чтобы учитывать нажатия клавиши CapsLock.
      local send := "{Blind}{" . key . "}"
      SendEvent(send)

      global hotkeysActions
      global hotStrings_
      if(hotkeysActions.hotStrings){
        hotStrings_.add(key)
      }
    }

  }


  modKeyPress(ThisHotkey){
    ; Debug.log("modKeyPress(), ThisHotkey = " . ThisHotkey)
                  ; 
    local modsPressed := Map()
    if(GetKeyState("LCtrl", "P")){
      modsPressed.Set("LCtrl", "")
    }
    if(GetKeyState("LShift", "P")){
      modsPressed.Set("LShift", "")
    }
    if(modsPressed.Count > 0){
      ; SendLevel 0
      ; Send this.getPressedMods_DownStr() . "{" . ThisKey . "}" . this.getPressedMods_UpStr()
    ; 
      ; this.isStickyActivated := false
      ; this.winNumMode := false
      this.modsPressed := Map()
      return
    }
    

  }


  /**
   * Включает, или отключает Sticky хоткеи.
  ; https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes 
   * @param {String} onOff 
   */
  onOffHotkeys(onOff := "On"){

    global allScKeys

    for _, sc in allScKeys.mods {
      ; * - Чтобы при удержании других модификаторов, тоже срабатывало.
      Hotkey "~*"  . sc, (sc) => this.modPress(sc), onOff
    }

    for _, sc in allScKeys.keys {
      local options := onOff
      if(onOff == "On"){
        ; Срабатывает на отправления не меньше чем 11.
        options := "On I10"
      }
      ; Hotkey "*" . sc, (sc) => this.oneKeyPress(sc), onOff
      Hotkey sc, (sc) => this.oneKeyPress(sc), onOff
    } 

    ; for _, sc in allScKeys.keys {
    ;   local options := onOff
    ;   if(onOff == "On"){
    ;     options := "On"
    ;   }
    ;   Hotkey "~*" . sc, (sc) => this.modKeyPress(sc), onOff
    ; } 

  }

}





