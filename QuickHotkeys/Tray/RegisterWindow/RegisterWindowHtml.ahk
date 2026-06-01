

; Этот класс должен принимать другие классы, которые должны
; реализовывать методы:
; this.License.createLicenseInRegistry(key)
; this.Request.checkKey(key)
class RegisterWindowHtml extends WebViewBase {

  ; Объект который отсылается на страницу Html.
  itemsToHtml := {
    ; Сообщение на верху страницы.
    message: "",
    isRegistered: false
  }

  ; Ключ был зарегистрирован?
  isKeyRegistered := false

  ; Созданный объект класса запроса. Например GumroadRequest.
  Request := {}

  ; Класс лицензии. LicenseTrialKeyboard.
  ; Чтобы вызвать метод записи ключа в реестр.
  License := {}

  static self := {}


  __New(Request, License, itemsToHtml := {}) {

    global config

    ; MsgBox "New"

    this.Request := Request
    this.License := License

    if (ObjOwnPropCount(itemsToHtml) > 0) {
      this.itemsToHtml := itemsToHtml
    }

    super.__New()

    this.win.Title := config.appName " - Register"
    this.win.Opt("-MaximizeBox +ToolWindow +AlwaysOnTop -0xCF0000")
    this.win.BackColor := "ffffff"
    local winWidth := 700
    local xCoord := A_ScreenWidth/2 - winWidth/2
    this.init( 'x' . xCoord . ' y120 w' . winWidth . ' h330')
    ; this.win.BackColor := "ffffff"
    this.navigate("file:///" . A_ScriptDir . "\Tray\RegisterWindow\RegisterWindow.html")
    WinSetTransparent 240, config.appName " - Register"

    RegisterWindowHtml.self := this

  }

  close(){
    super.close()
  }

  ; Добавляем методы для страницы Html
  AddHostObjectToScript() {

    local itemsToHtml := JSON.Stringify(this.itemsToHtml)

    local eventHandlers := {
      sendKey: (key) => this.sendKey(key),
      items: itemsToHtml
    }

    ; Call method in base class.
    super.AddHostObjectToScript(eventHandlers)

  }


  ; Обработчик который вызывается после загрузки страницы.
  NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs) {

    ; MsgBox "NavigationCompleteHandler"

    ; local th := RegisterWindowHtml.self

    ; ; Установка сообщения на верху окна.
    ; if(ObjOwnPropCount(th.itemsToHtml) > 0){
    ;     ; Чтобы передать аргумент строкой, кодируем 2 раза
    ;     local items := JSON.Stringify(JSON.Stringify(th.itemsToHtml))
    ;     th.wv.ExecuteScript("fromAhkMain(" . items . ")", false)
    ; }
  }


  ; Вызывается в html, и передаёт ключ из поля ключа.
  sendKey(key) {
    global config
    ; MsgBox key
    try {
      ; local message := "Request Test"
      ; throw Error(message, -1)

      ; Отправляем запрос на сервер.
      ; Все исключения брошенные в Request, будут ловится здесь.
      if (this.Request.checkKey(key)) {
        ; Ключ действительный, и регистрируется в первый раз.

        this.License.createLicenseInRegistry(key)

        this.isKeyRegistered := true

        this.itemsToHtml.message := "✓ The program has been successfully registered!"
        this.itemsToHtml.isRegistered := true

        ; Если для строки использовать JSON.Stringify(message), то:
        ; message - будет "message". И "кавычки" внутри экранируются \".)

        local items := JSON.Stringify(JSON.Stringify(this.itemsToHtml))

        this.wv.ExecuteScript("fromAhkMain(" items ")", false)

        config.isTrial := false
        try {
          Tray.Delete("Re&gister")
        } catch as e {

        }

      } else {
        local message := message . " Request return false."
        throw Error(message, -1)
      }
    } catch as e {
      local messageObj := {}
      messageObj.message := e.Message
      local items := JSON.Stringify(JSON.Stringify(messageObj))
      ; MsgBox "items = " items
      this.wv.ExecuteScript("fromAhkMain(" . items . ")", false)
    }

  }

}



