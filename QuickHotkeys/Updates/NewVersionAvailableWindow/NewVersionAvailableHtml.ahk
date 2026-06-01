

; Этот класс должен принимать другие классы, которые должны
; реализовывать методы:
; this.License.createLicenseInRegistry(key)
; this.Request.checkKey(key)
class NewVersionAvailableHtml extends WebViewBase {

  itemsToHtml := {}

  __New(itemsToHtml := {}) {

    global config

    if (ObjOwnPropCount(itemsToHtml) > 0) {
      this.itemsToHtml := itemsToHtml
    }

    super.__New()

    local title := config.appName " - New Version Available"

    this.win.Title := title
    this.win.Opt("-MaximizeBox +ToolWindow -0xCF0000")
    this.win.BackColor := "ffffff"

    this.init('y120 w700 h240')
    ; this.win.BackColor := "ffffff"
    this.navigate("file:///" . A_ScriptDir . "\Updates\NewVersionAvailableWindow\index.html")
    WinSetTransparent 240, title

  }

  ; Добавляем методы для страницы Html
  AddHostObjectToScript() {

    local itemsToHtml := JSON.Stringify(this.itemsToHtml)

    local eventHandlers := {
      items: itemsToHtml
    }

    ; Call method in base class.
    super.AddHostObjectToScript(eventHandlers)

  }


  ; Обработчик который вызывается после загрузки страницы.
  ; NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs){

  ; }


}



