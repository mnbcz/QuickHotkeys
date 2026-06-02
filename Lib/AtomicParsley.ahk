
class AtomicParsley{

  static programPath := A_ScriptDir . '\bin\AtomicParsley.exe'

  /**
   * Устанавливает картинку у видео.
   * @param video 
   * @param thumbnail 
   * @returns {Integer} 
   */
  static setThumbnail(video, thumbnail){
    local execCommand := '"' . AtomicParsley.programPath . '" "' . video . '" --artwork "' . thumbnail . '" --overWrite'
    local runReturn := RunWait(execCommand, , "Hide")
    return runReturn
  }

  static deleteThumbnail(video){
    local execCommand := '"' . AtomicParsley.programPath . '" "' . video . '" --artwork REMOVE_ALL --overWrite    '
    local runReturn := RunWait(execCommand, , "Hide")
    return runReturn
  }

}



