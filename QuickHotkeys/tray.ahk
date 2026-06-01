
#Include ./Tray/SettingsWindow/SettingsWindow.ahk
; #Include ./../Lib/Utils.ahk
#Include ./Tray/FixVideoWindow/FixVideoWindow.ahk
#Include ./Tray/SetThumbnailWindow/SetThumbnailWindow.ahk
#Include ./../Lib/Ffmpeg.ahk

#Include ./Tray/RegisterWindow/RegisterWindowHtml.ahk
#Include ../Lib/GumroadRequest.ahk
#Include ./Tray/AboutWindow/AboutWindow.ahk

; Текст подсказка в трее у программы, которая появляется
; при наведении мышии.
A_IconTip := config.appName

; NoStandard - отключает стандартное контекст меню.
global Tray := A_TrayMenu
; Убираем все дэфаулт меню.
Tray.Delete()
; Добавляем элементы меню:
Tray.Add("&About/Help", ContextMenu)
if (config.isTrial) {
  Tray.Add("Re&gister", ContextMenu)
}

Tray.Add("Remember Window Size", ContextMenu)
Tray.Add("Set Thumbnail for Video", ContextMenu)
Tray.Add("&Fix Video File", ContextMenu)
Tray.Add("&Settings", ContextMenu)
; Добавляет линию
Tray.Add()
Tray.Add("&Reload", ContextMenu)
Tray.Add("&Pause", ContextMenu)
Tray.Add("E&xit", ContextMenu)

; Картинка программы в трее.
TraySetIcon("icons/logo.ico")
; Картинки слева у элементов меню:
; https://icon-icons.com/icon/play-normal/26969
; Нужно указать отрицательное число: D:\Images\icons\W11_icon_files\shell32-icons
Tray.SetIcon("&About/Help", "Shell32.dll", "-263")
; Tray.SetIcon("Re&gister", "Shell32.dll", "-194")
if (config.isTrial) {
  Tray.SetIcon("Re&gister", "Shell32.dll", "-194")
}

; Tray.SetIcon("Remember Window Size", "Shell32.dll", "-160")
; Tray.SetIcon("Remember Window Size", "icons/size_icon_1.ico")
Tray.SetIcon("Remember Window Size", "icons/size_maximize_icon.ico")

Tray.SetIcon("Set Thumbnail for Video", "Shell32.dll", "-224")
Tray.SetIcon("&Fix Video File", "icons/fix.ico")
Tray.SetIcon("&Settings", "Shell32.dll", "-62999")
Tray.SetIcon("&Reload", "Shell32.dll", "-16739")
Tray.SetIcon("&Pause", "icons/Pause.ico")
Tray.SetIcon("E&xit", "Shell32.dll", "-240")

/**
 * Возвращает массив путей к выбранным файлам, или false если ни чего не выбрано.
 * @returns {Array} 
 */
getSelectedFilesFromFileExplorer() {
  local hwnd := WinGetID("ahk_class CabinetWClass")
  if(!hwnd){
    MsgBox "You need to select the file in the File Explorer window first."
    return false
  }
  WinActivate(hwnd)
  Sleep(100)
  local selectedFiles := Utils.Explorer_GetSelection(hwnd)
  if (selectedFiles == "") {
    MsgBox "No files are selected in the File Explorer window. You need to select the file in the File Explorer window first."
    return false
  }
  ; Массив выбранных файлов.
  local selectedFiles := StrSplit(selectedFiles, "`n")

  local selectedFilesClean := []
  for k, selectedFile in selectedFiles{
    ; Убираем кавычки в начале и в конце строки.
    selectedFile := RegExReplace(selectedFile, '(?<=^)[\" ]+|[\" ]+(?:$)', "")
    if(selectedFile != ""){
      selectedFilesClean.Push(selectedFile)
    }
    ; MsgBox selectedFile
  }

  return selectedFilesClean
}


; /**
;  * Возвращает массив выбранных файлов, или false если ни чего не выбрано.
;  * @returns {Array} 
;  */
; getSelectedFilesFromFileExplorer() {
;   local bak := A_Clipboard
;   A_Clipboard := ""
;   local HWND := getLastActiveWindow()
;   WinActivate(HWND)
;   Sleep(100)
;   Send "^+{c}"
;   ClipWait 0
;   ; Send "{c Up}{Ctrl Up}{Shift Up}"
;   ; Send "{F5}"
;   Sleep 100
;   ; Массив выбранных файлов.
;   local selectedFiles := StrSplit(A_Clipboard, "`n")

;   A_Clipboard := bak

;   if(selectedFiles.Length == 0){
;     MsgBox "No files selected"
;     return false
;   }

;   ; Send "{Right}{Right}"
;   ; Sleep 2000

;   ; Убираем кавычки с краёв, и проверяем что в клипборде, путь к файлу или нет.
;   local testVideo := RegExReplace(selectedFiles[1], '^[\" ]+|[\" ]+$', "")
;   local isPath := RegExMatch(testVideo, "^[a-zA-Z]\:")
;   if(!isPath){
;     MsgBox "No files selected"
;     return false
;   }

;   local selectedFilesClean := []
;   for k, selectedFile in selectedFiles{
;     selectedFile := RegExReplace(selectedFile, '(?<=^)[\" ]+|[\" ]+(?:$)', "")
;     selectedFilesClean.Push(selectedFile)
;   }
;   return selectedFilesClean
; }

; --------------------------------------------------------------------------
; Меню в трее
; https://www.autohotkey.com/docs/v2/lib/Menu.htm#Add
ContextMenu(A_ThisMenuItem, *) {

  global gumroadOptions, config, LicenseTrialQH

  if (A_ThisMenuItem = "&About/Help") {
    AboutWindow(config)
    return
  }

; Если платная, раскомментировать
  ; if (A_ThisMenuItem == "Re&gister") {
  ;   local GumReq := GumroadRequest(gumroadOptions)
  ;   RegisterWindowHtml(GumReq, LicenseTrialQH, config)
  ;   return
  ; }

  if (A_ThisMenuItem == "Remember Window Size") {
    ; Not found.
    ; WinGetID("A")
    try{
      ; Первое окно в списке - это tray.
      ; Активируем предыдущее окно.
      WinActivate("ahk_id " . WinGetList()[2])
    }
    global rememberWindowsSizes_
    rememberWindowsSizes_.openGui()
  }

  ; global config, gumroadOptions, License_TrialKeyboard
  if (A_ThisMenuItem == "Set Thumbnail for Video") {
    local selectedFile := ""
    local selectedFiles := getSelectedFilesFromFileExplorer()
    if (selectedFiles != false) {
      selectedFile := selectedFiles[1]
    }
    local SetThumbWin := SetThumbnailWindow()
    SetThumbWin.run(selectedFile)
  }

  if (A_ThisMenuItem == "&Fix Video File") {
    local selectedFiles := getSelectedFilesFromFileExplorer()
    if(selectedFiles == false){
      return
    }
    local FixVideoWin := FixVideoWindow()
    FixVideoWin.run(selectedFiles)

    pageLoaded(*) {
      for selectedFile in selectedFiles {
        local fileObj := {
          path: selectedFile,
          status: "loading"
        }
        local fileObjStr := JSON.stringify(JSON.stringify(fileObj))
        ; Когда окно закрыто, то FixVideoWin.wv = 0.
        if (FixVideoWin.wv) {
          FixVideoWin.wv.ExecuteScript('fromAhk_setFileStatus(' . fileObjStr . ')', false)
        } else {
          return
        }
        ; Sleep(2000)
        local result := Ffmpeg.fixVideoAuto(selectedFile)
        if (result == 0) {
          fileObj := {
            path: selectedFile,
            status: 1
          }
        } else {
          fileObj := {
            path: selectedFile,
            status: "error"
          }
        }
        fileObjStr := JSON.Stringify(JSON.Stringify(fileObj))
        if (FixVideoWin.wv) {
          FixVideoWin.wv.ExecuteScript('fromAhk_setFileStatus(' . fileObjStr . ')', false)
        } else {
          return
        }
      }
      Sleep(1000)
      FixVideoWin.close()
    }

    FixVideoWin.loaded(pageLoaded)
    ; Sleep(1600)
  }

  if (A_ThisMenuItem == "&Settings") {
    ; MsgBox "&Settings"
    SettingsWindow()
    return
  }


  ; Нажато остановить скрипт
  if (A_ThisMenuItem = "&Pause") {
    Suspend 1
    Pause 1
    ; Icon для скрипта
    ; Третий аргумент - 1 - чтобы картитнка не заменялдась на Ahk pause
    ; карнтитнку.
    TraySetIcon("icons/logo-stoped.ico", , 1)
    ; Меняем текст элемента
    Tray.Rename("&Pause", "&Play")
    ; Icon для элемента меню
    Tray.SetIcon("&Play", "icons/Play.ico")
    onPauseCallback()
    return
  }

  ; Нажато играть скрипт
  if (A_ThisMenuItem = "&Play") {
    Suspend 0
    Pause 0
    ; Icon для скрипта
    ; Третий аргумент - 1 - чтобы картитнка не заменялдась на Ahk pause
    ; карнтитнку.
    TraySetIcon("icons/logo.ico", , 1)
    Tray.Rename("&Play", "&Pause")
    Tray.SetIcon("&Pause", "icons/Pause.ico")
    onPlayCallback()
    return
  }

  if (A_ThisMenuItem = "&Reload") {
    Reload()
    return
  }

  ; Закрыть скрипт
  if (A_ThisMenuItem = "E&xit") {
    ExitApp()
    return
  }

}


