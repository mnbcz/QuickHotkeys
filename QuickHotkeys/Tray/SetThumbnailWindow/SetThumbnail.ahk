#Include ../../../Lib/Exiftool.ahk
#Include ../../../Lib/Ffmpeg.ahk
#Include ../../../Lib/AtomicParsley.ahk


class SetThumbnail{

  /**
   * Устанавливает картинку у файла видео.
   * И копирует метаданные из прежднего файла.
   * @param video - путь к видео, куда нужно установить картинку.
   * @param thumbnail - путь к картинке.
   * @return 0 - если успешно.
   */
  _setThumbnail_viaFfmpeg(video, thumbnail){
    SplitPath video, , &dir, &ext, &name_no_ext
    ; Видео с установленной картинкой
    local outVideo := dir . "\" . name_no_ext . "_" . Random(10000, 100000) . '.' . ext
    local runReturn := Ffmpeg.setThumbnail(video, thumbnail, outVideo)
    ; MsgBox "setThumbnail command = " . runReturn
    if(runReturn == 0){
      ; Команда успешна.
      ; Копируем мета тэги.
      Exiftool.copyAllMetadata(video, outVideo)
      try{
        FileDelete video
      }catch as err{
        MsgBox err.Message
      }
      try{
        ; Rename from to
        FileMove outVideo, video
      }catch as err{
        MsgBox err.Message
      }
    }
    return runReturn

  }

  /**
   * Устанавливает картинку из файла картинки.
   * @param selectedFile 
   * @param thumbnailPath 
   */
  setThumbnailFromImage_viaFfmpeg(selectedFile, thumbnailPath){
    ; Это не работает на испорченных файлах.
    local fileIsCorrupt := Ffmpeg.fileIsCorrupt(selectedFile)
    if(fileIsCorrupt){
      ; Картинка скорее всего не была установлена раньше.
      ; Не нужно удалять картинку.
      ; Устанавливаем у файла новую картинку.
      ; local fixVideo_ := fixVideo(selectedFile)
      ; if(fixVideo_ == 0){        
        local retSetThumbnail := this._setThumbnail_viaFfmpeg(selectedFile, thumbnailPath)
        ; MsgBox "setThumbnail() = " . retSetThumbnail
        return retSetThumbnail

    }else{
      ; Возможно картинка уже установлена.
      ; Убираем прежднюю картинку.
      ; Это не устанавливает картинку на уже установленную.
      if(Exiftool.removePreview(selectedFile) == 0){
        ; Устанавливаем у файла новую картинку
        local retSetThumbnail := this._setThumbnail_viaFfmpeg(selectedFile, thumbnailPath)
        MsgBox "setThumbnail() = " retSetThumbnail
        return retSetThumbnail
      }
    }
  }

  ; Устанавливает картинку дял mp4 файлов.
  ; Удаляет прежднюю сначала.
  _setThumbnail_viaAtomicParsley(video, thumbnail){
    ; Возможно картинка уже установлена.
    ; Убираем прежднюю картинку.
    ; Это не устанавливает картинку на уже установленную.
    local deleteThumbnailRet := AtomicParsley.deleteThumbnail(video)
    if(deleteThumbnailRet != 0) {
      MsgBox "Cannot delete thumbnail. Error: " . deleteThumbnailRet
    }

    local setThumbnailRet := AtomicParsley.setThumbnail(video, thumbnail)
    if(setThumbnailRet != 0) {
      MsgBox "Failed to set thumbnail. Error: " . setThumbnailRet
      return false
    }
    return true
  }


  setThumbnail(video, thumbnail){
    ; MsgBox "setThumbnail()"

    ; Проверить расширение видео. Если это не mp4, то вернуть ошибку.
    ; Проверить не испорчен ли файл.
    ; Это не работает на испорченных файлах.
    ; Если испорчен, исправить.
    ; Удалить прежднюю картинку.
    ; Установить картинку.
    ; Копировать дату из исходного видео и установить к видео.

    ; SplitPath FullFileName, &name, &dir, &ext, &name_no_ext, &drive
    SplitPath video, , &dir, &ext, &name_no_ext

    ; Расширения которые поддерживаются
    local supportExtMap := Map()
    supportExtMap.Set("mp4", "")

    if(!supportExtMap.Has(ext)){
      MsgBox "This extension " . ext . " is not supported. Try mp4."
      return false
    }

    ; Атрибуты даты видео
    local dateModifiedVideo := FileGetTime(video, "M")
    local dateCreatedVideo := FileGetTime(video, "C")
    local dateLastAccessVideo := FileGetTime(video, "A")

    local fileIsCorrupt := Ffmpeg.fileIsCorrupt(video)
    ; Исправляем видео.
    if(fileIsCorrupt){
      ; Исправленное видео.
      local videoRepaired := dir . "\" . name_no_ext . "_repaired" . "." . ext

      local fixVideoRet := Ffmpeg.fixVideo(video, videoRepaired)
      if(fixVideoRet != 0) {
        MsgBox "Failed to fix video. Error: " . fixVideoRet
        return false
      }

      ; Копируем мета тэги.
      local copyAllMetadataRet := Exiftool.copyAllMetadata(video, videoRepaired)
      if(copyAllMetadataRet != 0) {
        MsgBox "Metadata cannot be copied. Error: " . copyAllMetadataRet
      }

      ; Удаляем прежднее видео, и заменяем исправленным.
      try{
        FileSetAttrib "-R", video
        FileDelete video
        FileMove videoRepaired, video
      }catch as err{
        MsgBox err.Message
      }
    }

    ; video - исходное видео, или исправленное.

    if(ext == "mp4"){
      this._setThumbnail_viaAtomicParsley(video, thumbnail)
    }else{
      MsgBox "This extension " . ext . " is not supported. Try mp4."
      return false
    }

    FileSetTime dateModifiedVideo, video, "M"
    FileSetTime dateCreatedVideo, video, "C"
    FileSetTime dateLastAccessVideo, video, "A"
    
  }



}

