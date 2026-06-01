
// Без левых и правых модификаторов. Только (Ctrl).
let modReplaceMapAbs = {
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

/**
 * Возвращает массив из 3-ёх элементов: 
 * 1. Нормализованную строку, в правильном порядке модификаторов - LCtrl+LShift+q
 * 2. Строка для хоткея - ^!q.
 * 3. Клавиша - q
 * @param {string} hotkeyStr - Строка хоткея "Shift + Ctrl + q".
 */
function parseHotkeyString(hotkeyStr){

  // Убираем все пробелы
  hotkeyStr = hotkeyStr.replace(/ /gi, '')
  // Заменяем + на |
  hotkeyStr = hotkeyStr.replace(/\+/gi, '|')

  // Строим строку с правильным следованием Ctrl, Shift. 
  // В том порядке, в котором они определены в массиве. 

  // Объект модификаторов.
  // {lCtrl: "<^", ...}
  let modObj = {}
 
  // Перебираем карту, и добавляем модификаторы в массив
  Object.keys(modReplaceMapAbs).forEach(function(key, index) {
    // key - LCtrl, ...
    const regex = new RegExp(key, "i")
    let modMatchResult = hotkeyStr.match(regex)
    if(modMatchResult){
      // В строке, в поле, есть модификатор, типа LCtrl.
      modObj[key] = modReplaceMapAbs[key]
      // Убираем найденный модификатор из строки
      const regex = new RegExp(key + "[\|\ ]*", "i")
      hotkeyStr = hotkeyStr.replace(regex, "")
    }
  });

  // Убираем все символы | из строки
  // key - например клавиша - q, Tab, или пустая строка.
  let key = hotkeyStr.replace(/[\| ]/gi, "")
  // Строка модификаторов - ^!
  let hotkeyModStr = Object.values(modObj).join("")
  // Строка хоткея с плюсами. LCtrl+LWin.
  let hotkeyDisplayStr = Object.keys(modObj).join("+")
  if(key){
      if(hotkeyDisplayStr == ""){
          hotkeyDisplayStr = key
      }else{
          hotkeyDisplayStr += "+" + key
      }
  }  
  // hotkeyModStr += "{" + key + "}"
  return [hotkeyDisplayStr, hotkeyModStr, key]
}


export {parseHotkeyString}
