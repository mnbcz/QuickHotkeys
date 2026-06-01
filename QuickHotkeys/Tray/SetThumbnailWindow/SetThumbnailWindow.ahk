; #Include ../../../Lib/WebViewBase.ahk
#Include ../../../Lib/Utils.ahk
#Include SetThumbnail.ahk
#Include ../../../Lib/Ffmpeg.ahk

class SetThumbnailWindow extends WebViewBase {
  ; static loadedCallback := {}
  ; Путь к выбранному файлу видео.
  video := ""

  __New() {
    global config, Modules
    super.__New()
    ; this.win.Title :=  config.appName " - Fix Video"
    this.win.Title := "Set thumbnail for Video"
    ; this.win.Opt("-MaximizeBox +ToolWindow -0xCF0000")
  }

  /**
   * Открывает окно с формой выбора файла картинки, с кнопкой ОК.
   * Когда кнопка нажимается, устанавливается картинка к файлу.
   * @param video Path to video.
   */
  run(video) {
    this.video := video
    local eventHandlers := {
      timeValueCallback: (video, timeValue) => this.timeValueCallback(video, timeValue),
      selectedFile: video,
      selectFile: () => this.selectFile()
    }
    this.init('y40 w1040 h600')
    this.AddHostObjectToScript(eventHandlers)
    ; this.win.BackColor := "ffffff"
    this.navigate(A_ScriptDir . '\Tray\SetThumbnailWindow\SetThumbnail.html')
  }

  ; Устанавливаем функцию колбэк, которая будет вызываться,
  ; после загрузки страницы.
  ; loaded(loadedCallback){
  ;     FixVideoWindow.loadedCallback := loadedCallback
  ; }

  ; Обработчик который вызывается после загрузки страницы.
  NavigationCompleteHandler(handler, ICoreWebView2, NavigationCompletedEventArgs) {
    ; this здесь не существует, это номер окна, int.
    ; Поэтому используется статический метод.
    ; FixVideoWindow.loadedCallback()
  }

  /**
   * Вызывается из html, и передаёт значение времени, или пути к файлу.
   * @param video Path to video.
   * @param timeValue Path to thumbnail, or time of thumbnail.
   */
  timeValueCallback(video, timeValue) {
    timeValue := RegExReplace(timeValue, '^[\" ]+|[\" ]+$', "")
    video := RegExReplace(video, '^[\" ]+|[\" ]+$', "")

    ; Это путь к thumbnail?, или время
    local isPath := RegExMatch(timeValue, "^[a-zA-Z]\:")
    ; Класс SetThumbnail
    local thumb := SetThumbnail()
    try {
      if (isPath) {
        ; В поле указан путь к файлу.
        thumb.setThumbnail(video, timeValue)
      } else {
        ; В поле указано время.
        ; MsgBox "Time"
        local pathToImage := Ffmpeg.getImage(video, timeValue)
        if (pathToImage != false) {
          ; MsgBox pathToImage
          thumb.setThumbnail(video, pathToImage)
          try {
            FileDelete pathToImage
          } catch as err {
            MsgBox err.Message
          }
        }
      }
      Sleep(1000)
      this.close()
    } catch as err {
      return err.Message
    }
  }

  /**
   * Открывает окно Windows выбора файла.
   * @returns {String | Array} Возвращает путь к выбранному файлу.
   */
  selectFile() {
    ; SelectedFile := FileSelect(3, , "Open a file", "Text Documents (*.txt; *.doc)")
    local selectedFile := FileSelect(3, , "Open a file")
    return selectedFile
  }

  ; Вызывается при закрытии окна.
  close() {
    super.close()
  }

}










