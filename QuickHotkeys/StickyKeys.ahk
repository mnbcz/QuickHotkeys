
#Include ./../Lib/Debug.ahk
#Include ../Lib/Utils.ahk

/**
 * Версия залипания клавиш с реальным залипанием модификаторов.
 */
class StickyKeys {

  ; Время когда был нажат последний модификатор
  timeModPressed := 0
  ; Карта нажатых сейчас модификаторов.
  pressedMods := Map()
  ; Функция this.modsTimeout() для таймера. 
  modsTimeoutFunc := 0
  ; Массив предыдущих нажатых клавиш.
  priorKeys := []

; A0  02A	h	d	1.02	LShift
  allMods := Map("sc2A", "", "sc136", "", "sc1D", "", "sc11D", "", 
  "sc15B", "", "sc15C", "", "sc38", "", "sc138", "")

  __New() {
    this.modsTimeoutFunc := ObjBindMethod(this, "modsTimeout")
  }

  /**
   * Возвращает все sc клавиши.
   * @param {Integer} isGetTestString - 1 - Если нужно вернуть тестовую строку.
   * @param {Integer} exclude 
   * @returns {String | Object} - Объект с ключами:
   * ; Клавиши, модификаторы, все.
    local scKeysObj := {
      keys: [],
      mods: [],
      all: []
    }
  */
  getAllScKeys(exclude := 0){

    if(exclude == 0){
      ; Клавиши которые исключить. 
      exclude := Map()
      ; sc1C - Enter
      exclude["sc1C"] := ""
      ; scE - BackSpace 
      exclude["scE"] := ""  
      ; sc36 - Лишний RShift
      exclude["sc36"] := ""
    }

    ; Модификаторы.
    local mods := Map()
    ; sc2A - LShift
    mods["sc2A"] := ""
    ; sc136 - RShift
    mods["sc136"] := ""
    ; sc1D - LControl
    mods["sc1D"] := ""
    ; sc11D - RControl
    mods["sc11D"] := ""
    ; sc15B - LWin
    mods["sc15B"] := ""
    ; sc15C - RWin
    mods["sc15C"] := ""
    ; sc38 - LAlt
    mods["sc38"] := ""
    ; sc138 - RAlt
    mods["sc138"] := ""

    ; Тестовая строка всех клавиш. 
    local scKeys := ""

    ; Клавиши, модификаторы, все.
    local scKeysObj := {
      keys: [],
      mods: [],
      all: []
    }


    ; 0x100 - 256
    ; 0x200 - 512
    Loop 0x200{
      ; sc клавиша. Например sc10.
      ; "sc{:X}" - Форматировать без лидирующих нулей.
      local sc := Format( "sc{:X}", A_Index - 1 )
      ; "sc{:03X}" - Форматировать c лидирующими нулями.
      ; sc := Format( "sc{:03X}", A_Index-1 )

      ; Название клавиши. Например Enter.
      local keyName := GetKeyName(sc)
      if(keyName == ""){
        continue
      }
      if(exclude.Has(sc)){
        continue
      }

      if(mods.Has(sc)){
        scKeysObj.mods.Push(sc)
      }else{
        scKeysObj.keys.Push(sc)
      }
      scKeysObj.all.Push(sc)

    }

    return scKeysObj

  }


  /**
   * Возвращает строку Down всех нажатых сейчас модификаторов:
   * {sc10 Down}{sc11 Down}.
   * @returns {String} 
   */
  getPressedMods_DownStr(mods := 0){
    if(this.pressedMods.Count == 0){
      return ""
    }
    local retStr := ""
    if(mods == 0){
      mods := this.pressedMods
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
    if(this.pressedMods.Count == 0){
      return ""
    }
    local retStr := ""
    if(mods == 0){
      mods := this.pressedMods
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
    if(this.priorKeys.Length > 3){
      this.priorKeys.RemoveAt(1)
    }
  }

  getPriorKey(){
    if(this.priorKeys.Length != 0){
      return this.priorKeys[this.priorKeys.Length]
    }
    return 0
  }


  setAllModHotkeys(){

    local onOff := "On"
    local allScKeys := this.getAllScKeys()

    for _, sc in allScKeys.mods {
      ; * - Чтобы при удержании других модификаторов, тоже срабатывало.
      Hotkey "*"  . sc, (sc) => this.modPress(sc), onOff
    }

    for _, sc in allScKeys.keys {
      local options := onOff
      if(onOff == "On"){
        ; Срабатывает на отправления не меньше чем 11.
        options := "On I10"
      }
      ; Hotkey "*" . sc, (sc) => this.oneKeyPress(sc), onOff
      Hotkey "*" . sc, (sc) => this.oneKeyPress(sc), onOff
    } 

  }

  modPress(thisHotkey){
    
    thisHotkey := StrReplace(thisHotkey, "*")
    SendEvent "{" . thisHotkey . " Down}"

    Debug.logT("modPress(), ThisHotkey = " . thisHotkey)
    this.pressedMods.Set(thisHotkey, "")
    this.timeModPressed := A_TickCount
    this.addKeyToPriorKeys(thisHotkey)

    SetTimer this.modsTimeoutFunc, 30

  }


  oneKeyPress(thisHotkey){
    Debug.logT("oneKeyPress(), ThisHotkey = " . thisHotkey)
    thisHotkey := StrReplace(thisHotkey, "~")
    thisHotkey := StrReplace(thisHotkey, "*")
    local priorKey := this.getPriorKey()
    this.addKeyToPriorKeys(thisHotkey)

      ; Предыдущая клавиша -  модификатор.
      if(this.allMods.Has(priorKey)){
        this.timeModPressed := A_TickCount
      }else{
        if(priorKey == thisHotkey){
          this.timeModPressed := A_TickCount
        }else{
          this.releaseAllMods()
        }
      }
      SendEvent "{" . thisHotkey . "}"
      return
      
    ; Если модификаторы сейчас нажаты, то:
      ; Если предыдущая клавиша была такая же как сейчас, то продлить таймаут
      ; залипания.
    if(this.pressedMods.Count > 0 ){

      ; Предыдущая клавиша была модификатор.
      if(this.allMods.Has(priorKey)){
        this.timeModPressed := A_TickCount
        return
      }

      ; Предыдущая клавиша - такая же как сейчас.
      if(priorKey == thisHotkey){
        Debug.log("priorKey == thisHotkey")
        ; SetTimer this.modsTimeoutFunc, 100
        this.timeModPressed := A_TickCount
        return
      }else{
        ; Предыдущая клавиша, не такая же как сейчас (и не модификатор).
        this.releaseAllMods()
        return
      }
    }
  }



  modsTimeout(){
    if(A_TickCount - this.timeModPressed > 1000){ 
      this.releaseAllMods()
    }
  }

  releaseAllMods(){
    if(this.pressedMods.Count > 0){
      Send this.getPressedMods_UpStr()
    }
    this.pressedMods := Map()
    this.timeModPressed := 0
    SetTimer this.modsTimeoutFunc, 0
  }


}


stickyKeys_ := StickyKeys()
stickyKeys_.setAllModHotkeys()


::md2::--


