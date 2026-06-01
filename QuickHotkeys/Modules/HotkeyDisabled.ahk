
; Хоткеи алиасы из /appDataDir/hotkeyAliases.json.
class HotkeyDisabled {

  ; jsonPath := A_ScriptDir . "/appDataDir/hotkeyDisabled.json"
  jsonPath := config.appDataDir . "/hotkeyDisabled.json"

  ; Массив объектов хоткеев, из .json
  state := {}
  ; Хоткеи которые были назначены для Hotkey().
  ; {"id хоткея": "!+^sc10", ... }
  ; Чтобы отключить активный хоткей
  assignedHotkeys := {}

  ; Состояние было изменено? Изменялись поля?
  ; Чтобы сохранить потом.
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

  /**
   * Обновляет хоткей, при изменении полей на странице Settings.
   * @param hotkeysState - строка состояния state из страницы Settings.
   * @param hotkeyId - id хоткея который обновляется.
   */
  updateHotkey(hotkeysState, hotkeyId) {

    this.isWasChanged := true
    ; Устанавливаем состояние, хоткеи из состояния страницы Settings
    this.state := JSON.Parse(hotkeysState, false, false)

    disableFunc(*){
      return false
    }

    ; Ищем хоткей изменённый на странице, в состоянии
    for i, hotkeyDisable in this.state {
      ; Найден хоткей
      if (hotkeyDisable.id == hotkeyId) {
        ; Отключаем предыдущий хоткей.
        try{
          if (hotkeyDisable.scope) {
            HotIfWinActive "ahk_class " . hotkeyDisable.scope
            ; Hotkey(hotkeyDisable.hotkey, disableFunc, "Off")
            Hotkey(this.assignedHotkeys[hotkeyId], disableFunc, "Off")
            HotIfWinActive
          } else {
            ; Hotkey(hotkeyDisable.hotkey, disableFunc, "Off")
            Hotkey(this.assignedHotkeys[hotkeyId], disableFunc, "Off")
          }
        }

        this.assignedHotkeys.DeleteProp(hotkeyId)
        
        ; Назначаем хоткей, если отмечено isEnable.
        if (hotkeyDisable.isEnable) {
          if (hotkeyDisable.scope) {
            HotIfWinActive "ahk_class " . hotkeyDisable.scope
            Hotkey(hotkeyDisable.hotkey, disableFunc, "On I1")          
            HotIfWinActive
            this.assignedHotkeys[hotkeyId] := hotkeyDisable.hotkey
          } else {
            Hotkey(hotkeyDisable.hotkey, disableFunc, "On I1")          
            this.assignedHotkeys[hotkeyId] := hotkeyDisable.hotkey
          }
        }
      }
    }
    
  }


  /**
 * Отключает хоткей, при изменении полей на странице Settings.
 * @param hotkeysState - строка состояния state из страницы Settings.
 * @param hotkeyId - id хоткея который удаляется.
 */
  deleteHotkey(hotkeysState, hotkeyId) {

    this.isWasChanged := true
    ; Устанавливаем состояние, хоткеи из состояния страницы Settings
    this.state := JSON.Parse(hotkeysState, false, false)
  
    ; Ищем хоткей изменённый на странице, в состоянии
    for i, hotkeyDisabled in this.state {
      ; Найден хоткей
      if (hotkeyDisabled.id == hotkeyId) {
        ; Отключаем предыдущий хоткей.
        try{
          if (hotkeyDisabled.scope) {
            HotIfWinActive "ahk_class " . hotkeyDisabled.scope
            Hotkey(this.assignedHotkeys[hotkeyId], "Off")
            HotIfWinActive
          } else {
            Hotkey(this.assignedHotkeys[hotkeyId], "Off")
          }
        }
      }
    }

    this.assignedHotkeys.DeleteProp(hotkeyId)

  }


  ; Устанавливает хоткеи в Hotkey() из состояния state.
  setHotkeys(hotkeysState := "") {

    disableFunc(*){
      return false
    }

    if(hotkeysState != ""){
      this.isWasChanged := true
      ; Устанавливаем состояние, хоткеи из состояния страницы Settings
      this.state := JSON.Parse(hotkeysState, false, false)
    }

    ; Отключаем все назначенные хоткеи
    if (ObjOwnPropCount(this.assignedHotkeys) > 0) {
      for k, hotkeyDisabled in this.assignedHotkeys.OwnProps() {
        try{
          if (hotkeyDisabled.scope) {
            HotIfWinActive "ahk_class " . hotkeyDisabled.scope
            Hotkey(hotkeyDisabled.hotkey, "Off")
            HotIfWinActive
          } else {
            Hotkey(hotkeyDisabled.hotkey, "Off")
          }
        }
      }
    }

    ; Устанавливаем Hotkey() из состояния.
    for i, hotkeyDisabled in this.state {
      if (hotkeyDisabled.isEnable) {
        if (hotkeyDisabled.scope) {
          HotIfWinActive "ahk_class " . hotkeyDisabled.scope
          ; Hotkey(hotkeyDisabled.hotkey, disableFunc, "I1")    
          Hotkey(hotkeyDisabled.hotkey, disableFunc, "On I1")          
          HotIfWinActive
          this.assignedHotkeys[hotkeyDisabled.id] := hotkeyDisabled.hotkey
        } else {
          ; Hotkey(hotkeyDisabled.hotkey, disableFunc, "I1")      
          Hotkey(hotkeyDisabled.hotkey, disableFunc, "On I1")          
          this.assignedHotkeys[hotkeyDisabled.id] := hotkeyDisabled.hotkey
        }
      }
    }
  }

}

