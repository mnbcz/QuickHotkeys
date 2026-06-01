; #Include ../../../Lib/WebViewBase.ahk
#Include ../../../Lib/Utils.ahk


class FixVideoWindow extends WebViewBase{

    static loadedCallback := {}

    __New() {        
        global config, Modules
        super.__New()
        ; this.win.Title :=  config.appName " - Fix Video"
        this.win.Title := "Fix Video"
        ; this.win.Opt("-MaximizeBox +ToolWindow -0xCF0000")
    }

    run(selectedFiles){
        local eventHandlers := {
            selectedFiles: JSON.Stringify(selectedFiles), 
        }
        this.init('y40 w1040 h600')
        this.AddHostObjectToScript(eventHandlers)
        ; this.win.BackColor := "ffffff"
        ; this.navigate('file:///' . A_ScriptDir . '\modules\Tray\SettingsWindow\SettingsWindow.html')
        this.navigate(A_ScriptDir . '\Tray\FixVideoWindow\FixVideoWindow.html')
    }

    ; Устанавливаем функцию колбэк, которая будет вызываться, 
    ; после загрузки страницы.
    loaded(loadedCallback){
        FixVideoWindow.loadedCallback := loadedCallback
    }

    ; Обработчик который вызывается после загрузки страницы.
    NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs){
        ; this здесь не существует, это номер окна, int.
        ; Поэтому используется статический метод.
        FixVideoWindow.loadedCallback()
    }
    
    ; Вызывается при закрытии окна.
    close(){
        super.close()
    }

}










