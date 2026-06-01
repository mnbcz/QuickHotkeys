
; 
class Data {

  ; Данные из файла data.json
  data := {}

  __New() {
    this.load()
  }

  ; Загружает данные из файла data.json в config, и в свойство data
  load() {
    global config, ConfigReader
    if (FileExist(config.Data.dataPath)) {
      this.data := ConfigReader.getObject(config.Data.dataPath)
      if (this.data) {
        for k, v in this.data.OwnProps() {
          config[k] := v
        }
      }
    }
  }


  ; Записывает данные в файл data.json.
  ; data - объект, значения, которые добавить к данным, или перезаписать.
  save(data := false) {
    global config, ConfigReader
    if (data) {
      for k, v in data.OwnProps() {
        this.data[k] := v
      }
    }
    ConfigReader.set(this.data, config.Data.dataPath)
  }
}

