
class Ffmpeg{
  static ffmpegPath := A_ScriptDir . '\bin\ffmpeg.exe'

 /**
   * Устанавливает картинку у файла видео.
   * Но у полученного видео стираются метаданные.
   * @param video - путь к видео, куда нужно установить картинку.
   * @param thumbnail - путь к картинке.
   * @return 0 - если успешно.
   */
  static setThumbnail(video, thumbnail, outVideo){
    ;  -movflags +faststart
    local execCommand := '"' . Ffmpeg.ffmpegPath . '" -i "' . video . '" -i "' . thumbnail . '" -map 1 -map 0 -c copy -disposition:0 attached_pic "' . outVideo . '"'
    ; local exeCommand := '"' . this.ffmpegPath . '" -i "' . video . '" -i "' . thumbnail . '" -map 1 -map 0 -c copy -map_metadata 0 -map_metadata:s:v 0:s:v -map_metadata:s:a 0:s:a -disposition:0 attached_pic "' . outVideo . '"'
    ; Устанавливаем картинку
    local runReturn := RunWait(execCommand, , "Hide")
    ; MsgBox "setThumbnail command = " . runReturn
    return runReturn
  }

  
  /**
   * Файл испорчен?
   * @param selectedFile 
   * @returns {Integer} 
   */
  static fileIsCorrupt(selectedFile){

    ; SplitPath FullFileName, &name, &dir, &ext, &name_no_ext, &drive
    SplitPath selectedFile, , &dir, &ext, &name_no_ext
    local exeOutPath := dir . "\isCorruptOut.txt"
    /**
     * Выполняет команду проверки испорчен ли файл, или нет.
     * Испорчен - если нельзя установить оценку.
     * Возвращает true, если испорчен.
     * @returns {Integer} 
     */
    testIsCorrupt(){
      ; local exeStr := '"' . A_ScriptDir . '\bin\ffmpeg.exe' . '" -i "' . selectedFile . '" > "' . exeOutPath . '" 2>&1'
      local exeStr := '"' . Ffmpeg.ffmpegPath . '" -i "' . selectedFile . '" > "' . exeOutPath . '" 2>&1'
      ; Hide - не отображать окно терминала.
      ; A_ComSpec - путь к cmd.exe
      ; /c - аргумент cmd.exe - выполнить, и выйти.
      exeStr := A_ComSpec . ' /c "' . exeStr . '"'
      ; Hide - не отображать окно терминала.
      RunWait(exeStr, , "Hide")

      local textFromOutFile := ConfigReader.getRaw(exeOutPath)
      if(textFromOutFile == false) {
        return true
      }
      local match := RegExMatch(textFromOutFile, "start: (\d+\.\d+)", &matchGroup)
      if(match != 0){
        if(matchGroup[1] < 0.06){
          ; start: 0.000000
          return false
        }else{
          return true
        }
      }else{
        ; start: 0.000000 - не найдено.
        return true
      }

    }

    local testIsCorruptRet := testIsCorrupt()
    try{
      FileDelete exeOutPath
    }catch as err{
      MsgBox "Cannot delete file." . err.Message
    }
    return testIsCorruptRet

  }


  /**
   * Исправляет видео, и сохраняет исправленное видео в файл outVideo.
   * @param video
   * @param outVideo
   * @returns {Integer} Если возвращено 0, то значит успешно.
   * Если 1, то не успешно.
   */
  static fixVideo(video, outVideo){
    ; MsgBox outPath
    ; Hide - не отображать окно терминала.
    local runReturn := RunWait('"' . Ffmpeg.ffmpegPath . '" -i "' . video . '" -c copy "' . outVideo . '"', , "Hide")
    return runReturn
  }

/**
 * Исправляет видео, и сохраняет исправленный файл в этот же каталог,
 * и удаляет прежднее.
 * @param video Path to video.
 * @returns {Integer} Если возвращено 0, то значит успешно.
 * Если 1, то не успешно.
 */
static fixVideoAuto(video){
  ; Sleep 1000
  ; video := RegExReplace(video, '^[\" ]+|[\" ]+$', "")
  video := RegExReplace(video, '(?<=^)[\" ]+|[\" ]+(?:$)', "")
  if(video == ""){
    return
  }
  ; MsgBox video
  ; SplitPath FullFileName, &name, &dir, &ext, &name_no_ext, &drive
  SplitPath video, , &dir, &ext, &name_no_ext
  ; Если расширение не mkv, то конвертируем в mp4
  if(ext != "mkv"){
    ext := "mp4"
  }
  local outPath := dir . "\" . name_no_ext . "_" . Random(10000, 100000) . "." . ext
  local newVideoPath := dir . "\" . name_no_ext . "." . ext
  ; MsgBox outPath
  ; Hide - не отображать окно терминала.
  local command := '"' . Ffmpeg.ffmpegPath . '" -err_detect ignore_err -i "' . video . '" -c copy "' . outPath . '"'
  ; MsgBox "command = " . command
  local runReturn := 1
  try{
    runReturn := RunWait(command, , "Hide")
    ; runReturn := RunWait(command)
  }catch as err{
    MsgBox "RunWait error: " . err.Message
  }
  if(runReturn == 0){
    try{
      FileSetAttrib "-R", video
      FileDelete video
      FileMove outPath, newVideoPath
    }catch as err{
      MsgBox "Delete error: " . err.Message . ", video = " . video
    }
  }else{
    Sleep 400
    try{
      FileDelete outPath
    }catch as err{
      ; MsgBox "Delete error: " . err.Message . ", outPath: " . outPath
    }
  }
  ; MsgBox "runReturn = " . runReturn
  return runReturn
}


  ; Сохраняет картинку из видео, в том же каталоге что и видео, 
  ; и возвращает путь к этой картинке.
  static getImage(video, time){
    SplitPath video, , &dir, &ext, &name_no_ext
    local image := dir . "\" . name_no_ext . "_" . Random(1, 10000) . ".jpg"
    local runReturn := RunWait('"' . Ffmpeg.ffmpegPath . '" -ss "' . time . '" -i "' . video . '" -frames:v 1 "' . image . '"', , "Hide")
    if(runReturn != 0){
      MsgBox "Cannot create image from video. Error: " . runReturn
      return false
    }
    return image
  }

}


