// LShift - <+
// LCtrl - <^
// LAlt - <!
// LWin - <#
// RShift - >+
// RCtrl - >^
// RAlt - >!
// RWin - >#

/**
 * Возвращает массив из двух элементов, нормализованную строку, в 
 * правильном порядке хоткеев:
 * hotkeyDisplayStr - LShift+LCtrl+q
 * hotkeyModStr - <+<^q
 * @param {string} hotkeyStr - Строка хоткея "LCtrl + Shift + q".
 * Можно использовать модификаторы ^+q, но тогда порядок будет таким как
 * указан.
 */
function parseHotkeyString(hotkeyStr){

  let hotkeySymbolReplaceMap = {
    "LCtrl": "<^",
    "Ctrl": "^",
    "RCtrl": ">^",

    "LShift": "<+",
    "Shift": "+",
    "RShift": ">+",

    "LAlt": "<!",
    "Alt": "!",
    "RAlt": ">!",

    "LWin": "<#",
    "Win": "#",
    "RWin": ">#",

  }

  // Убираем все пробелы
  hotkeyStr = hotkeyStr.replace(/ /gi, '')
  // Заменяем + на |
  hotkeyStr = hotkeyStr.replace(/(?<=[a-zA-Z0-9]) *\+ *(?=[a-zA-Z0-9])/gi, '|')

  // Строим строку с правильным следованием Ctrl, Shift. 
  // В том порядке, в котором они определены в массиве. 

  // Массив модификаторов.
  // {lCtrl: "<^", ...}
  let modObj = {}

  // Перебираем карту, и добавляем модификаторы в массив
  Object.keys(hotkeySymbolReplaceMap).forEach(function(key, index) {
    const regex = new RegExp(key, "i")
    let modMatchResult = hotkeyStr.match(regex)
    if(modMatchResult){
      modObj[key] = hotkeySymbolReplaceMap[key]
      // Убираем найденный модификатор из строки
      const regex = new RegExp(key + "[ \|]*", "i")
      hotkeyStr = hotkeyStr.replace(regex, "")
    }
  });

  // Убираем все символы | из строки
  // Клавиша - q
  let key = hotkeyStr.replace(/\|/gi, "")

  let hotkeyDisplayStr = Object.keys(modObj).join("+")
  let hotkeyModStr = Object.values(modObj).join("")

  // console.log(hotkeyDisplayStr)
  // console.log(hotkeyModStr)

  return [hotkeyDisplayStr, hotkeyModStr, key]

}

// parseHotkeyString("$*~<+<!^>+K")
// console.log( parseHotkeyString("$*~<^<+k") )
// console.log( parseHotkeyString("Shift + Ctrl + q") )



