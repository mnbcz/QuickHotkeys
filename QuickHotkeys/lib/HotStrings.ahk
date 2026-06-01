

class HotStrings{

  ; Последние буквы которые были набраны.
  typedSymbols := ""

  ; Map(): values["nd"] := {value: "–", length: 2}
  tokens := Map()

  __New() {
    values := Map()
    ; -==
    values["scCscDscD"] := {value: "—", length: 3}
    ; -00
    values["scCscBscB"] := {value: "–", length: 3}
    ; arru
    values["sc1Esc13sc13sc16"] := {value: "↑", length: 4}
    ; arrd
    values["sc1Esc13sc13sc20"] := {value: "↓", length: 4}
    ; arrl
    values["sc1Esc13sc13sc26"] := {value: "←", length: 4}
    ; arrr
    values["sc1Esc13sc13sc13"] := {value: "→", length: 4}
    ; 
    this.tokens := values

  }

  /**
   * Есть совпадение в строке последних набранных символов?
   * @returns {Any | Integer} 
   */
  match(){
    for keyword, value in this.tokens{
      ; if(RegExMatch(this.last60symbols, "([^\w]|^)" . keyword . "$")){
      if(RegExMatch(this.typedSymbols, keyword . "$")){
        ; MsgBox GetKeyName("sc10") . StrLen(str)
        return [keyword, value]
      }
    }
    return false
  }

  /**
   * Добавляет клавишу, к тексту нажатых клавиш.
   * @param key 
   */ 
  add(key := 0){
    static count := 0

    if(key == 0){
      this.typedSymbols := ""
      count := 0
      return
    }

    this.typedSymbols .= key
    if(count > 30){
      count := 0
      ; Убираем первые символы из начала строки.
      local typedLength := StrLen(this.typedSymbols)
      if(typedLength >= 120){
        ; Возвращает всё, начиная с индекса typedLength - 20, 
        ; и до конца строки.
        this.typedSymbols := SubStr(this.typedSymbols , typedLength - 20)
      }
    }
    count++
  }

}



