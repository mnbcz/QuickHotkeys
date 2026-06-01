
; Хоткеи алиасы из /appDataDir/hotkeyAliases.json.
class HotkeyAliases {

  ; TEST
  ; jsonPath := A_ScriptDir . "/appDataDir/hotkeyAliases.json"
  jsonPath := config.appDataDir . "/hotkeyAliases.json"

  ; Массив объектов хоткеев, из .json
  state := {}
  ; Хоткеи которые были назначены для Hotkey().
  ; {"id хоткея": "!+^sc10", ... }
  ; Чтобы отключить активный хоткей
  assignedHotkeys := {}

  ; Состояние было изменено? Изменялись поля?
  isWasChanged := false

  __New() {

  }

  init() {
    this.loadFromJsonFile()
    this.setHotkeys()
  }

  ; Загружает состояние хоткеев из файла.
  loadFromJsonFile() {
    global config, ConfigReader
    ; this.state := ConfigReader.getObject(config.Hotkeys.jsonPath)
    this.state := ConfigReader.getObject(this.jsonPath)
  }

  ; Сохраняет хоткеи в файл
  saveToJsonFile() {
    global config, ConfigReader
    ; ConfigReader.set(this.state, config.Hotkeys.jsonPath)
    if(this.isWasChanged){
      ConfigReader.set(this.state, this.jsonPath)
    }
  }


  aliasFunction(hotkey := ""){
    ; SendLevel 2
    ; MsgBox "aliasFunction() = " . hotkey
    Send hotkey
  }


  /**
   * Обновляет хоткей, при изменении полей на странице Settings.
   * @param hotkeysState - строка состояния state из страницы Settings.
   * @param hotkeyId - id хоткея который обновляется.
   */
  updateHotkey(hotkeysState, hotkeyId) {

    this.isWasChanged := true
    ; Устанавливаем состояние, хоткеи из состояния страницы Settings
    this.state := JSON.Parse(hotkeysState, false, false)
 
    aliasFunc(arg, ThisHotkey){
      this.aliasFunction(arg)
    }

    
      ; Ищем хоткей изменённый на странице, в состоянии
      for i, aliasHotkey in this.state {
        ; Найден хоткей
        if (aliasHotkey.id == hotkeyId) {

          ; Отключаем предыдущий хоткей.
          try{
            if (aliasHotkey.scope) {
              HotIfWinActive "ahk_class " . aliasHotkey.scope
              Hotkey(aliasHotkey.aliasHotkey, "Off")
              HotIfWinActive
            } else {
              Hotkey(aliasHotkey.aliasHotkey, "Off")
            }
          }
          
          ; Назначаем хоткей, если отмечено isEnable.
          if (aliasHotkey.isEnable) {
            if (aliasHotkey.scope) {
              HotIfWinActive "ahk_class " . aliasHotkey.scope
              Hotkey(aliasHotkey.aliasHotkey, aliasFunc.bind(aliasHotkey.hotkeyHotkey), "On")          
              HotIfWinActive
              this.assignedHotkeys[hotkeyId] := aliasHotkey.aliasHotkey
            } else {
              Hotkey(aliasHotkey.aliasHotkey, aliasFunc.bind(aliasHotkey.hotkeyHotkey), "On")          
              this.assignedHotkeys[hotkeyId] := aliasHotkey.aliasHotkey
            }
          }
        }
      }
    
  }


  /**
 * Удаляет хоткей, при изменении полей на странице Settings.
 * @param hotkeysState - строка состояния state из страницы Settings.
 * @param hotkeyId - id хоткея который удаляется.
 */
  deleteHotkey(hotkeysState, hotkeyId) {

    this.isWasChanged := true
    ; Устанавливаем состояние, хоткеи из состояния страницы Settings
    this.state := JSON.Parse(hotkeysState, false, false)
  
    ; Ищем хоткей изменённый на странице, в состоянии
    for i, aliasHotkey in this.state {
      ; Найден хоткей
      if (aliasHotkey.id == hotkeyId) {
        ; Отключаем предыдущий хоткей.
        try{
          if (aliasHotkey.scope) {
            HotIfWinActive "ahk_class " . aliasHotkey.scope
            Hotkey(aliasHotkey.aliasHotkey, "Off")
            HotIfWinActive
          } else {
            Hotkey(aliasHotkey.aliasHotkey, "Off")
          }
        }
      }
    }
  }


  ; Устанавливает хоткеи в Hotkey() из состояния state.
  setHotkeys(hotkeysState := "") {

    aliasFunc(arg, ThisHotkey){
      this.aliasFunction(arg)
    }

    if(hotkeysState != ""){
      this.isWasChanged := true
      ; Устанавливаем состояние, хоткеи из состояния страницы Settings
      this.state := JSON.Parse(hotkeysState, false, false)
    }

    ; Отключаем все назначенные хоткеи
    if (ObjOwnPropCount(this.assignedHotkeys) > 0) {
      for k, aliasHotkey in this.assignedHotkeys.OwnProps() {
        try{
          if (aliasHotkey.scope) {
            HotIfWinActive "ahk_class " . aliasHotkey.scope
            Hotkey(aliasHotkey.aliasHotkey, "Off")
            HotIfWinActive
          } else {
            Hotkey(aliasHotkey.aliasHotkey, "Off")
          }
        }
      }
    }

    ; Устанавливаем Hotkey() из состояния.
    for i, aliasHotkey in this.state {
      if (aliasHotkey.isEnable) {
        if (aliasHotkey.scope) {
          HotIfWinActive "ahk_class " . aliasHotkey.scope
          Hotkey(aliasHotkey.aliasHotkey, aliasFunc.bind(aliasHotkey.hotkeyHotkey), "On")          
          HotIfWinActive
          this.assignedHotkeys[aliasHotkey.id] := aliasHotkey.aliasHotkey
        } else {
          Hotkey(aliasHotkey.aliasHotkey, aliasFunc.bind(aliasHotkey.hotkeyHotkey), "On")          
          this.assignedHotkeys[aliasHotkey.id] := aliasHotkey.aliasHotkey
        }
      }
    }
  }


}

