

class Utils {

  ; К первому объекту obj1 добавляются элементы из второго объекта obj2.
  ; Возвращается новый объект obj1.
  ; Работает только для первого уровня вложенности.
  ; obj1 := {k1: "v1"}
  ; obj2 := {k2: "v2"}
  ; obj2n := Utils.mergeObjects(obj1, obj2)
  ; MsgBox obj2n.k1
  static mergeObjects(obj1, obj2) {

    obj1 := obj1.Clone()
    obj2 := obj2.Clone()

    ; ; Объект {key: value} не перебирается в цикле.
    ; ; Конвертируем в Map.
    ; local obj2Str := JSON.Stringify(obj2)
    ; obj2 := JSON.Parse(obj2Str)
    ; Или:
    for k, v in obj2.OwnProps() {
      obj1[k] := v
    }

    return obj1

  }


  ; Добавляет к объекту 1, объект 2, как ссылки на объекты. Не копируя значения.
  ; Не создавая новый объект.
  ; Ни чего не возвращает.
  static mergeObjectsRef(obj1, obj2) {

    if Type(obj1) != "Object" || Type(obj2) != "Object" {
      MsgBox "Error: obj1 = " Type(obj1) ", " Type(obj2)
      return
    }

    for k, v in obj2.OwnProps() {
      if Type(v) == "Object" {
        ; Значение первого уровня это объект

        if obj1.HasOwnProp(k) {
          ; Есть такое же свойство у объекта 1
          ; Значение у объекта 1 это объект?
          if (Type(obj1[k]) == "Object") {
            Utils.mergeObjectsRef(obj1[k], v)
          } else {
            ; Значение у объекта 1 это не объект
            obj1[k] := v
          }

        } else {
          obj1[k] := v
        }

      } else {
        ; Значение первого уровня это не объект
        obj1[k] := v
      }
    }

  }


  /**
   * ОБновляет значения в объекте obj, значениями с совпавшими ключами
  ;  в объекте newObj.
  * @param obj 
  * @param newObj 
  */
  static updateObject(obj, newObj){
    for k, v in newObj.OwnProps(){
      obj[k] := v
    }
  }


  ; Объединяет Map, или объекты, и возвращает новый Map.
  static mergeMaps(obj1, obj2) {

    obj1 := obj1.Clone()
    obj2 := obj2.Clone()
    local newMap := {}

    if (Type(obj1) == "Object") {
      for k, v in obj1.OwnProps() {
        newMap[k] := v
      }
    } else {
      for k, v in obj1 {
        newMap[k] := v
      }
    }

    if (Type(obj2) == "Object") {
      for k, v in obj2.OwnProps() {
        newMap[k] := v
      }
    } else {
      for k, v in obj2 {
        newMap[k] := v
      }
    }

    return newMap

  }

  ; Объединяет массивы, и возвращает новый массив.
  ; К первому массиву, добавляются элементы второго массива.
  static mergeArrays(arr1, arr2) {
    local arr1Copy := arr1.clone()
    local arr2Copy := arr2.clone()
    for k, v in arr2Copy {
      arr1Copy.Push(v)
    }
    return arr1Copy
  }


  ; В массиве есть значение?
  ; haystack - array
  ; needle - значение которое ищется в массиве
  static arrayHasValue(haystack, needle, &key := 0) {

    if (!isObject(haystack)) {
      return false
    }

    if (haystack.Length == 0) {
      return false
    }

    for k, v in haystack {
      if (IsSet(v) && v == needle) {
        key := k
        return true
      }
    }

    return false

  }


  ; Объединяет все значения массива arr в строку, через разделитель sep.
  static joinArrayToString(sep, arr) {
    for index, val in arr {
      str .= sep . val
    }
    return SubStr(str, StrLen(sep) + 1)
  }


  ; Это массив?
  static isArray(obj) {
    return Type(obj) == "Array"
  }


  ; Инвертирует массив, и возвращает новый массив
  static reverseArray(arr) {
    local newArr := []
    local arr2 := arr.clone()
    for k, win in arr {
      newArr.Push(arr2.Pop())
    }
    return newArr
  }


  /**
   * Объединяет уникальные значения. Возвращает новый массив.
   * Добавляет к первому массиву, значения из второго массива.
   * В результирующем массиве присутствуют все элементы из первого массива, 
   * и добавляются элементы из второго массива.
   * Все значения в полученном массиве будут уникальны.
   * arr1 := [1, 2, 3]
   * arr2 := [3, 1, 2, 4, 6, 7]
   * Return: 1, 2, 3, 4, 6, 7]
   * @param arr1 
   * @param arr2 
   */
  static arrayMergeUniqueValues(arr1, arr2){
    local retArr := arr1.clone()
    local arr2copy := arr2.clone()
    for _, arr2value in arr2copy{
      if(Utils.arrayHasValue(retArr, arr2value)){
        continue
      }
      retArr.Push(arr2value)
    }
    return retArr
  }

  /**
   * Возвращает новый массив, где все значения deleteValue убраны из массива arr1.
   * arr1 := [1, 2, 3, 1, 2, 3, 3], deleteValue := "3"
   * Result: [1, 2, 1, 2]
   * @param arr1 
   * @param arr2 
   */
  static arrayDeleteValue(arr, deleteValue){
    local keyMinus := 0
    local retArr := arr.clone()
    for k, arrValue in arr{
      if(arrValue == deleteValue){
        retArr.RemoveAt(k - keyMinus)
        keyMinus := keyMinus + 1
      }
    }
    return retArr
  }

  /**
   * Удаляет в массиве arr значения deleteValues.
   * Ни чего не возвращает.
   * @param {Array} arr 
   * @param {Array} deleteValues - Массив ключей которые удалить.
   */
  static arrayDeleteValues(arr, deleteValues){
    if(arr.Length == 0){
      return
    }
    local keyMinus := 0
    for _, deleteValue in deleteValues{
        local deleteIndex := deleteValue - keyMinus
        if(deleteIndex < 1 || deleteIndex > arr.Length){
          continue
        }
        arr.RemoveAt(deleteIndex)
        keyMinus := keyMinus + 1
    }
  }

  /**
   * Повторяет строку.
   * https://www.autohotkey.com/boards/viewtopic.php?t=33977
   * @param text 
   * @param times 
   * @returns {Integer | String} 
   */
  static strRepeat(text, times){
    ; local timeStart := A_TickCount
    local ret := ""
    loop times{
      ret .= text
    }
    ; Debug.log(A_TickCount - timeStart)
    return ret
  }

  ; Существует у объекта такой путь 'key1.key2...'?
  ; obj - объект.
  ; path - строка пути, вида '["key1"]["key2"]...'.
  ; Если значение переменной пути вычисляется к false, то возвращает false.
  static propertyPathIsExist(obj, path) {

    local str := ""

    try {
      ahkExec("str := obj" . path)
    } catch as e {
      return false
    }

    return true

    ; if(str){
    ;     return true
    ; }else{
    ;     return false
    ; }

  }


  ; ; Требуется при обновлении конфигов при установке новой версии программы.
  ; ; Only nested objects, not arrays.
  ; ; В новом json, новой версии, перезаписывает ключи, конфигурацию, значениями из
  ; ; user json.
  ; ; newJson - json новой версии.
  ; ; userJson - user json.
  ; ; keyNamesToUpdate - массив с именами ключей которые нужно обновлять из user json.
  ; static replaceValuesFromUserJson(newJson, userJson, keyNamesToUpdate){

  ;     ; ["key1"]["key2"]...
  ;     local path := []

  ;     updateJson(newJson, newJson, userJson)

  ;     ; ==================================================

  ;     updateJson(obj, newJson, userJson){
  ;     ; updateJson(obj){

  ;         ; Листаем новый json, до крайнего свойства, значение которого
  ;         ; это не объект.
  ;         ; Если этот json путь существует в прежднем json, то
  ;         ; устанавливаем значение оттуда в новый json.
  ;         for k, v in obj.OwnProps(){

  ;             if(IsObject(v)){

  ;                 path.Push("[`"" . k . "`"]")

  ;                 updateJson(v, newJson, userJson)
  ;                 ; updateJson(v)

  ;                 if(path.Length != 0){
  ;                     path.Pop()
  ;                 }

  ;             }else{
  ;                 ; Значение это не объект. Это крайнее свойство.

  ;                 ; Имя свойства в спике?
  ;                 if(Utils.arrayHasValue(keyNamesToUpdate, k)){

  ;                     local pathStr := Utils.joinArrayToString("", path)
  ;                     pathStr .= "[`"" . k . "`"]"

  ;                     if(Utils.propertyPathIsExist(userJson, pathStr)){
  ;                         ; В прежднем json есть такой путь

  ;                         local execStr := "newJson" . pathStr . " := userJson" . pathStr

  ;                         try{
  ;                             ahkExec(execStr)
  ;                         }catch as e{
  ;                             ; MsgBox e.Message
  ;                         }

  ;                     }

  ;                 }


  ;             }

  ;         }
  ;     }

  ; }


  static replaceValuesFromUserJson(newJson, userJson, keyNamesToUpdate) {

    ; ["1"]["key1"]["key2"]...
    local path := []

    updateJson(newJson, newJson, userJson)

    ; ==================================================

    updateJson(obj, newJson, userJson) {
      ; updateJson(obj){

      ; Debug().logF(obj, "=========== updateJson() ============")

      local loopVar := obj

      if (!Utils.isArray(obj)) {
        try {
          loopVar := obj.OwnProps()
        } catch as e {
          ; Debug().logF("!!!!!!!!!! Error ")
          return
          ; MsgBox loopVar
        }
      }

      ; Листаем новый json, до крайнего свойства, значение которого
      ; это не объект.
      ; Если этот json путь существует в прежднем json, то
      ; устанавливаем значение оттуда в новый json.
      for k, v in loopVar {

        ; MsgBox "loopVar"

        ; Debug().logF(v, "--------- for k, v in loopVar: ")

        if (IsObject(v)) {

          path.Push("[`"" . k . "`"]")

          ; Debug().logF(path, "---- path (IsObject(v) == true):")


          updateJson(v, newJson, userJson)
          ; updateJson(v)

          if (path.Length != 0) {
            path.Pop()
            ; Debug().logF(path, "---- after updateJson(): ")
          }

        } else {
          ; Значение это не объект. Это крайнее свойство.

          ; Debug().logF("---- IsObject(v) == false")

          ; Имя свойства в спике?
          if (Utils.arrayHasValue(keyNamesToUpdate, k)) {

            local pathStr := Utils.joinArrayToString("", path)
            pathStr .= "[`"" . k . "`"]"

            ; Debug().logF( "k = " . k . " in array, pathStr = " . pathStr)

            if (Utils.propertyPathIsExist(userJson, pathStr)) {
              ; В прежднем json есть такой путь

              local execStr := "newJson" . pathStr . " := userJson" . pathStr

              ; Debug().logF( "propertyPathIsExist == true, execStr = " . execStr)

              try {
                ahkExec(execStr)
              } catch as e {
                ; Debug().logF("!!!!!!!!!!!!!!! Error ahkExec()")
                ; MsgBox e.Message
              }

            }

          }


        }

      }
    }

  }


  ; Get SC key for keyboard layout, default is english (langID).
  ; Возвращает sc код клавиши, для английской раскладки. sc10.
  ; Без лидирующего нуля, не sc010.
  ; Или называние клавиши, если sc кода не существует. Например LButton.
  static GetKeySCFromLang(key, langID := 0x4090409) {
    local currentLayout := DllCall("GetKeyboardLayout", "uint", 0)            ; Save previous layout
    DllCall("ActivateKeyboardLayout", "uptr", langID, "uint", 0)        ; Set new keyboard layout
    local SC := GetKeySC(key)                                                 ; Get SC for new layout
    DllCall("ActivateKeyboardLayout", "uptr", currentLayout, "uint", 0) ; revert to previous layout

    if (SC) {
      SC := Format("sc{:X}", SC)
    } else {
      SC := key
    }
    return SC
  }


  /**
   * возвращает строку, с напечатанными клавишами sc или vk.  
   * @param {String} scVk - "sc" | "vk".
   * @returns {String} 
   */
  static printVkScKeys(scVk := "sc"){
    local scKeys := ""
    n := 0

    ; 0x100 - 256
    ; 0x200 - 512
    local numLoop := 0
    if(scVk == "sc"){
      numLoop := 0x200 
    }else{
      numLoop := 0x100 
    }

    Loop numLoop{
      ; sc клавиша. Например sc10.
      ; "sc{:X}" - Форматировать без лидирующих нулей.
      local vk := Format( scVk . "{:X}", A_Index - 1 )
      ; "sc{:03X}" - Форматировать c лидирующими нулями.
      ; sc := Format( "sc{:03X}", A_Index-1 )

      ; Название клавиши. Например Enter.
      local keyName := GetKeyName(vk)

      if(keyName == ""){
        continue
      }

      n := n + 1
      scKeys .= n . ". - " . vk . " - " . keyName . "`n"
    }

    return scKeys
  }



  /**
   * Возвращает путь к выделенному файлу, в FileExplorer.
   * Если выбрано несколько файлов, то пути разделяются через \n.
   * @returns {String} 
   */
  static Explorer_GetSelection(hwnd := false) {
    if(hwnd == false){
      if !hwnd := WinActive("ahk_class CabinetWClass ahk_exe explorer.exe"){
        return
      }
    }
    try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd)
    for w in ComObject("Shell.Application").Windows {
      if w.hwnd != hwnd
        continue
      if IsSet(activeTab) {
        static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
        shellBrowser := ComObjQuery(w, IID_IShellBrowser, IID_IShellBrowser)
        ComCall(3, shellBrowser, "uint*", &thisTab := 0)
        if thisTab != activeTab
          continue
      }
      foundWin := w
      break
    }
    str := ""
    for i in foundWin.Document.SelectedItems
      str .= i.Path "`n"
    return str
  }

  

}


; https://www.autohotkey.com/docs/v2/Objects.htm#ObjPtr

; obj1 := {
;     k1: "v1",
;     obj2: {
;         obj3: "value",
;         obj3_2: [],
;         k3: "test"
;     }
; }


; obj2 := {
;     k2: "v2",
;     obj2: {
;         obj3: "valueNew",
;         obj3_2: [1, 2],
;         k4: "v"
;     }
; }








