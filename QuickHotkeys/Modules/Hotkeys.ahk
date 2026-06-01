
#Include ../configs/config.ahk

config.Hotkeys := {}
; config.Hotkeys.jsonPath := config.appDataDir . "/hotkeys.json"
; TEST
; config.Hotkeys.jsonPath := A_ScriptDir .  "/appDataDir/hotkeys.json"
; config.Hotkeys.jsonDefaultPath := A_ScriptDir . "/configs/hotkeys-default.json"

config.Hotkeys.jsonPath := config.appDataDir .  "/hotkeys.json"
config.Hotkeys.jsonDefaultPath := A_ScriptDir . "/configs/hotkeys-default.json"

; Хоткеи из файла json хоткеев
class Hotkeys {

    jsonPath := config.Hotkeys.jsonPath 
    jsonDefaultPath := config.Hotkeys.jsonDefaultPath

    ; Массив объектов хоткеев, из hotkeys.json
    state := {}
    ; Хоткеи которые были назначены для Hotkey().
    ; {"id хоткея": "!+^sc10", ... }
    ; Чтобы отключить активный хоткей
    assignedHotkeys := {}

    ; Состояние было изменено? Изменялись поля?
    isWasChanged := false

    __New(){
    }

    init(){
        this.loadFromJsonFile()
        this.setHotkeys()
    }

    ; Загружает состояние хоткеев из файла.
    loadFromJsonFile(){
        global config, ConfigReader
        ; this.state := ConfigReader.getObject(config.Hotkeys.jsonPath)
        this.state := ConfigReader.getObject(this.jsonPath)
    }

    ; Сохраняет конфиг в файл
    saveToJsonFile(){
        global config, ConfigReader
        ; ConfigReader.set(this.state, config.Hotkeys.jsonPath)
        ConfigReader.set(this.state, this.jsonPath)
    }

    ; Возвращает строку json дефаулт хоткеев из файла.
    getDefaultHotkeysString(){
        global config, ConfigReader
        return ConfigReader.getRaw(this.jsonDefaultPath)
    }

    ; Устанавливает дефаулт хоткеи
    resetToDefaultHotkeys(){
        global config, ConfigReader
        ; Перезаписываем json файл дефаулт значениями
        ; ConfigReader.setRaw(this.getDefaultHotkeysString(), config.Hotkeys.jsonPath)
        ConfigReader.setRaw(this.getDefaultHotkeysString(), this.jsonPath)
        ; Устанавливаем состояние из файла в json
        this.loadFromJsonFile()
        ; Назначаем хоткеи
        this.setHotkeys()
    }

    ; Обновляет состояние state этого класса, 
    ; при изменении полей и флажков хоткея, в окне Settings хоткеев. 
    ; Назначает Hotkey(), или отключает.
    ; Не сохраняется в файл.
    ; hotkeysState - строка json состояния хоткеев со страницы Settings.
    ; hotkeyId - ид элемента который был изменён на странице. 
    updateHotkey(hotkeysState, hotkeyId){

        this.isWasChanged := true
        ; Устанавливаем состояние, хоткеи из состояния страницы Settings
        this.state := JSON.Parse(hotkeysState, false, false)
        
        ; Устанавливаем Hotkey's
        ; Нужно знать предыдущий хоткей который был назначен, чтобы его отключить.

        ; Предыдущий хоткей.
        ; Хоткей ^q назначенный на этот id хоткея.
        local prevHotkey := false
        ; Устанавливаем предыдущий хоткей
        if( this.assignedHotkeys.HasOwnProp(hotkeyId) ){
            prevHotkey := this.assignedHotkeys[hotkeyId]
        }

        ; Ищем хоткей изменённый на странице, в состоянии
        for i, v in this.state{
            ; Найден хоткей
            if(v.id == hotkeyId){

                ; Добавляем хоткей в список хоткеев, с названиями.
                if (v.HasOwnProp("hotkeyListName")){
                    global hotkeyList
                    hotkeyList[v.hotkeyListName] := v.hotkeyModifiers . v.sc
                }

                ; if(v.type == "noHotkey"){
                ;     %v.function%(v)
                ;     break
                ; }

                if(v.type == "mod&key"){
                    ; Хоткей ^+sc10
                    local hotkeySc := v.hotkeyModifiers . v.sc
                    ; Название функции которая срабатывает для хоткея.
                    local fName := %v.function%
                    ; Отключаем предыдущий хоткей.
                    if(prevHotkey){
                        if (v.HasOwnProp("ahk_classes")){
                            for index, ahk_class in v.ahk_classes{
                                HotIfWinActive ahk_class
                                Hotkey(prevHotkey, "Off")
                            }
                            HotIfWinActive
                        }else{
                            Hotkey(prevHotkey, "Off")
                        }
                    }
                    ; Назначаем хоткей, если отмечено isEnable. 
                    if(v.isEnable){
                        if (v.HasOwnProp("ahk_classes")){
                            for index, ahk_class in v.ahk_classes{
                                HotIfWinActive ahk_class
                                Hotkey(hotkeySc, fName.bind(v.sc), "On I1")
                            }
                            HotIfWinActive
                            this.assignedHotkeys[hotkeyId] := hotkeySc
                        }else{
                            ; Передаём в функцию аргумент - sc код клавиши, cs10 
                            Hotkey(hotkeySc, fName.bind(v.sc), "On I1")
                            this.assignedHotkeys[hotkeyId] := hotkeySc
                        }

                    }
                }else{
                    %v.function%(v)
                }
                break
            }
        }
    }


    ; Устанавливает хоткеи в Hotkey() из состояния state.
    setHotkeys(){
        ; Отключаем все назначенные хоткеи
        if (ObjOwnPropCount(this.assignedHotkeys) > 0){
            for k, v in this.assignedHotkeys.OwnProps(){
                if (v.HasOwnProp("ahk_classes")){
                    for index, ahk_class in v.ahk_classes{
                        HotIfWinActive ahk_class
                        Hotkey(v, "Off")
                        HotIfWinActive
                    }
                }else{
                    Hotkey(v, "Off")
                }
            }
        }

        for i, v in this.state{

            ; Если нет свойства function, то не нужно назначать Hotkey
            if(!v.HasOwnProp("function")){
                continue
            }
            local fName := %v.function%

            ; if(v.type == "noHotkey"){
            ;     fName(v)
            ;     continue
            ; }
            
            if(v.type == "mod&key"){
                local hotkeySc := v.hotkeyModifiers . v.sc
                ; Если отмечено у хоткея isEnable, то назначаем Hotkey().
                ; Для хоткея назначаем функцию, и аргументом передаём scKey.
                if(v.hotkeyModifiers && v.isEnable){

                    if (v.HasOwnProp("ahk_classes")){
                        for index, ahk_class in v.ahk_classes{
                            HotIfWinActive ahk_class
                            Hotkey(hotkeySc, fName.bind(v.sc), "On I1")
                            HotIfWinActive
                        }
                        this.assignedHotkeys[v.id] := hotkeySc
                    }else{
                        ; Передаём в функцию аргумент - sc код клавиши, cs10 
                        Hotkey(hotkeySc, fName.bind(v.sc), "On I1")
                        this.assignedHotkeys[v.id] := hotkeySc
                    }
                }
                continue
            }else{
                fName(v)
                continue
            }
        }
    }


    /**
     * Возвращает sc код клавиши - sc10.
     * @param key - q - клавиша.
     */
    getScKey(key){
        global Utils
        return Utils.GetKeySCFromLang(key)
    }

    ; Перезаписывает конфиг новыми значениями, после обновления программы.
    ; Вызывать когда было обновление программы, и конфиг был изменён, 
    ; при первом старте программы.
    ; Из прежднего user конфиг получает установленные значения, хоткеи, 
    ; и записывает в новый обновлённый конфиг, если путь совпадает.
    ; Заменяет user конфиг новым конфиг.
    ; newJsonPath - путь к новому конфиг (обычно в temp каталоге).
    ; userJsonPath - путь к user конфиг.
    static updateJsonFileFromNewVersion(newJsonPath := config.appDataDir . "\temp\hotkeys.json", userJsonPath := config.Hotkeys.jsonPath){

        local newJson := ConfigReader.getObject(newJsonPath)
        local userJson := ConfigReader.getObject(userJsonPath)

        if(!newJson){
            return
        }
        if(!userJson){
            ; Копируем из каталога temp в app_data
            FileCopy(newJsonPath, userJsonPath)
        }

        ; Ключи, значения которых нужно обновить
        keyNamesToUpdate := ["modName", "modSymbol", "isChecked", 
        "key", "sc", "name", "path", "isActive", "isEnable"]

        Utils.replaceValuesFromUserJson(newJson, userJson, keyNamesToUpdate)
            
        ; Перезаписываем user конфиг
        ConfigReader.set(newJson, userJsonPath)

    }



}

