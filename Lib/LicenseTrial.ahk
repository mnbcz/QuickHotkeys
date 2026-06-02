; /Lib/LicenseTrial.ahk
#Include License.ahk
#Include Utils.ahk
; #Include GumroadRequest.ahk


; =======================================================================
; Проверка лицензии.

; При первом старте программы создаём запись в реестре, и скрытый файл Reg,
; в скрытом каталоге с программой.
; В файле, зашифрованный json: 
; - Дата установки,  
; - Ключ регистрации, (если нет, то значит это триал).
; - Ид компьютера.

; Проверяем, это первый старт программы, или нет.
; Ищем записи Reg в реестре.
; Если запись Reg не найдено в реестре, то ищем скрытый файл.
; Если скрытый файл не найден, то это первый старт программы.
; Создаём записи, в реестре, и в файле.
; Если скрытый файл найден, то наверно кто-то удалил запись из реестра.
; Записываем снова запись в реестр.

; Проверяем действие лицензии.
; Проверяем существует ли ключ key лицензии, из реестра.
; Если ключ не существует, то это триал.
;   Проверяем дату установки.
;   Если срок триала закончен, то отображает окно указать ключ.

; Если ключ лицензии существует, то проверяем действительность лицензии.
; Проверяем ид компьютера с ид из Реестра.
; Проверяем срок действия программы.
; Если что-то ошибочно, отображаем окно регистрации ключа, 
; с сообщением ошибки.

; Проверка даты установки.
; Кто-то может сдвинуть часы в компьютере на будущее время,
; при установке.
; Если ключа лицензии ещё нет, это триал, то при каждом старте скрипта,
; записывать дату старта в массив.
; Более нижняя дата должна быть всегда больше верхней.
; Если не так, то открываем окно регистрации ключа.

; Проверка ключа.
; После покупки выдаётся ключ.
; Этот ключ нужно указать в поле регистрации.
; Если ключ правильный, то программа будет работать.
; Чтобы проверить что ключ правильный, то отправляется запрос на сервер
; Gumroad, будет ответ, где поле uses будет равно числу запросов проверок.
; Это будет равно 1, если отправляется первый запрос.
; Для этого ключи должны генерироваться уникальными на Gumroad.
; Если проверка пройдена, и это первый запрос на этот ключ, то
; этот ключ + ид компьютера, шифруем, и помещаем в Reg запись в реестре.
; Чтобы нельзя было использовать скопированные данные в реестре, на 
; другом компьютере, при старте программы, проверяем ид компьютера
; из реестра, с ид компьютера. 

; Лицензия должна быть установлена в реестре при установке программы.
; При первом старте программы, в реестре должна быть запись.
; Сначала в реестре при установке должна быть установлена 
; строка пароля firstInstallRegistryPassword.
; Этот класс зависит от переменных:
; global firstInstallRegistryPassword
; global Config.isTrial
class LicenseTrial extends License{

    options := {
        ; Название приложения. Это название будет в реестре.
        appName: 0,
        ; Через какое время заканчивается лицензия, в днях.
        licenseExpiredInDays: 0,
        ; Через сколько дней заканчивается триал.
        trialExpiredInDays: 0,
        isTrial: false
    }


    __New(options, regKey) {
        this.options := options
        if(!this.options.licenseExpiredInDays || !this.options.trialExpiredInDays
        || !this.options.appName){
            MsgBox "Config license not set"
            ExitApp
        }

        super.__New(regKey)

    }

    ; Создаёт запись в реестре, объект с ключами.
    ; Вызывается при первом старте программы.
    ; Или добавляет ключ в реестр.
    createLicenseInRegistry(key := false){

        local compId := this.getBaseBoardId()

        local jsonMap := Map()
        jsonMap["compId"] := compId
        jsonMap["key"] := key
        jsonMap["dateCreate"] := A_Now

        local datesStart := []
        datesStart.Push(A_Now)

        ; Массив времён стартов скрипта, при триал периоде.
        ; Чтобы пользователь не обманул с установкой даты на будущее 
        ; при установке.
        jsonMap["datesStart"] := datesStart
        
        ; Время через которое заканчивается лицензия, в днях.
        jsonMap["licenseExpiredInDays"] := this.options.licenseExpiredInDays

        local encJsonStr := this.getEncryptedStrFromMap(jsonMap)

        this.setStrInRegistry(encJsonStr)

    }


    ; Лицензия должна быть установлена в реестре при установке программы.
    ; При первом старте программы, в реестре должна быть запись.
    ; Если этот метод вернёт false, то нужно будет закрыть скрипт.
    ; Если true, то или триал ещё не закончился, или лицензия ещё действует.
    checkLicense(){
 
        global firstInstallRegistryPassword

        ; Сначала в реестре при установке должна быть установлена строка пароля, лицензия.

        ; Получаем лицензию из реестра.
        local regStr := this.getStrFromRegistry()
        if(!regStr){
            ; В реестре нет такой программы, нет записей.
            local props := {message: "License not found. A license key is required."}
            return this.OpenRegisterWindow(props)
        }

        ; Сначала в реестре при установке должна быть установлена строка пароля.
        if(regStr == firstInstallRegistryPassword){
            ; Это первый старт скрипта.
            this.createLicenseInRegistry()
            this.options.isTrial := true
            return true  
        }


        ; Это не первый старт скрипта:
        
        ; Конвертируем строку лицензии в Map.
        local regMap := this.getMapFromEncryptedString(regStr)
        if(!regMap){
            local props := {message: "Installation file is damaged. A license key is required."}
            return this.OpenRegisterWindow(props)
        }

        local dateCreate := regMap.Get("dateCreate", false)
        local key := regMap.Get("key", false)

        ; Это триал?
        if(!key){
            ; Ключ ещё не установлен в реестр.
            ; Это триал.

            this.options.isTrial := true

            ; Проверяем на обман со временем регистрации 
            local datesStart := regMap.Get("datesStart", false)
            if(!this.checkSequenceTime(datesStart)){
                local props := {message: "Something is wrong with the installation time. The program must be registered."}
                return this.OpenRegisterWindow(props)
            }

            local dateDifTrial := DateDiff(A_Now, dateCreate, "days") 
            if(dateDifTrial >= this.options.trialExpiredInDays){
                ; Триал период закончился
                local props := {message: "The trial period has ended. The program must be registered."}
                return this.OpenRegisterWindow(props)
            }else{
                ; Триал период не закончился
                
                ; Перезаписываем даты стартов программы в реестре.
                local datesStart := regMap.Get("datesStart", false)
                datesStart.Push(A_Now)
                regMap.Set("datesStart", datesStart)
                local encJsonStr := this.getEncryptedStrFromMap(regMap)
                this.setStrInRegistry(encJsonStr)

                return true
            }
        }

        ; Это не триал:

        ; Сколько дней прошло с момента установки лицензии?
        local dateDif := DateDiff(A_Now, dateCreate, "days") 
        if(dateDif >= regMap.Get("licenseExpiredInDays")){
        ; if(dateDif >= 1){
            ; The license has expired
            local props := {message: "The license has expired. It need to <a href='" this.options.urlToBy "' target='_blank'>upgrade license</a>."}
            return this.OpenRegisterWindow(props)
        }

        ; Проверка compId
        local compId := regMap.Get("compId", false)
        if(compId == this.getBaseBoardId()){
        ; if(compId == "jksklfkfkdj"){
        
            ; Комп id из файла, и полученный из свойств компьютера, 
            ; совпадают.
            return true
        }else{
            local props := {message: "The license is already registered on another computer. <a href='" this.options.urlToBy "'>Buy a new key</a>."}
            return this.OpenRegisterWindow(props)
        }

    }


    ; Это базовый класс.
    ; Это перегружается наследником.
    ; Открывает окно зарегистрировать ключ.
    ; Когда окно будет закрыто:
    ; Возвращает true, если ключ был зарегистрирован.
    ; Возвращает false, если нет.
    ; props - Map со свойствами и значениями, которые добавить к классу LicenseExpiredHtml. 
    ; Нужно указать опции Gumroad здесь, переопределить в наследующем классе.
    OpenRegisterWindow(props := {}){

        ; local optionsGumroad := {
        ;     product_id: "",
        ;     license_key: "",
        ;     urlToBy: "",
        ;     ; Таймаут в секундах
        ;     timeout: 40,
        ;     ; TEST:
        ;     ; Сколько запросов на этот ключ будет считаться действительным ключом.
        ;     ; Нужно в производстве установить 1.
        ;     ; Что означает что на этот ключ можно сделать только один запрос.
        ;     usesLimit: 1000
        ; }

        ; local GReq := GumroadRequest(optionsGumroad)

        ; local RegHtml := this.RegisterWindowHtml(GReq, this, props)

        ; RegHtml.win.Title := "Screen Keyboard"
        ; RegHtml.init()
        ; RegHtml.navigate(A_ScriptDir . "\modules\Tray\RegisterWindow\index.html")
        
        ; ; Ждём пока окно не закроется.
        ; while RegHtml.isClose = false{
        ;     Sleep 100
        ; }
        ; ; MsgBox "Window is closed"
        ; return RegHtml.isKeyRegistered

    }
    
}






; ; Этот класс должен принимать другие классы, которые должны 
; ; реализовывать методы:
; ; this.License.createLicenseInRegistry(key)
; ; this.Request.checkKey(key)
; class RegisterWindowHtml extends WebViewBase{

;     ; Объект который отсылается на страницу Html.
;     itemsToHtml := {
;         ; Сообщение на верху страницы.
;         ; message: "",
;         ; isRegistered: true
;     }

;     ; Ключ был зарегистрирован?
;     isKeyRegistered := false

;     ; Созданный объект класса запроса. Например GumroadRequest.
;     Request := {}

;     ; Класс лицензии. Чтобы вызвать метод записи ключа в реестр.
;     License := {}

;     __New(Request, License, itemsToHtml := {}){

;         this.Request := Request
;         this.License := License

;         if ObjOwnPropCount(itemsToHtml) > 0{
;             this.itemsToHtml := itemsToHtml
;         }
;     }

;     ; Добавляем методы для страницы Html 
;     AddHostObjectToScript(){

;         local eventHandlers := {
;             sendKey: (key) => this.sendKey(key)
;         }

;         ; Call method in base class.
;         super.AddHostObjectToScript(eventHandlers)

;     }


;     ; Обработчик который вызывается после загрузки страницы.
;     NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs){
;           ; Установка сообщения на верху окна.
;         if(ObjOwnPropCount(this.itemsToHtml > 0)){
;             ; Чтобы передать аргумент строкой, кодируем 2 раза
;             local items := JSON.Stringify(JSON.Stringify(this.itemsToHtml))
;             ; MsgBox message
;             this.wv.ExecuteScript("fromAhkMain(" . items . ")", false)
;         }
;     }


;    ; Вызывается в html, и передаёт ключ из поля ключа.
;    sendKey(key){

;         ; MsgBox key

;         try{
;             ; Отправляем запрос на сервер.
;             ; Все исключения брошенные в Request, будут ловится здесь.
;             if(this.Request.checkKey(key)){
;                 ; Ключ действительный, и регистрируется в первый раз.

;                 this.License.createLicenseInRegistry(key)

;                 this.isKeyRegistered := true

;                 this.itemsToHtml.message := "✓ The program has been successfully registered!" 
;                 this.itemsToHtml.isRegistered := true

;                 ; Если для строки использовать JSON.Stringify(message), то:
;                 ; message - будет "message". И "кавычки" внутри экранируются \".)
               
;                 local items := JSON.Stringify(JSON.Stringify(this.itemsToHtml))
                    
;                 this.wv.ExecuteScript("fromAhkMain(" items ")", false)
            
;             }
;         }catch as e{
;             local messageObj := {}
;             messageObj.message := e.Message
;             local items := JSON.Stringify(JSON.Stringify(messageObj))
;             this.wv.ExecuteScript("fromAhkMain(" . items . ")", false)
;         }

;     }

; }







; ++++++++++++++++++++++++++ Старт скрипта ++++++++++++++++++++++++:


; options := {
;     ; Название приложения.
;     appName: "Screen Keyboard",
; }

; Lic := LicenseTrial(options)


; if(!Lic.checkLicense()){
;     ; Лицензия не действительна.
;     ExitApp
; }



