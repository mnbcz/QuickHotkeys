

class ConfigReader {

  ; Возвращает Map из config json файла.
  ; Если isObj = true, то возвращает json, не map.
  ; fileName - path to json file.
  ; Return - map, or json object, or false если файл не существует, или ошибочен.
  static get(fileName, isObj := false) {

    try {
      local config := FileRead(fileName)
      if (!config) {
        throw Error("Common config file not exists", -1)
      }

      if (isObj) {
        return JSON.Parse(config, true, false)
      } else {
        return JSON.Parse(config)
      }

    } catch as e {
      ; Common config file не существует, или json ошибочный.
      return false
    }

  }


  ; Возвращает объект из config json файла.
  ; Все значения true/false будут конвертированы в 1/0.
  ; fileName - path to json file.
  ; Return - object, or false если файл не существует, или ошибочен.
  static getObject(fileName) {

    try {
      local config := FileRead(fileName)
      if (!config) {
        throw Error("Common config file not exists", -1)
      }

      ; JSON2
      return JSON.Parse(config, false, false)

    } catch as e {
      ; Common config file не существует, или json ошибочный.
      return false
    }

  }


  ; Возвращает текст из файла.
  ; Return - text, or false если файл не существует, или ошибка.
  static getRaw(fileName) {
    try {
      local config := FileRead(fileName)
      if (!config) {
        throw Error("Common config file not exists", -1)
      }
      return config
    } catch as e {
      ; Common config file не существует, или json ошибочный.
      return false
    }
  }


  ; Перезаписывает config json на диске.
  ; Поступает Map, или объект.
  ; Return - true если конфиг был перезаписан, false - если файл нельзя открыть,
  ; или если не записано.
  static set(mapToWrite, fileName) {

    local FileObj

    try {
      ; rw - перезаписывает файл (но с ошибками),
      ; w - Write: Creates a new file, overwriting any existing file.
      ; и создаёт если не существует.
      FileObj := FileOpen(fileName, "w", "UTF-8")
    } catch as e {
      ; MsgBox "An error was thrown!`nSpecifically: " e.Message
      return false
    }

    try {
      local strToWrite := JSON.Stringify(mapToWrite)
      FileObj.Write(strToWrite)
      FileObj.Close()
      return true
    } catch as e {
      ; MsgBox "An error was thrown!`nSpecifically: " e.Message
      return false
    }

  }


  ; Перезаписывает файл на диске.
  ; Поступает строка.
  ; Return - true, false - если если не записано.
  static setRaw(strToWrite, fileName) {

    try {
      ; rw - перезаписывает файл (но с ошибками),
      ; w - Write: Creates a new file, overwriting any existing file.
      FileObj := FileOpen(fileName, "w", "UTF-8")
      FileObj.Write(strToWrite)
      FileObj.Close()
    } catch as e {
      ; MsgBox "An error was thrown!`nSpecifically: " e.Message
      return false
    }

  }


}


