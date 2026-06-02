
; Запрос проверки ключа на сайт Gumroad.
; Нужно передать объект опций при создании объекта класса.
; Этот класс зависит от класса Utils.

; Example:

; options := {
;     product_id: "",
;     license_key: "",
;     urlToBy: "",
;     usesLimit: 1
; }

; GumroadReq := GumroadRequest(options)
; try{
;     isRegistered := GumroadReq.checkKey()
;     if(isRegistered){

;     }
; }catch as e{
;     ; Ключ не зарегистрирован.
;     ; e.Message
;     ; Нужно ожидать правильного ключа.
; }
class GumroadRequest{

    options := {
        product_id: "",
        urlToBy: "",
        ; Таймаут в секундах
        timeout: 40,
        ; Сколько запросов на этот ключ будет считаться действительным ключом.
        ; Нужно в производстве установить 1.
        ; Что означает что на этот ключ можно сделать только один запрос.
        usesLimit: 1000
    }

    __New(options) {
        this.options:= Utils.mergeObjects(this.options, options)
    }

     
    ; Отправляет запрос на сервер для проверки действительности лицензии.
    ; Возвращает true, если ключ действительный, и регистрируется в первый раз.
    ; Выбрасывает исключения, если запрос не успешный, 
    ; или если ключ не действительный.
    ; Поступает ключ лицензии.
    checkKey(key){
            
        ; https://learn.microsoft.com/en-us/windows/win32/winhttp/winhttprequest
        local whr := ComObject("WinHttp.WinHttpRequest.5.1")
        
        try {

            ; arg-3:
            ; true - async. Вызов метода Send() возвращает сразу, 
            ; и не ждёт ответа.
            ; При этом использование whr.WaitForResponse(4, false) будет ждать ответ.
            ; Так можно указать таймаут для запроса.

            ; false - sync. Send() будет ждать ответа.
            ; Так нельзя указать таймаут для запроса.
            ; https://api.gumroad.com/v2/licenses/verify
            ; http://localhost:3000/test
            whr.Open("POST", "https://api.gumroad.com/v2/licenses/verify", true)
            ; whr.Open("POST", "http://localhost:3000/test", true)
            whr.SetRequestHeader("Content-Type", "application/json; charset=UTF-8")

            local jsonMap := Map()
            jsonMap["product_id"] := this.options.product_id
            jsonMap["license_key"] := key

            ; Отсылаем запрос на сервер.
            whr.Send(JSON.Stringify(jsonMap))

            ; Таймаут в секундах
            local res := whr.WaitForResponse(this.options.timeout, false)

        } catch as e {
            ; Интернет не подключен.
            ; e - https://www.autohotkey.com/docs/v2/lib/Error.htm
            throw Error("It looks like the Internet is disconnected. Check your internet connection and try again.")
        }


        if(!res){
            ; Превышен таймаут запроса.
            ; Arg1:
            ; Сообщение ошибки. Это будет в e.Message.
            ; Arg2:
            ; -1 - содержит имя этой функции.
            ; -2 - имя функции которая вызывала эту функцию, и тд.
            ; Это будет в e.What.
            ; Arg3:
            ; Идентификатор ошибки, любая строка. Это будет в e.Extra.
            throw Error("Request timeout exceeded", -1, "TO")
        }

        ; if (whr.Status >= 300) and (whr.Status < 400)
        ; MsgBox "Res = " . whr.ResponseText
        
        try{
            ; Ответ от сервера
            local resJson := JSON.Parse(whr.ResponseText)
        }catch as e{
            throw Error("Wrong parse JSON", -1, "WJSON")
        }

        local message := resJson.Get("message", "")

        if (!resJson.Get("success", false)){
            ; Ответ не успешен
            message := message . " Specify the correct key."       
            throw Error(message, -1)
        }

        if(!resJson.Get("uses", false)){
            throw Error("Wrong response format", -1)
        }

        ; uses - сколько было запросов, включая этот.
        if (resJson.Get("uses") > this.options.usesLimit) {
            throw Error("The program has already been registered before for this key. You can only register one program per computer. <a href=`'" this.options.urlToBy "`'>You can purchase a new key here</a>.", -1)
        } else {
            return true
        }

    }


}

