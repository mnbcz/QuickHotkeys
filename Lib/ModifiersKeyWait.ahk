
/**
 * Ожидает нажатие хоткея.
 * Или Ctrl+Shift+q, или q.
 * Что было нажато одновременно.
 */
; Usage:
; modKey := ModifiersKeyWait()
; modKey.start(pressedKeysCallback)
; pressedKeysCallback(_, keys){
;   Debug().logF(keys)
  ; Возвращает объект:
  ; {
  ; 	"hotkey": "<^<+<!sc10",
  ; 	"hotkeyDisplay": "LControl + LShift + LAlt + q"
  ; }
  ; Или пустую строку если нажато не правильно.
; }
class ModifiersKeyWait{

  ; Карта клавиш которые были нажаты.
  ; Ключи: sc, key (Key name).
  pressedStack := Map() 
  ; Содержит то же самое что и pressedStack, только клавиши
  ; убираются отсюда когда отжимаются.
  ; Когда все клавиши будут отжаты, это будет пустая карта.
  unpressedStack := Map() 

  modReplaceMap := {
    LCtrl: "<^",
    LControl: "<^",
    Ctrl: "^",
    RControl: ">^",
    RCtrl: ">^",
    LShift: "<+",
    Shift: "+",
    RShift: ">+",
    LAlt: "<!",
    Alt: "!",
    RAlt: ">!",
    LWin: "<#",
    Win: "#",
    RWin: ">#",
  }

  ; Без левых и правых модификаторов. Только (Ctrl).
  modReplaceMapAbs := {
    LCtrl: "^",
    LControl: "^",
    Ctrl: "^",
    RControl: "^",
    RCtrl: "^",
    LShift: "+",
    Shift: "+",
    RShift: "+",
    LAlt: "!",
    Alt: "!",
    RAlt: "!",
    LWin: "#",
    Win: "#",
    RWin: "#",
  }

  pressedKeysCallback := {}

  KeyDownCallback(ih, vk, sc){
    ; Когда нажимается модификатор, то это ещё отсылает клавишу с кодом 0.
    if(sc == 0){
      return
    }
    ; Backspace
    if(sc == 14){
      return
    }
    local keyObj := {}
    keyObj.sc := Format("sc{:x}", sc)  
    keyObj.vk := Format("vk{:x}", sc)  
    keyObj.key := GetKeyName(keyObj.sc)
    this.pressedStack.Set(keyObj.sc, keyObj)
    this.unpressedStack.Set(keyObj.sc, keyObj)
    ; Debug().logF("Down = " . keyObj.sc . ", " . keyObj.key)
  }
  
  KeyUpCallback(ih, vk, sc){
    ; Когда нажимается модификатор, то это ещё отсылает клавишу с кодом 0.
    if(sc == 0){
      return
    }
    ; Backspace
    if(sc == 14){
      return
    }

    local keyObj := {}
    keyObj.sc := Format("sc{:x}", sc)  
    keyObj.vk := Format("vk{:x}", sc)  
    keyObj.key := GetKeyName(keyObj.sc)
    this.pressedStack.Set(keyObj.sc, keyObj)
    this.unpressedStack.Delete(keyObj.sc)
    if(this.unpressedStack.Count == 0){
      ih.Stop()
      ; Debug().logF(this.pressedStack)
      ; Debug().logF(this.filter())
      this.pressedKeysCallback(this.filter())
    }
  }
 
  start(pressedKeysCallback){
    this.pressedKeysCallback := pressedKeysCallback
    ; L6 - Ожидать до 6-ти символов.
    ih := InputHook("L6")
    ; {all} - ожидать все клавиши.
    ih.KeyOpt("{all}", "N")
    ih.OnKeyDown := (ih, vk, sc) => this.KeyDownCallback(ih, vk, sc)
    ih.OnKeyUp := (ih, vk, sc) => this.KeyUpCallback(ih, vk, sc)
    ih.Start()
    ih.Wait()
  }

  ; Возвращает объект:
  ; {
  ; 	"hotkey": "<^<+<!sc10",
  ; 	"hotkeyDisplay": "LControl + LShift + LAlt + q"
  ; }
  ; Или пустую строку если нажато не правильно.
  filter(){
    ; Клавиша не модификатор которая была нажата. Карта.
    ; Ключи: sc, vk, key (Tab)
    local notMod := {}
    ; Клавиши модификаторы которые были нажаты. Карта.
    ; Ключи: sc, vk, key (Tab)
    local modsMap := Map()
    for sc, keyMap in this.pressedStack{
      if(!this.modReplaceMapAbs.HasOwnProp(keyMap.Get("key"))){
        ; Это клавиша не модификатор.
        if(ObjOwnPropCount(notMod) == 0){
          notMod := keyMap
        }
        continue
      }else{
        ; Это клавиша модификатор.
        modsMap.Set(sc, keyMap)
      }
    }

    ; Ключи: hotkey = ^!sc10, hotkeyDisplay = Ctrl + Aly + q. 
    local hotkeyMap := Map()
    local hotkeyDisplay := ""
    local hotkey := ""
    for sc, keyMap in modsMap{
      hotkeyDisplay .= keyMap.Get("key") . " + "
      hotkey .= this.modReplaceMapAbs[keyMap.Get("key")]
    }

    if(ObjOwnPropCount(notMod) == 0){
      return ""
    }

    hotkeyDisplay .= notMod.key
    hotkey .= "{" . notMod.vk . "}"
    return {hotkeyDisplay: hotkeyDisplay, hotkey: hotkey}

  }

}




