
; QuickHotkeys.ahk

try{

; Директивы скрипта 
#Include directives.ahk
; Конфиг приложения
#Include configs\config.ahk

; Libs:
#Include ../Lib/Debug.ahk
#Include ../Lib/Wheel.ahk
global Wheel_ := Wheel()

; JSON2 - чтобы не было ошибок при возврате из функции в ahk, к html
; Используется JSON2, а не встроенный JSON
#Include ../Lib/ahk2_lib/JSON.ahk
#Include ../Lib/Utils.ahk
#Include ../Lib/VectorsDegree.ahk
#Include ../Lib/FileSystem.ahk
#Include ../Lib/ConfigReader.ahk
; Encrypt
#Include ../Lib/AHK_CNG/src/Class_CNG.ahk
#Include ../Lib/ahk2_lib/WebView2/WebView2.ahk
#Include ../Lib/WebViewBase.ahk
#Include ./../Lib/SetSystemCursor.ahk

; #Include ../Lib/ModifiersKeyWait.ahk
#Include ./variables.ahk
#Include ./functions.ahk

if(!FileExist(config.Data.dataPath)){
  ; Создаём файл data.json если этого файла ещё не существует. 
  ; Это первый старт программы.
  global dataJson := {
      versionFromData: config.currentVersion
  }
  ConfigReader.set(dataJson, config.Data.dataPath)
}

; Проверка лицензии
; #Include ./License/checkLicense.ahk

#Include ./Modules/Hotkeys.ahk
#Include ./Modules/HotkeyAliases.ahk
#Include ./Modules/HotkeyDisabled.ahk
; ; Порядок объявления имеет значение
; class Modules{
;     ; Загружаем хоткеи из файла, и устанавливаем в Hotkey()
;     static Hotkeys := Hotkeys()
; }

; Должны быть определены выше Hotkeys():

#Include ./lib/HotStrings.ahk
global hotStrings_ := HotStrings()

#Include ./lib/HideTaskbar.ahk
global hideTaskbar_ := HideTaskbar()
; Вызывается при закрытии программы.
OnExit onExitCallback 
; Вызывается при закрытии программы.
onExitCallback(ExitReason := "", ExitCode := ""){
  global hideTaskbar_
  hideTaskbar_.stopTrack()
}
; Вызывается при остановке программы.
onPauseCallback(){
  onExitCallback()
}
; Вызывается при старте программы (до этого скрипт был остановлен).
onPlayCallback(){
  global hideTaskbar_
  hideTaskbar_.startTrack()
}

#Include ./lib/RememberWindowsSizes.ahk
global rememberWindowsSizes_ := RememberWindowsSizes()

#Include ./HotkeyFunctions/stickyKeys.ahk
#Include ./Modules/Data.ahk
#Include ../Lib/Wheel2.ahk

global Modules := {}
; Загружаем данные из файла config, в переменную config.
Modules.Data := Data()

; Загружаем хоткеи из файла, и устанавливаем в Hotkey()
Modules.Hotkeys := Hotkeys()
Modules.Hotkeys.init()

Modules.HotkeyAliases := HotkeyAliases()
Modules.HotkeyAliases.init()

Modules.HotkeyDisabled := HotkeyDisabled()
Modules.HotkeyDisabled.init()



; MsgBox "hotkeyList.minimizeWindow = " . hotkeyList.minimizeWindow

; Modules:
; Должно следовать после #Include LicenseTrialKeyboard.ahk
#Include tray.ahk


; LWin::return

; https://www.autohotkey.com/boards/viewtopic.php?style=19&t=101812
; ~LWin::vkE8

; Alternatively:
; ~LWin::Send "{Blind}{vkE8}"

; 5B  15B	 	d	1.61	LWin  

; Hotkey("~vk5B", openWinBlock, "On")
; ; Hotkey("~LWin", openWinBlock, "On")

; openWinBlock(*){
;     BlockInput "On"
;     Send("{Blind}{vk07}")
;     BlockInput "Off"
; }

; Отключение одиночного нажатия Win и Alt
; vk5B:: ; ~LWin::
; Должно быть обязательно ~
; ~LWin::
; ; ~sc15B::
; ~vk5B::
; { 
;     ; MsgBox "T"
;     ; {vkE8}
;     BlockInput "On"
;     ; Send("{Blind}{vkE8}")
;     ; Send("{Blind}{vk07}{vkE8}{vkE8}{vk07}")
;     Send("{Blind}{vk07}")
;     BlockInput "Off"
;     ; Sleep 10
;     ; SendInput("{Blind}{vkE8}")
;     ; Нужно указать "{Blind}{vk07}", а то Win+V не будет работать, и клипборд
;     ; не будет открываться.
;     ; Send("{Blind}{vk07}")

;     ; MsgBox("Test")
;     ; modPress()
; } 

; ~LWin Up::
; {
;     ; Send("{Blind}{vk07}")
;     ; Send("{Blind}{vkE8}")
;     ; Send("{Blind}{vk07}")
;     ; return
; }


; vkA4 - LAlt
; ~LAlt::
; ~vkA4::
; { 
;     ; MsgBox "LAlt"
;     ; logF("LAlt")
;     ; Send("{Blind}{vkE8}")
;     Send("{Blind}{vk07}")
;     ; modPress()
;     ; modPressLabel()
; }


#Include ./HotkeyFunctions/linkClick.ahk
#Include ./HotkeyFunctions/closeTab.ahk
#Include ./HotkeyFunctions/closeWindow.ahk
#Include ./HotkeyFunctions/scroll.ahk
#Include ./HotkeyFunctions/scrollSelect.ahk
#Include ./HotkeyFunctions/HotkeyFunctions.ahk
#Include ./HotkeyFunctions/moveResizeWindow.ahk
#Include ./HotkeyFunctions/minMaxWindow.ahk
#Include ./HotkeyFunctions/RButtonAndWheel.ahk
#Include ./HotkeyFunctions/nextPreviousTabByWheel.ahk
#Include ./HotkeyFunctions/copy.ahk
#Include ./HotkeyFunctions/altTab.ahk
#Include ./HotkeyFunctions/FileExplorer.ahk
#Include ./HotkeyFunctions/setTransparency.ahk
#Include ./HotkeyFunctions/GoToStartEndLine.ahk
#Include ./HotkeyFunctions/activateLastWindows.ahk
#Include ./HotkeyFunctions/DeleteToStartLine.ahk
#Include ./HotkeyFunctions/DeleteToEndLine.ahk
#Include ./HotkeyFunctions/scrollHorizontal.ahk

#Include ./HotkeyFunctions/zoomByWheel.ahk
#Include ./HotkeyFunctions/minimizeBackWindows.ahk
#Include ./HotkeyFunctions/moveWindowByWheel.ahk
#Include ./HotkeyFunctions/exit-reload.ahk
#Include ./HotkeyFunctions/focusWindow.ahk

#Include ./HotkeyFunctions/HotGestures.ahk
#Include ./HotkeyFunctions/scrollTabsByRButtonWheel.ahk

#Include ./HotkeyFunctions/oneKeyFunctions.ahk
#Include ./HotkeyFunctions/autoReplaceWords.ahk

#Include ./HotkeyFunctions/hideTaskbar.ahk
#Include ./HotkeyFunctions/rememberWindowsSizes.ahk
#Include ./HotkeyFunctions/chromeCloseFullScreen.ahk


#Include ./lib/AltTabWindows.ahk
global _altTabWindows := AltTabWindows()

#Include ./lib/ListenWindows.ahk
global _listenWindows := ListenWindows()
_listenWindows.startListenMinimize()



; Проверка наличия новой версии.
#Include ./Updates/Update.ahk
; Требует уже установленные:
; Modules.Data
Update().check()

}catch as err{
  
}

