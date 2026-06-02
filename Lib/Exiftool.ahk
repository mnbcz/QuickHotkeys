
class Exiftool{
  static exiftoolPath := A_ScriptDir . '\bin\exiftool.exe'

  /**
   * Удаляет картинку thumbnail у видео, и возвращает к исходной.
   * @param video 
   * @returns {Integer} 
   */
  static removePreview(video){
    local execCommand := '"' . Exiftool.exiftoolPath . '" -overwrite_original -Preview:All= "' . video . '"'
    local runReturn := RunWait(execCommand, , "Hide")
    return runReturn
  }

  /**
   * Копирует все метаданные из одного файла в другой.
   * Оценки, тэги, ...
   * Если успешно, возвращает 0.
   * @param videoFrom 
   * @param videoTo 
   * @returns {Integer} 
   */
  static copyAllMetadata(videoWhereGetTags, videoWhereAddTags){
    ; local execCommand := '"' . this.exiftoolPath . '" -TagsFromFile "' . videoFrom . '" "-all:all>all:all" "' . videoTo . '"'
    local execCommand := '"' . Exiftool.exiftoolPath . '" -overwrite_original -TagsFromFile "' . videoWhereGetTags . '" -all:all "' . videoWhereAddTags . '"'
    ; MsgBox execCommand
    local runReturn := RunWait(execCommand, , "Hide")
    return runReturn
  }

}





