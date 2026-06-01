
; Строка которая добавляется в реестр при установке,
; в переменную Reg.
global firstInstallRegistryPassword := "j2k4ou"

; Конфиг программы:
global config := {}

config.appName := "QuickHotkeys"
config.currentVersion := "v2.1.3"

; Где размещается файл регистрации
config.regPath := "HKCU\SOFTWARE\Classes\AppXswj1dd2zfbfudg3sq1dukp9gsihyt"

; Где будут размещаться данные программы.
; A_AppDataCommon - C:\ProgramData
; A_AppData - C:\Users\<UserName>\AppData\Roaming
config.appDataDir := A_AppData . "\" . config.appName

; Устанавливается после проверки новой версии: 
; Это хранится в data.json
config.newVersion := config.currentVersion
config.newVersionUrl := "https://github.com/mnbcz/QuickHotkeys/releases"

; Время когда была последняя проверка на наличии новой версии,
; запрос на Github.
; Установим стартовое время на -20 дней.
config.newVersionCheckTime := DateAdd(A_Now, -20, "days")

config.email := "mnbczmnbcz@gmail.com"
config.youtubeUrl := "https://www.youtube.com/playlist?list=PLVkS_eTsfH-sEFw55o5UkRK7uMNIyICXb"
; Урл к странице Gumroad, чтобы купить.
config.urlToBy := "https://coolthemes.gumroad.com/l/QuickHotkeys"

; Для проверки на наличие новой версии.
; Урл возвращающий все релизы.
config.gitReleasesUrl := "https://api.github.com/repos/mnbcz/QuickHotkeys/releases"

; Сколько программа будет работать, в днях? 
; Потом нужно снова регистрировать лицензию.
; 365 - 1 год
; 730 - 2 года.
; licenseExpiredInDays
; 366, 183
config.licenseExpiredInDays := 183
config.trialExpiredInDays := 14
; Когда триал закончился, появляется окно сообщающее что нужен ключ.
; Это определяет интервал в минутах, через какое время будет постоянно появляться это окно.
config.trialExpiredRegistrationWindowAppearInterval := 20

; Таймаут в часах на проверку новой версии.
; Запрос не делается если таймаут с последнего запроса не прошёл.
config.newVersionCheckTimeout := 24

; В миллисекундах.
; 1 минута = 1000 * 60
; 1 час = 1000 * 60 * 60. 
; 12 часов = 1000 * 60 * 60 * 12 = 43,200,000

; Через сколько времени сделать запрос на сервер, после старта скрипта, 
; не после перезагрузки. В миллисекундах.
; Должно быть отрицательным.
; Нельзя устанавливать меньше чем 10 000, будут ошибки.
config.checkUpdate_FromStartTimeout := -20000

; Production
; В браузере включить DevTools?
; В производстве - отключить.
config.AreDevToolsEnabled := true

; Включить правый клик?, чтобы появлялось окно копировать.
config.AreDefaultContextMenusEnabled := true

; Это триал?
; Устанавливается скриптом. Самим не нужно устанавливать.
config.isTrial := false

; Данные. Например последнее время запроса наличия новой версии.
config.Data := {}
config.Data.dataPath := config.appDataDir . "/data.json"


global gumroadOptions := {
    product_id: "L_wDucKubLTLaLf5soFeSQ==",
    ; 6F0E4C97-B72A4E69-A11BF6C4-AF6517E7
    urlToBy: config.urlToBy,
    ; Таймаут в секундах
    timeout: 40,
    ; TEST:
    ; Сколько запросов на этот ключ будет считаться действительным ключом.
    ; Нужно в производстве установить 1.
    ; Что означает что на этот ключ можно сделать только один запрос.
    usesLimit: 1
}


; Определяет какая функция назначена, для действия.
; Например такого как: RButton+Wheel.
global hotkeysActions := {
    ; RButtonAndWheel: "minimizeMaximizeWindow"
    RButtonAndWheel: 0,
    gestures: 0,
    holdingLeftRightKey: 0,
    holdingRepeatSymbols: 0,
    holdingEsc: 0,
    hotStrings: 0,
    hideTaskbar: 0,
    altTabOnTaskbar: 0
}

; Функции которые назначаются на нажатие одной клавиши sc, например sc14D.
; Ключ - это клавиша, а значение - это имя функции которая вызывается 
; при нажатии этой клавиши.
global oneKeyFunctions := Map()
; 27  14D	s	u	0.12	Right          	
; 25  14B	h	d	1.25	Left 
oneKeyFunctions["sc14D"] := "sc14D"
oneKeyFunctions["sc14B"] := "sc14B"
; BD  00C	s	u	0.14	-              	
; BB  00D	h	d	0.27	=  
oneKeyFunctions["scC"] := "scC"
oneKeyFunctions["scD"] := "scD"
; 1B  001	h	d	1.03	Escape  
oneKeyFunctions["sc1"] := "sc1"

