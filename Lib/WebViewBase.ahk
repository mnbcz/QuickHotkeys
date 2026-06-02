
; Test
; #Include ..\Lib\ahk2_lib\WebView2\WebView2.ahk

class WebViewBase{

    wvc := {}
    wv := {}
    win := {}
    ; Окно было закрыто?
    isClose := false


    __New() {

        ; MsgBox "WebViewBase __New"

        ; Extended styles: 
        ; https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
        ; В начало нужно добавить E, и L не нужно указывать.
        ; Например: -E0x00000200.
        ; -0xFF0092 - Make square window.
        ; win := Gui('+Resize')
        this.win := Gui('+Resize')
        this.win.MarginX := this.win.MarginY := 0
        this.win.Title := ""

        ; Вызывается при закрытии окна.
        ; Можно отменить закрытие вернув 1.
        ; win.OnEvent('Close', (*) => (wvc := wv := 0))
        ; this.win.OnEvent('Close', (thisGui) => this.close(thisGui))
        this.win.OnEvent('Close', (*) => this.close())

        ; Вызывается когда изменяются размеры окна
        this.win.OnEvent('Size', (GuiObj, MinMax, Width, Height) => this.guiChangeSize(GuiObj, MinMax, Width, Height))

        ; Убираем картинку у заголовка окна.
        ; this.win.Opt("LastFound")
        ; DllCall("uxtheme\SetWindowThemeAttribute", "ptr", WinExist()
        ; , "int", 1, "int64*", 6 | 6<<32, "uint", 8)

    }


    ; Вызывается когда изменяются размеры окна.
    guiChangeSize(GuiObj, MinMax, Width, Height) {
        if (MinMax != -1) {
            ; Перерисовывает содержимое окна.
            ; Оно не перерисовывается автоматически при изменении размеров окна.
            try this.wvc.Fill()
        }
    }


    ; Отображает окно, и устанавливает настройки для WebView.
    init(dimension := 'y40 x200 w700 h630'){

        global config

        ; MsgBox "init"

        ; https://www.autohotkey.com/docs/v2/lib/Gui.htm#Show
        ; Отображает окно.
        this.win.Show(dimension)

        local userDataDir := config.appDataDir . "\WebViewUserData"
        ; Это обязательно должно быть после win.Show()
        ; WebView2.create(hwnd,,,,,{AdditionalBrowserArguments:'--remote-debugging-port=9222'})
        this.wvc := WebView2.create(this.win.Hwnd, , , userDataDir, , {AdditionalBrowserArguments:'--disable-web-security=true --allow-file-access-from-files=true --allow-file-access=true --allow-file-access=true --enable-features=msWebView2EnableDraggableRegions'})

        ; Установка прозрачности фона окна.
        ; https://www.autohotkey.com/boards/viewtopic.php?style=17&f=83&t=95666&start=100
        this.wvc.DefaultBackgroundColor := 0x000000

        this.wv := this.wvc.CoreWebView2


        this.AddHostObjectToScript()

        ; Добавляем обработчик который вызывается после загрузки страницы.
        ; https://www.autohotkey.com/boards/viewtopic.php?f=83&t=95666&start=120
        ; this.wv.add_NavigationCompleted(WebView2.Handler((handler, ICoreWebView2, NavigationCompletedEventArgs) => this.NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs)))

        this.wv.add_NavigationCompleted(WebView2.Handler(this.NavigationCompleteHandler))


        ; this.wv.add_NavigationCompleted(WebView2.Handler( this.NavigationCompleteHandler ))

        if IsSet(config) && config.HasOwnProp("AreDevToolsEnabled") {
            ; Отключение DevTools
            this.wv.Settings.AreDevToolsEnabled := config.AreDevToolsEnabled
        }


        if IsSet(config) && config.HasOwnProp("AreDefaultContextMenusEnabled") {
            ; Отключение меню правого клика
            this.wv.Settings.AreDefaultContextMenusEnabled := config.AreDefaultContextMenusEnabled
        }

        ; this.wv.Settings.DefaultBackgroundColor := "#EEAA99"
        ; this.wv.DefaultBackgroundColor := "#EEAA99"
        ; this.wv.DefaultBackgroundColor := 0x00000111


    }


    ; Загружает html.
    navigate(url){
        ; Загружаем html
        this.wv.Navigate(url)

        ; Test
        ; Updater.wv.Navigate('file:///' . A_ScriptDir . '/checkUpdate.html')

        ; this.wv.NavigateToString()
    }


    ; Обработчик который вызывается после загрузки страницы.
    NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs){
        ; MsgBox "Loaded=" this
        ; this.wv.ExecuteScript('document.getElementById("whatChanges").href = "' . currentVersionFromGit.Get("html_url", "") . '"', false)

    }



    AddHostObjectToScript(eventHandlers := {}){


        local defaultEvents := {
            hrefClick: (href) => this.hrefClick(href),
            close: () => this.close()
            ; autoHeight: (height) => this.autoHeight(height),
            ; ; dragTitleBar: () => dragTitleBar(main.Hwnd)
        }

        local events := Utils.mergeObjects(defaultEvents, eventHandlers)

        ; if(Type(this) == "AboutWindow"){
        ;     for k, v in events.OwnProps(){
        ;         MsgBox k
        ;     }
        ; }

        ; Передаём странице html имя ahk, и хост свойства (HostProperty).
        this.wv.AddHostObjectToScript('ahk', events)
    }


    hrefClick(href){
        ; MsgBox "href = " href  
        Run href
    }


    ; Вызывается при закрытии окна.
    close(){
        ; Обнуляем WebView
        this.wvc := 0
        this.wv := 0
        this.win.Destroy()
        this.isClose := true
        ; MsgBox "WV Base close()"
        ; Можно отменить закрытие вернув 1.
        ; return 1
    }


    autoHeight(height){
        this.win.Show('y40 w700' . ' h' . height + 30)
    }


}



; WV := WebViewBase()
; WV.init()
; WV.navigate('file:///' . A_ScriptDir . '/Test.html')


