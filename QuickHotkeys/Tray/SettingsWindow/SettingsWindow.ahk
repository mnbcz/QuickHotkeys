

class SettingsWindow extends WebViewBase {

  __New() {

    global config, Modules
    super.__New()
    this.win.Title := config.appName " - Settings"
    ; this.win.Opt("-MaximizeBox +ToolWindow -0xCF0000")

    local eventHandlers := {
      hotkeys: JSON.Stringify(Modules.Hotkeys.state),
      hotkeysDefault: Modules.Hotkeys.getDefaultHotkeysString(),
      updateHotkey: (hotkeys, id) => Modules.Hotkeys.updateHotkey(hotkeys, id),
      resetToDefaultHotkeys: () => this.resetToDefaultHotkeys(),
      getScKey: (key) => Modules.Hotkeys.getScKey(key),
      hotkeyAliases: JSON.Stringify(Modules.HotkeyAliases.state),
      hotkeyAliases_updateHotkey: (hotkeys, id) => Modules.HotkeyAliases.updateHotkey(hotkeys, id),
      hotkeyAliases_deleteHotkey: (hotkeys, id) => Modules.HotkeyAliases.deleteHotkey(hotkeys, id),
      hotkeyAliases_addHotkey: (hotkeys) => Modules.HotkeyAliases.setHotkeys(hotkeys),
      ; listenModsKeyPresses: (domId, isAddOrEdit) => this.listenModsKeyPresses(domId, isAddOrEdit),
      ; config: JSON.Stringify(config),
      hotkeyDisabled: JSON.Stringify(Modules.HotkeyDisabled.state),
      hotkeyDisabled_updateHotkey: (hotkeys, id) => Modules.HotkeyDisabled.updateHotkey(hotkeys, id),
      hotkeyDisabled_deleteHotkey: (hotkeys, id) => Modules.HotkeyDisabled.deleteHotkey(hotkeys, id),
      hotkeyDisabled_addHotkey: (hotkeys) => Modules.HotkeyDisabled.setHotkeys(hotkeys),
    }

    ; MsgBox eventHandlers.hotkeys

    this.init('y10 w1400 h790')
    this.AddHostObjectToScript(eventHandlers)
    ; this.win.BackColor := "ffffff"
    ; this.navigate('file:///' . A_ScriptDir . '\modules\Tray\SettingsWindow\SettingsWindow.html')
    this.navigate(A_ScriptDir . '\Tray\SettingsWindow\SettingsWindow.html')

  }


  ; ; Обработчик который вызывается после загрузки страницы.
  ; NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs){

  ; }


  ; Вызывается при закрытии окна.
  close() {
    global Modules
    ; Сохраняем в файл hotkeys.json
    Modules.Hotkeys.saveToJsonFile()
    Modules.HotkeyAliases.saveToJsonFile()
    Modules.HotkeyDisabled.saveToJsonFile()
    super.close()
  }


  ; Устанавливает все поля к дэфаулт значениям.
  resetToDefaultHotkeys() {
    global Modules
    Modules.Hotkeys.resetToDefaultHotkeys()
  }


  ; listenModsKeyPresses(domId, isAddOrEdit := true){
  ;   ; MsgBox "listenModsKeyPresses = " . domId
  ;   local modKey := ModifiersKeyWait()
  ;   modKey.start(pressedKeysCallback)
  ;   pressedKeysCallback(_, keys) {
  ;     local keysObjStr := ""
  ;     ; if(keys != ""){
  ;     ;   keysObjStr := JSON.stringify(JSON.stringify(keys))
  ;     ; }
  ;     keysObjStr := JSON.stringify(JSON.stringify(keys))

  ;     if(isAddOrEdit){
  ;       isAddOrEdit := "true"
  ;     }else{
  ;       isAddOrEdit := "false"
  ;     }

  ;     local fromAhk := 'fromAhk_AddAlias_listenModsKeyPresses("' . domId . '", '  . keysObjStr . ', ' . isAddOrEdit . ')'
  ;     ; MsgBox fromAhk

  ;     this.wv.ExecuteScript(fromAhk, false)
  ;     ; Возвращает объект:
  ;     ; {
  ;     ;   "hotkey": "<^<+<!sc10",
  ;     ;   "hotkeyDisplay": "LControl + LShift + LAlt + q"
  ;     ; }
  ;     ; Или пустую строку если нажато не правильно.
  ;   }
  ; }

}










