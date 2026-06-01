
; For test
; #Include ..\..\..\QuickHotkeys.ahk

class AboutWindow extends WebViewBase {

  itemsToHtml := {}

  __New(itemsToHtml := {}) {
    global config
    ; MsgBox "AboutWindow __New"
    if (ObjOwnPropCount(itemsToHtml) > 0) {
      this.itemsToHtml := itemsToHtml
      ; MsgBox this.itemsToHtml.appName
    }
    super.__New()
    local title := config.appName " - About"
    this.win.Title := title
    this.win.Opt("-MaximizeBox +ToolWindow -0xCF0000")
    this.win.BackColor := "ffffff"

    this.init('y120 w840 h310')
    this.navigate('file:///' . A_ScriptDir . '\Tray\AboutWindow\AboutWindow.html')
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

}










