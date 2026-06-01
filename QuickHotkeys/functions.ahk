
; Отключаем срабатывание на сначала нажатую LCtrl
; Hotkey("~LCtrl & ~LButton", disable, "On")
; Hotkey("LWin & ~LButton", disable, "On")
; Hotkey("~LShift & ~LButton", disable, "On")
; Hotkey("~LAlt & ~LButton", disable, "On")
; Hotkey("~CapsLock & ~LButton", disable, "On")
; Hotkey("~Tab & ~LButton", disable, "On")


disable(*){
  return
}

; Используется как колбэк в HotIf.
HotIfCallBackOn_FileExplorer_Desktop(*){
  return WinActive("ahk_class CabinetWClass") || WinActive("ahk_class WorkerW")
}

/**
 * Курсор над каким нибудь из окон из массива WinTitles? 
 * @param WinTitles - массив с названиями окон ahk_class (без слова ahk_class).
 * @param winId - id окна. Не обязательно. Будет получен ид окна гле курсор.
 * @returns {boolean}
 */
MouseIsOverWindows(WinTitles, &winId := false) {
  if (!IsSet(winId) || winId == false) {
    MouseGetPos(, , &winId)
  }
  for i, WinTitle in WinTitles {
    if (WinExist("ahk_class " . WinTitle . " ahk_id " . winId)) {
      return true
    }
  }
  return false
}

/**
 * Колбэк для HotIf.
 * Проверяет находится ли курсор на окнах которые запрещено перемещать.
 * Курсор не на - десктопе (WorkerW), 
 * окне AltTab (XamlExplorerHostIslandWindow)?
 * @returns True если курсор не на дэсктопе, окне AltTab.
 */
CursorIsNotOverDesktop(*) {
  return !MouseIsOverWindows(["WorkerW", "XamlExplorerHostIslandWindow"])
}

; Возвращает название класса окна над которым курсор.
getWindowClassOfCursor(hWnd := false) {
  if (hWnd = false) {
    ; id окна где курсор
    MouseGetPos(, , &hWnd)
  }
  ; Фокус на окно
  ; WinActivate, ahk_id %hWnd%
  ; Название класса через id окна (hWnd)
  return WinGetClass("ahk_id " hWnd)
}


; Окно в FullScreen?
isWindowFullScreen(winTitle) {
  ;checks if the specified window is full screen
  local winID := WinExist(winTitle)

  if (!winID) {
    return false
  }

  local style := WinGetStyle("ahk_id " WinID)
  WinGetPos(, , &winW, &winH, winTitle)
  ; 0x800000 is WS_BORDER.
  ; 0x20000000 is WS_MINIMIZE.
  ; no border and not minimized
  return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

; Сворачивает окно над которым курсор на TaskBar.
minimizeWindow(winId := false) {
  if (winId == false) {
    MouseGetPos(, , &winId)
  }
  ; This message is mostly equivalent to WinMinimize,
  ; but it avoids a bug with PSPad.
  try{
    PostMessage(0x112, 0xf020, , , "ahk_id " winId)
  }
  ; Скрывает таскбар.
  ; Но таскбар больше не появляется.
  ; try{
  ;   ; WinHide "ahk_class Shell_TrayWnd"
  ;   WinShow "ahk_class Shell_TrayWnd"
  ; }
}

; Разворачивает последнее свёрнутое окно, из Alt+Tab, и возвращает id
; этого окна.
restoreLastMinimizedWindow(isExceptOpenedWindows := false) {
  local winId := 0
  global _altTabWindows

  if(isExceptOpenedWindows){
    local altTabWindows := _altTabWindows.getAltTabWindows()
    local maximizedWindows := _altTabWindows.getMinimizedMaximizedWindows(altTabWindows)["maximized"]

    if (winId := getNextActiveAltTabWindow(altTabWindows, maximizedWindows)){
      WinActivate("ahk_id " winId)
    }
    return winId
  }

  if (winId := getNextActiveAltTabWindow()){
    WinActivate("ahk_id " winId)
  }
  return winId
}


; ; Разворачивает последнее свёрнутое окно, из Alt+Tab, и возвращает id
; ; этого окна.
; restoreLastMinimizedWindow(isExceptOpenedWindows := false) {
;   local winId := 0
;   global _altTabWindows

;   local realAltTabWindows := getRealAltTabWindows(&maximizedWindows, &minimizedWindows)

;   if(isExceptOpenedWindows){
;     for k, minimizedWindow in minimizedWindows{
;       if(WinGetID("A") == minimizedWindow){
;         continue
;       }
;       try{
;         if (winId := minimizedWindows[k]){
;           WinActivate("ahk_id " winId)
;         }
;       }
;       break
;     }
;     return winId
;   }

;   try{
;     if (winId := realAltTabWindows[1]){
;       WinActivate("ahk_id " winId)
;     }
;   }
;   return winId
; }


; filteredAltTabWindows()


/**
 * Возвращает соседнее, следующее самое недавнее активное окно.
 * Или false если окон в списке нет.
 * @param {Array} - Какие окна исключить. 
 * Автоматически добавляется активное окно в список исключения.
 * @returns {Integer | Any} 
 */
getNextActiveAltTabWindow(altTabWindows := 0, exclude := []){
  ; Нужно получить: 
  ; - Список открытых окон.
  ; - Список свёрнутых окон на Таскбаре.
  ; Получить окно из списка окон AltTab, самое недавнее.
  ; Если это окно на экране, то вернуть это.
  ; Если это свёрнутое, то получить первое из списка свёрнутых окон,
  ; если это окно присутствует в спике AltTab.
  ; Если не присутствует, то убрать из списка свёрнутых окон.

  local activeWindow := 0
  try{
    activeWindow := WinGetID("A")
  }
  if(activeWindow){
    ; exclude.Set(activeWindow, "")
    exclude.Push(activeWindow)
  }

  global _listenWindows
  global _altTabWindows

  if(altTabWindows == 0){
    altTabWindows := _altTabWindows.getAltTabWindows()
  }

  if(altTabWindows.Length == 0){
    return false
  }

  local mostActiveWindow := altTabWindows[1]

  ; Перебираем окна из AltTab, пока не встретится окно не в аргументе exclude, 
  ; Если нужное окно на экране, то возвращаем.
  ; Если не на экране, то объединяем массивы окон AltTab на Таскбаре, 
  ; с массивом свёрнутых окон.
  ; Возвращаем первое найденное.

  for k, altTabWindow in altTabWindows{
    ; if(exclude.Has(altTabWindow)){
    if(Utils.arrayHasValue(exclude, altTabWindow)){
      continue
    }
    local winState := WinGetMinMax("ahk_id " . altTabWindow)
    if(winState != -1){
      ; Это окно на экране (не свёрнуто, не на Таскбаре).
      return altTabWindow
    }else{
      ; Ближайшее окно свёрнуто.
      mostActiveWindow := altTabWindow
      break
    }
  }

  ; Список AltTab говорит что ближайшее активное окно - свёрнуто.

  for _, minimizedWindow in _listenWindows.minimizedWindows{
    ; if(exclude.Has(minimizedWindow)){
    if(Utils.arrayHasValue(exclude, minimizedWindow)){
      continue
    }
    ; Проверяем, есть ли это окно в списке altTab.
    if(Utils.arrayHasValue(altTabWindows, minimizedWindow)){
      return minimizedWindow
    }else{
      ; Окно не существует в AltTab
      _listenWindows.minimizedWindows := Utils.arrayDeleteValue(_listenWindows.minimizedWindows, minimizedWindow)
    }
  }

  return mostActiveWindow

}


getRealAltTabWindows(&maximizedArg := 0, &minimizedArg := 0){
  global _altTabWindows
  global _listenWindows

  local altTabWindows := _altTabWindows.getAltTabWindows()
  if(altTabWindows.Length == 0){
    return 0
  }
  if(altTabWindows.Length == 1){
    return altTabWindows[1]
  }

  local realAltTabWindows := []

  local minimizedMaximizedWindows := _altTabWindows.getMinimizedMaximizedWindows(altTabWindows)
  local maximizedWindows := minimizedMaximizedWindows["maximized"]
  local minimizedWindows := minimizedMaximizedWindows["minimized"]
  maximizedArg := maximizedWindows

  ; Проверяем, возможно окна были закрыты, и в массиве _listenWindows.minimizedWindows
  ; содержатся лишние закрытые окна.
  ; Убираем из массива _listenWindows.minimizedWindows не существующие окна.
  local deleteMinimizedWindows := []
  for _, minimizedWindow in _listenWindows.minimizedWindows{
    if(!Utils.arrayHasValue(altTabWindows, minimizedWindow)){
      deleteMinimizedWindows.Push(minimizedWindow)
    }
  }
  if(deleteMinimizedWindows.Length > 0){
    Utils.arrayDeleteValues(_listenWindows.minimizedWindows, deleteMinimizedWindows)
  }
  
  ; Если предложенное списком AltTab окно - на экране, то ошибки нет,
  ; возвращаем массив AltTab как есть.
  ; Если предложенное списком AltTab окно - свёрнуто, то может быть ошибка.
  ; Первым в списке AktTab устанавливаем первое окно из _listenWindows.minimizedWindows.
  
  ; local winState := WinGetMinMax("ahk_id " . altTabWindows[2])
  ; if(winState != -1){
  ;   ; Это окно на экране (не свёрнуто, не на Таскбаре).
  ;   return altTabWindows
  ; }
  ; else{
  ;     local realMinimizedWindows := Utils.arrayMergeUniqueValues(_listenWindows.minimizedWindows, minimizedWindows)
  ;     local first := [realMinimizedWindows[2]]
  ;     return Utils.arrayMergeUniqueValues(first, altTabWindows)
  ; }

  ; Объединяем минимизированные окна.
  local realMinimizedWindows := Utils.arrayMergeUniqueValues(_listenWindows.minimizedWindows, minimizedWindows)
  maximizedArg := maximizedWindows
  minimizedArg := realMinimizedWindows

  ; Объединяем окна на экране с минимизированными.
  realAltTabWindows := Utils.arrayMergeUniqueValues(maximizedWindows, realMinimizedWindows)
  return realAltTabWindows

}

/**
 * Возвращает самое недавнее активное окно, кроме активного.
 * @param {Integer} realAltTabWindows 
 * @returns {Integer} 
 */
getNextRealAltTabWindow(realAltTabWindows := 0, &key := 0){

  if(realAltTabWindows == 0){
    realAltTabWindows := getRealAltTabWindows()
  }
  if(realAltTabWindows.Length == 0){
    return 0
  }
  if(realAltTabWindows.Length == 1){
    key := 1
    return realAltTabWindows[1]
  }

  local activeWindow := 0
  try{
    activeWindow := WinGetID("A")
  }
  if(activeWindow == realAltTabWindows[1]){
    key := 2
    return realAltTabWindows[2]
  }
  
  key := 1
  return realAltTabWindows[1]
}




; Возвращает модификаторы (LControl, LShift, ...) массивом из хоткей. 
; Включая LButton, RButton.
; Поступает строка хоткей: "^!#K"
getModifiers(hkey, includeLRButtons := true){
  modList := []
  if(RegExMatch(hkey, "\^")){
      modList.Push("LControl")
  }
  if(RegExMatch(hkey, "\+")){
      modList.Push("LShift")
  }
  if(RegExMatch(hkey, "\#")){
      modList.Push("LWin")
  }
  if(RegExMatch(hkey, "\!")){
      modList.Push("LAlt")
  }

  if(RegExMatch(hkey, "LControl")){
    modList.Push("LControl")
  }
  if(RegExMatch(hkey, "LCtrl")){
    modList.Push("LCtrl")
  }  
  if(RegExMatch(hkey, "LShift")){
    modList.Push("LShift")
  }  
  if(RegExMatch(hkey, "LAlt")){
    modList.Push("LAlt")
  }  
  if(RegExMatch(hkey, "LWin")){
    modList.Push("LWin")
  }
  if(RegExMatch(hkey, "RControl")){
    modList.Push("RControl")
  }
  if(RegExMatch(hkey, "RCtrl")){
    modList.Push("RCtrl")
  }  
  if(RegExMatch(hkey, "RShift")){
    modList.Push("RShift")
  }  
  if(RegExMatch(hkey, "RAlt")){
    modList.Push("RAlt")
  }  
  if(RegExMatch(hkey, "RWin")){
    modList.Push("RWin")
  }

  if(includeLRButtons){
    if(RegExMatch(hkey, "RButton")){
      modList.Push("RButton")
    }
    if(RegExMatch(hkey, "LButton")){
      modList.Push("LButton")
    }
  }

  return modList
}


; Возвращает модификаторы (<+,+,^, ...) массивом из хоткей. 
; Поступает строка хоткей: "^!#K"
getModifiersSymbols(hkey){
  modList := []
  if(RegExMatch(hkey, "\<\^")){
      modList.Push("<^")
      hkey := RegExReplace(hkey, "\<\^", "")
  }
  if(RegExMatch(hkey, "\<\+")){
      modList.Push("<+")
      hkey := RegExReplace(hkey, "\<\+", "")
  }
  if(RegExMatch(hkey, "\<\#")){
      modList.Push("<#")
      hkey := RegExReplace(hkey, "\<\#", "")
  }
  if(RegExMatch(hkey, "\<\!")){
      modList.Push("<!")
      hkey := RegExReplace(hkey, "\<\!", "")
  }

  if(RegExMatch(hkey, "\>\^")){
    modList.Push(">^")
    hkey := RegExReplace(hkey, "\>\^", "")
}
if(RegExMatch(hkey, "\>\+")){
    modList.Push(">+")
    hkey := RegExReplace(hkey, "\>\+", "")
}
if(RegExMatch(hkey, "\>\#")){
    modList.Push(">#")
    hkey := RegExReplace(hkey, "\>\#", "")
}
if(RegExMatch(hkey, "\>\!")){
    modList.Push(">!")
    hkey := RegExReplace(hkey, "\>\!", "")
}


if(RegExMatch(hkey, "\^")){
  modList.Push("^")
  hkey := RegExReplace(hkey, "\^", "")
}
if(RegExMatch(hkey, "\+")){
  modList.Push("+")
  hkey := RegExReplace(hkey, "\+", "")
}
if(RegExMatch(hkey, "\#")){
  modList.Push("#")
  hkey := RegExReplace(hkey, "\#", "")
}
if(RegExMatch(hkey, "\!")){
  modList.Push("!")
  hkey := RegExReplace(hkey, "\!", "")
}

  return modList
}



/**
 * Возвращает названия модификаторов, и символы модификаторов. 
 * @param hotkeyDisplay - Хоткей, вида LCtrl+LSift+T.
 * @returns {Object} - {symbols, names, key, scKey}
 */
getModsFromHotkeyDisplay(hotkeyDisplay){
  local mods := Map()
  mods["LShift"] := "<+"
  mods["RShift"] := ">+"
  mods.Set("Shift", "+")

  mods.Set("LCtrl", "<^")
  mods.Set("RCtrl", ">^")
  mods.Set("Ctrl", "^")

  mods.Set("LWin", "<#")
  mods.Set("RWin", ">#")
  mods.Set("Win", "#")

  mods.Set("LAlt", "<!")
  mods.Set("RAlt", ">!")
  mods.Set("Alt", "!")

  local modSymbolsMatch := {
    names: [],
    symbols: []
  }
  
  for modName, modSymbol in mods{
    ; https://regex101.com/r/PIVvjB/1

    if(RegExMatch(hotkeyDisplay, "i)(?<=^|[\+\s])" . modName . "(?=$|[\+\s])")){
      modSymbolsMatch.symbols.Push(modSymbol)
      modSymbolsMatch.names.Push(modName)
    }
  }

  for _, keyName in modSymbolsMatch.names{
    ; str := RegExReplace(str, regex, "")
    hotkeyDisplay := StrReplace(hotkeyDisplay, keyName)
  }

  hotkeyDisplay := StrReplace(hotkeyDisplay, "+")
  hotkeyDisplay := StrReplace(hotkeyDisplay, " ")
  modSymbolsMatch.key := hotkeyDisplay
  modSymbolsMatch.scKey := Format("sc{:X}", GetKeySC(hotkeyDisplay))

  return modSymbolsMatch

}


releaseModifiers_Timeout(interval := 60, stopFrom := -600){
  SetTimer releaseModifiers, interval
  SetTimer releaseModifiers_disableTimer, stopFrom
}

/**
 * Отключает таймер, который был установлен через:
 * SetTimer releaseModifiers, 100
 * Использование:
 * SetTimer releaseModifiers, 100
 * SetTimer releaseModifiers_disableTimer, -400
 * 
 */
releaseModifiers_disableTimer(){
  SetTimer releaseModifiers, 0
}

/**
 * Отжимает модификаторы, и кнопки мыши, если они нажаты программно, а физически отжаты.
 */
releaseModifiers(){
  
    ; Debug().logF("releaseModifiers()")
    ; SendEvent "{Blind}{sc15B Up}"

  ; KeyWait "LShift"
  if(GetKeyState("LShift") && !GetKeyState("LShift", "P")){
    SendEvent "{Blind}{LShift Up}"
    ; SendEvent "{Blind}{LShift Up}"
    ; Debug().logF("{LShift Up}")
  }
  ; KeyWait "LCtrl"
  ; SendEvent "{LCtrl Down}{LCtrl Up}"
  if(GetKeyState("LCtrl") && !GetKeyState("LCtrl", "P")){
    ; SendEvent "{LCtrl Up}"
    SendEvent "{Blind}{LCtrl Up}"
    ; SendEvent "{Blind}{LCtrl Up}"
  }

  ; SendEvent "{LAlt Down}{LAlt Up}"
  if(GetKeyState("LAlt") && !GetKeyState("LAlt", "P")){
    SendEvent "{Blind}{LAlt Up}"
    ; SendEvent "{Blind}{LAlt Up}"
    ; Debug().logF("{LAlt Up}")
  }
  ; KeyWait "LWin"
  if(GetKeyState("sc15B") && !GetKeyState("sc15B", "P")){
    ; SendEvent "{Blind}{LWin Up}"
    BlockInput "On"
    ; {sc15B Up}
    ; SendEvent "{Blind}{sc15B}{vk07}"
    ; Send "{Blind}{sc15B}{vk07}"
    Send "{Blind}{sc15B Up}"
    BlockInput "Off"
    ; SendEvent "{Blind}{sc15B Up}"
  }

  if(GetKeyState("RButton") && !GetKeyState("RButton", "P")){
    SendEvent "{Blind}{RButton Up}"
    ; SendEvent "{Blind}{RButton Up}"
    ; Debug().logF("{RButton Up}")
  }
  if(GetKeyState("LButton") && !GetKeyState("LButton", "P")){
    SendEvent "{Blind}{LButton Up}"
    ; SendEvent "{Blind}{LButton Up}"
    ; Debug().logF("{LButton Up}")
  }
}


/**
 * Стартует программу.
 * Должно вызываться таймером.
 * @param {String} prog 
 */
startProgram(prog := "calc.exe", title := "Calculator"){
  Run prog
  local winId := WinWait(title, , 10)
  ; Debug().logF(winId)
  if(winId){
    WinActivate title
  }
}

/**
 * Возвращает массив выделенных файлов в FileExplorer.
 * Или false если активное окно это не FileExplorer, или файлы не выбраны.
 * @returns {Integer | Array} 
 */
getSelectedFilesInFileExplorer(){
  
  if(WinActive("ahk_class CabinetWClass")){
    local hwnd := WinGetID("A")
    ; ahk_class CabinetWClass - FileExplorer
    ; ahk_class WorkerW - Desktop
    ; ahk_exe explorer.exe
  
    local selectedFiles := Utils.Explorer_GetSelection(hwnd)
    if (selectedFiles == "") {
      ; MsgBox "No files are selected in the File Explorer window."
      return false
    }
    ; Массив выбранных файлов.
    local selectedFiles := StrSplit(selectedFiles, "`n")
  
    local selectedFilesClean := []
    for k, selectedFile in selectedFiles{
      ; Убираем кавычки в начале и в конце строки.
      selectedFile := RegExReplace(selectedFile, '(?<=^)[\" ]+|[\" ]+(?:$)', "")
      if(selectedFile != ""){
        selectedFilesClean.Push(selectedFile)
      }
      ; MsgBox selectedFile
    }
  
    return selectedFilesClean
  }else{
    return false
  }
}


; Check whether the target window is activation target.
IsWindow(hWnd){
  dwStyle := WinGetStyle("ahk_id " hWnd)
  if ((dwStyle&0x08000000) || !(dwStyle&0x10000000)) {
      return false
  }
  dwExStyle := WinGetExStyle("ahk_id " hWnd)
  if (dwExStyle & 0x00000080) {
      return false
  }
  szClass := WinGetClass("ahk_id " hWnd)
  if (szClass = "TApplication") {
      return false
  }
  return true
}




; 
/**
 * Приводит окна AltTab в нужный порядок.
 * Когда в начале списка - самые недавние открытые окна.
 * И сортирует окна на открытые, и свёрнутые.
 * @returns {Map} Возвращает Map(), с ключами - "opened", "closed", "all".
 * opened, closed - массив id открытых/закрытых окон.
 * all - массив карт Map, с ключами: winId, winTitle, winState. Окна в порядке
 * самое недавнее открытое.
 */
filteredAltTabWindows(excludeWinId := 0){

  global _altTabWindows
  ; Окна в окне AltTab
  ; local altTabWins := WinGetListAlt()
  local altTabWins := _altTabWindows.getAltTabWindows()

  local mapWins := Map()
  ; Развёрнутые окна, на экране.
  ; Массив карт с ключами: winId, winTitle, winState.
  local openedWindows := []
  ; Свёрнутые окна.
  ; Массив карт с ключами: winId, winTitle, winState.
  local minimizedWindows := []
  ; Массив id открытых окон.
  local openedWindowsArr := []
  ; Массив id свёрнутых окон.
  local minimizedWindowsArr := []

  ; Перебираем все окна, и добавляем открытые окна на экране в один массив,
  ; а свёрнутые окна в другой массив.
  for k, winId in altTabWins{

    if(winId == excludeWinId){
      continue
    }

    ; Проверяем окно, это обычное окно, или скрытое, или CPU программа,
    ; и игнорируем все не стандартные окна, которых нет в списке AltTab.

    local winTitle := WinGetTitle(winId)
    ; Если заголовок окна это пустая строка, значит это Desktop.
    ; Monitor - это окно RAM программа.
    if(winTitle == ""){
        continue
    }
    if(!IsWindow(winId)){
        continue
    }

    ; logF("id = " . winId . ", title = " . winTitle)
    ; Получаем состояние окна - максимизировано (1, наверно развёрнуто на весь экран), 
    ; минимизировано (-1, в трее), в обычном перемещаемом состоянии (0).
    local winState := WinGetMinMax("ahk_id " winId)
    if(winState >= 0){
        ; Окно открыто
        openedWindows.Push(Map("winId", winId, "winTitle", winTitle, "winState", winState))
        openedWindowsArr.Push(winId)
    }else{
        ; Окно свёрнуто
        minimizedWindows.Push(Map("winId", winId, "winTitle", winTitle, "winState", winState))
        minimizedWindowsArr.Push(winId)
    }
  }

  ; Реверсируем свёрнутые окна. Так что в начале списка будет самое не давнее 
  ; открытое окно.
  local reverseClosedWins := Utils.reverseArray(minimizedWindows)
  ; Добавляем в конец к открытым окнам, свёрнутые.
  local allSortingWins := Utils.mergeArrays(openedWindows, reverseClosedWins)
  local winsMap := Map()
  winsMap["opened"] := openedWindowsArr
  winsMap["closed"] := minimizedWindowsArr
  winsMap["all"] := allSortingWins

  return winsMap

}





emptyFunc(*){
  return false
}


disableAllHotkeys(exceptMap := Map()){
  ; MsgBox "disableAllHotkeys()"
  global Modules
  for k, v in Modules.Hotkeys.assignedHotkeys.OwnProps(){
    if(exceptMap.Has(v)){
      continue
    }
    try{
      if(Type(v) == "Array"){
        Hotkey(v[1], v[2], "Off")
      }else{
        Hotkey(v, "Off")
      }
    }
  }
}

enableAllHotkeys(){
  global Modules
  for k, v in Modules.Hotkeys.assignedHotkeys.OwnProps(){
    try{
      ; Hotkey(v, "On")
      if(Type(v) == "Array"){
        Hotkey(v[1], v[2], v[3])
      }else{
        Hotkey(v, "On")
      }
    }
  }
}

printAllAssignedHotkeys(){
  global Modules
  Debug().logF(Modules.Hotkeys.assignedHotkeys)
}



; Прозрачное окно, на верху всех других окон, 
; через которое не проходят клики.
; Чтобы открыть это окно - topTransparentNotClickableWindow.Show()
; Чтобы закрыть это окно - topTransparentNotClickableWindow.Hide()
global topTransparentNotClickableWindow

topTransparentNotClickableWindowInit(){

  ; +++++++++++++++++++++++++++++++++++++++++++++++++
  ; global topLayerWindow := Gui("-Resize -DPIScale -0xCF0000 +ToolWindow")
  ; global topLayerWindow := Gui("+LastFound +AlwaysOnTop +ToolWindow +E0x00000020 -Caption -DPIScale")
  ; https://learn.microsoft.com/en-us/windows/win32/winmsg/extended-window-styles
  ; WS_EX_TRANSPARENT - 0x00000020L
  ; +E0x - означает расширенный стиль.
  global topTransparentNotClickableWindow := Gui("+AlwaysOnTop +ToolWindow +E0x00000020 -Caption -DPIScale")
  ; super.__New("+LastFound +AlwaysOnTop +ToolWindow +E0x00000020 -Caption -DPIScale")

  topTransparentNotClickableWindow.Title := "TopLayer"
  ; win2.AddButton(, "Text")
  ; 0x000000 - полностью прозрачный.
  topTransparentNotClickableWindow.BackColor := 0x000000
  ; #D81B1B 0x093fe1
  ; topTransparentNotClickableWindow.BackColor := 0x346897 
  ; Если установить прозрачность, то цвет будет более близкий
  ; к прозрачному, изначальному.
  ; WinSetTransparent 224, topLayerWindow

    ; Чтобы установить оставшиеся поля структуры к 0 байт. Необязательно.
    local margins := Buffer(16, 0)
    NumPut("Int", -1, margins)
  
    local ret := DllCall("Dwmapi\DwmExtendFrameIntoClientArea",
    "Ptr", topTransparentNotClickableWindow.Hwnd,
    ; MARGINS *pMarInset
    "Ptr", margins
    )
    ; Чтобы избавиться от бага - открытие Таскбара.
    topTransparentNotClickableWindow.Show("x0 y0 w" . A_ScreenWidth . " h" . A_ScreenHeight)
    topTransparentNotClickableWindow.Hide()
    ; topLayerWindow.Show("NoActivate x0 y0 w" . A_ScreenWidth . " h" . A_ScreenHeight)
    ; topTransparentNotClickableWindow.Show("x0 y0 w" . A_ScreenWidth . " h" . A_ScreenHeight)
}
topTransparentNotClickableWindowInit()



/**
 * Для более плавного расскрытия окон. Чтобы окно hwnd было размещено за hWndInsertAfter,
 * а не активировано как самое верхнее.
 * Это нужно вызывать после WinActivate().
 * https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setwindowpos?redirectedfrom=MSDN
 * @param hwnd 
 * @param hWndInsertAfter 
 */
setZOrderOfWindow(hwnd, hWndInsertAfter){
	; Repositioning a window in the z-order sometimes sets AlwaysOnTop.
    ; WinGet, OldExStyle, ExStyle, ahk_id %hwnd%
	
	DllCall("SetWindowPos", "uint", hwnd, "uint", hWndInsertAfter
	, "int", 0, "int", 0, "int", 0, "int", 0
	, "uint", 0x13)  ; 0x13 - NOSIZE|NOMOVE|NOACTIVATE (0x1|0x2|0x10)
	
	; Check if AlwaysOnTop status changed.   
    ; WinGet, ExStyle, ExStyle, ahk_id %hwnd%
    ; if (OldExStyle ^ ExStyle) & 0x8
    ;     WinSet, AlwaysOnTop, Toggle
}


upAllModifiers(){
  Send "{Blind}{LCtrl Up}"
  Send "{Blind}{Shift Up}"
  Send "{Blind}{LAlt Up}"
  Send "{Blind}{LWin Up}"
}


/**
 * Возвращает все sc клавиши.
 * @param {Integer} isGetTestString - 1 - Если нужно вернуть тестовую строку.
 * @param {Integer} exclude 
 * @returns {String | Object} - Объект с ключами:
 * ; Клавиши, модификаторы, все.
  local scKeysObj := {
    keys: [],
    mods: [],
    all: []
  }
 */
getAllScKeys(exclude := 0){

  if(exclude == 0){
    ; Клавиши которые исключить. 
    exclude := Map()
    ; sc1C - Enter
    exclude["sc1C"] := ""
    ; scE - BackSpace 
    exclude["scE"] := ""  
    ; sc36 - Лишний RShift
    exclude["sc36"] := ""

    ; 25  14B	 	u	0.12	Left           	
    ; 27  14D	 	d	0.34	Right      
    exclude["sc14B"] := ""
    exclude["sc14D"] := ""

  }

  ; Модификаторы.
  local mods := Map()
  ; sc2A - LShift
  mods["sc2A"] := ""
  ; sc136 - RShift
  mods["sc136"] := ""
  ; sc1D - LControl
  mods["sc1D"] := ""
  ; sc11D - RControl
  mods["sc11D"] := ""
  ; sc15B - LWin
  mods["sc15B"] := ""
  ; sc15C - RWin
  mods["sc15C"] := ""
  ; sc38 - LAlt
  mods["sc38"] := ""
  ; sc138 - RAlt
  mods["sc138"] := ""

  ; Тестовая строка всех клавиш. 
  local scKeys := ""

  ; Клавиши, модификаторы, все.
  local scKeysObj := {
    keys: [],
    mods: [],
    all: []
  }


  ; 0x100 - 256
  ; 0x200 - 512
  Loop 0x200{
    ; sc клавиша. Например sc10.
    ; "sc{:X}" - Форматировать без лидирующих нулей.
    local sc := Format( "sc{:X}", A_Index - 1 )
    ; "sc{:03X}" - Форматировать c лидирующими нулями.
    ; sc := Format( "sc{:03X}", A_Index-1 )

    ; Название клавиши. Например Enter.
    local keyName := GetKeyName(sc)
    if(keyName == ""){
      continue
    }
    if(exclude.Has(sc)){
      continue
    }

    if(mods.Has(sc)){
      scKeysObj.mods.Push(sc)
    }else{
      scKeysObj.keys.Push(sc)
    }
    scKeysObj.all.Push(sc)

  }

  return scKeysObj

}



/**
 * Возвращает все vk клавиши.
 * @param {Integer} exclude 
 * @returns {String | Object} - Объект с ключами:
 * ; Клавиши, модификаторы, все.
  local scKeysObj := {
    keys: [],
    mods: [],
    all: []
  }
 */
getAllVkKeys(exclude := 0){

  if(exclude == 0){
    ; Клавиши которые исключить. 
    exclude := Map()

    ; Кнопки мыши
    exclude["vk1"] := ""
    exclude["vk2"] := ""
    exclude["vk3"] := ""
    exclude["vk4"] := ""
    exclude["vk5"] := ""
    exclude["vk6"] := ""
    ; Enter
    exclude["vkD"] := ""
    ; Shift
    exclude["vk10"] := ""
    ; Control
    exclude["vk11"] := ""
    ; Alt
    exclude["vk12"] := ""

    ; Wheel
    exclude["vk9C"] := ""
    exclude["vk9D"] := ""
    exclude["vk9E"] := ""
    exclude["vk9F"] := ""

  }

  ; Модификаторы.
  local mods := Map()
  ; sc2A - LShift
  mods["vkA0"] := ""
  ; sc136 - RShift
  mods["vkA1"] := ""
  ; sc1D - LControl
  mods["vkA2"] := ""
  ; sc11D - RControl
  mods["vkA3"] := ""
  ; sc15B - LWin
  mods["vk5B"] := ""
  ; sc15C - RWin
  mods["vk5C"] := ""
  ; sc38 - LAlt
  mods["vkA4"] := ""
  ; sc138 - RAlt
  mods["vkA5"] := ""


  ; Клавиши, модификаторы, все.
  local scKeysObj := {
    keys: [],
    mods: [],
    all: []
  }

  ; 0x100 - 256
  ; 0x200 - 512
  Loop 0x100{
    ; sc клавиша. Например sc10.
    ; "sc{:X}" - Форматировать без лидирующих нулей.
    local sc := Format( "vk{:X}", A_Index - 1 )
    ; "sc{:03X}" - Форматировать c лидирующими нулями.
    ; sc := Format( "sc{:03X}", A_Index-1 )

    ; Название клавиши. Например Enter.
    local keyName := GetKeyName(sc)
    if(keyName == ""){
      continue
    }
    if(exclude.Has(sc)){
      continue
    }

    if(mods.Has(sc)){
      scKeysObj.mods.Push(sc)
    }else{
      scKeysObj.keys.Push(sc)
    }
    scKeysObj.all.Push(sc)

  }

  return scKeysObj

}
  


; Активирует дэсктоп
activateDesktop(){
  if(WinExist("ahk_class WorkerW ahk_exe explorer.exe")){
    try{
      WinActivate ("ahk_class WorkerW ahk_exe explorer.exe")
      return true
    }
    return false
  }
  if(WinExist("ahk_class Progman ahk_exe explorer.exe")){
    try{
      WinActivate ("ahk_class Progman ahk_exe explorer.exe")
      return true
    }
    return false
  }
}



; #Include ../Lib/ahk2_lib/BSTR.ahk
; #Include ../Lib/ahk2_lib/ComVar.ahk
; #Include ../Lib/ahk2_lib/UIAutomation/UIAutomation.ahk
; #Include ../Lib/ahk2_lib/Acc/Lib/Acc.ahk

/*
Возвращает как ссылки координаты мигающего текстового курсора.
Возвращает 1 - если есть мигающий курсор, курсор в текстовом поле?
и 0 - если нет.
@example
f1:: {
    if GetCaretPosEx(&left, &top, &right, &bottom, true) {
        A_CoordModeToolTip := "Screen"
        ToolTip "Hello", left, bottom
    }
}
*/
GetCaretPosEx(&left?, &top?, &right?, &bottom?, useHook := false) {
  if getCaretPosFromGui(&hwnd := 0)
    return true
  try
    className := WinGetClass(hwnd)
  catch
    className := ""
  if className ~= "^(?:Windows|Microsoft)\.UI\..+"
    funcs := [getCaretPosFromUIA, getCaretPosFromHook, getCaretPosFromMSAA]
  else if className ~= "^HwndWrapper\[PowerShell_ISE\.exe;;[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\]"
    funcs := [getCaretPosFromHook, getCaretPosFromWpfCaret]
  else
    funcs := [getCaretPosFromMSAA, getCaretPosFromUIA, getCaretPosFromHook]
  for fn in funcs {
    if fn == getCaretPosFromHook && !useHook
      continue
    if fn()
      return true
  }
  return false

  getCaretPosFromGui(&hwnd) {
    x64 := A_PtrSize == 8
    guiThreadInfo := Buffer(x64 ? 72 : 48)
    NumPut("uint", guiThreadInfo.Size, guiThreadInfo)
    if DllCall("GetGUIThreadInfo", "uint", 0, "ptr", guiThreadInfo) {
      if hwnd := NumGet(guiThreadInfo, x64 ? 48 : 28, "ptr") {
        getRect(guiThreadInfo.Ptr + (x64 ? 56 : 32), &left, &top, &right, &bottom)
        scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
        clientToScreenRect(hwnd, &left, &top, &right, &bottom)
        return true
      }
      hwnd := NumGet(guiThreadInfo, x64 ? 16 : 12, "ptr")
    }
    return false
  }

  getCaretPosFromMSAA() {
    if !hOleacc := DllCall("LoadLibraryW", "str", "oleacc.dll", "ptr")
      return false
    hOleacc := { Ptr: hOleacc, __Delete: (_) => DllCall("FreeLibrary", "ptr", _) }
    static IID_IAccessible := guidFromString("{618736e0-3c3d-11cf-810c-00aa00389b71}")
    if !DllCall("oleacc\AccessibleObjectFromWindow", "ptr", hwnd, "uint", 0xfffffff8, "ptr", IID_IAccessible, "ptr*", accCaret := ComValue(13, 0), "int") {
      if A_PtrSize == 8 {
        varChild := Buffer(24, 0)
        NumPut("ushort", 3, varChild)
        hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "ptr", varChild, "int")
      }
      else {
        hr := ComCall(22, accCaret, "int*", &x := 0, "int*", &y := 0, "int*", &w := 0, "int*", &h := 0, "int64", 3, "int64", 0, "int")
      }
      if !hr {
        pt := x | y << 32
        DllCall("ScreenToClient", "ptr", hwnd, "int64*", &pt)
        left := pt & 0xffffffff
        top := pt >> 32
        right := left + w
        bottom := top + h
        scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
        clientToScreenRect(hwnd, &left, &top, &right, &bottom)
        return true
      }
    }
    return false
  }

  getCaretPosFromUIA() {
    try {
      uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
      ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
      if !cacheRequest.Ptr
        return false
      ComCall(4, cacheRequest, "ptr", 10014) ; cacheRequest->AddPattern(UIA_TextPatternId);
      ComCall(4, cacheRequest, "ptr", 10024) ; cacheRequest->AddPattern(UIA_TextPattern2Id);

      ComCall(12, uia, "ptr", cacheRequest, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElementBuildCache(cacheRequest, &focusedEle);
      if !focusedEle.Ptr
        return false

      static IID_IUIAutomationTextPattern2 := guidFromString("{506a921a-fcc9-409f-b23b-37eb74106872}")
      range := ComValue(13, 0)
      ComCall(15, focusedEle, "int", 10024, "ptr", IID_IUIAutomationTextPattern2, "ptr*", textPattern := ComValue(13, 0)) ; focusedEle->GetCachedPatternAs(UIA_TextPattern2Id, IID_PPV_ARGS(&textPattern));
      if textPattern.Ptr {
        ComCall(10, textPattern, "int*", &isActive := 0, "ptr*", range) ; textPattern->GetCaretRange(&isActive, &range);
        if range.Ptr
          goto getRangeInfo
      }
      ; If no caret range, get selection range.
      static IID_IUIAutomationTextPattern := guidFromString("{32eba289-3583-42c9-9c59-3b6d9a1e9b6a}")
      ComCall(15, focusedEle, "int", 10014, "ptr", IID_IUIAutomationTextPattern, "ptr*", textPattern) ; focusedEle->GetCachedPatternAs(UIA_TextPatternId, IID_PPV_ARGS(&textPattern));
      if textPattern.Ptr {
        ComCall(5, textPattern, "ptr*", ranges := ComValue(13, 0)) ; textPattern->GetSelection(&ranges);
        if ranges.Ptr {
          ; Retrieve the last selection range.
          ComCall(3, ranges, "int*", &len := 0) ; ranges->get_Length(&len);
          if len > 0 {
            ComCall(4, ranges, "int", len - 1, "ptr*", range) ; ranges->GetElement(len - 1, &range);
            if range.Ptr {
              ; Collapse the range.
              ComCall(15, range, "int", 0, "ptr", range, "int", 1) ; range->MoveEndpointByRange(TextPatternRangeEndpoint_Start, range, TextPatternRangeEndpoint_End);
              goto getRangeInfo
            }
          }
        }
      }
      return false
getRangeInfo:
      psa := 0
      ; This is a degenerate text range, we have to expand it.
      ComCall(6, range, "int", 0) ; range->ExpandToEnclosingUnit(TextUnit_Character);
      ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
      if psa {
        rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
        if rects.MaxIndex() >= 3 {
          rects[2] := 0
          goto end
        }
      }
      ; ExpandToEnclosingUnit by character may be invalid in some control if the range is at the end of the document.
      ; Assume that the range is at the end of the document and not in an empty line, try to expand it by line.
      ComCall(6, range, "int", 3) ; range->ExpandToEnclosingUnit(TextUnit_Line)
      ComCall(10, range, "ptr*", &psa) ; range->GetBoundingRectangles(&psa);
      if psa {
        rects := ComValue(0x2005, psa, 1) ; SafeArray<double>
        if rects.MaxIndex() >= 3 {
          ; Here rects is {x, y, w, h}, we take the end endpoint as the caret position.
          rects[0] := rects[0] + rects[2]
          rects[2] := 0
          goto end
        }
      }
      return false
end:
      left := Round(rects[0])
      top := Round(rects[1])
      right := left + Round(rects[2])
      bottom := top + Round(rects[3])
      return true
    }
    return false
  }

  getCaretPosFromWpfCaret() {
    try {
      uia := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}")
      ComCall(8, uia, "ptr*", focusedEle := ComValue(13, 0)) ; uia->GetFocusedElement(&focusedEle);
      if !focusedEle.Ptr
        return false

      ComCall(20, uia, "ptr*", cacheRequest := ComValue(13, 0)) ; uia->CreateCacheRequest(&cacheRequest);
      if !cacheRequest.Ptr
        return false

      ComCall(17, uia, "ptr*", rawViewCondition := ComValue(13, 0)) ; uia->get_RawViewCondition(&rawViewCondition);
      if !rawViewCondition.Ptr
        return false

      ComCall(9, cacheRequest, "ptr", rawViewCondition) ; cacheRequest->put_TreeFilter(rawViewCondition);
      ComCall(3, cacheRequest, "int", 30001) ; cacheRequest->AddProperty(UIA_BoundingRectanglePropertyId);

      var := Buffer(24, 0)
      ref := ComValue(0x400C, var.Ptr)
      ref[] := ComValue(8, "WpfCaret")
      ComCall(23, uia, "int", 30012, "ptr", var, "ptr*", condition := ComValue(13, 0)) ; uia->CreatePropertyCondition(UIA_ClassNamePropertyId, CComVariant(L"WpfCaret"), &classNameCondition);
      if !condition.Ptr
        return false

      ComCall(7, focusedEle, "int", 4, "ptr", condition, "ptr", cacheRequest, "ptr*", wpfCaret := ComValue(13, 0)) ; focusedEle->FindFirstBuildCache(TreeScope_Descendants, condition, cacheRequest, &wpfCaret);
      if !wpfCaret.Ptr
        return false

      ComCall(75, wpfCaret, "ptr", rect := Buffer(16)) ; wpfCaret->get_CachedBoundingRectangle(&rect);
      getRect(rect, &left, &top, &right, &bottom)
      return true
    }
    return false
  }

  getCaretPosFromHook() {
    static WM_GET_CARET_POS := DllCall("RegisterWindowMessageW", "str", "WM_GET_CARET_POS", "uint")
    if !tid := DllCall("GetWindowThreadProcessId", "ptr", hwnd, "ptr*", &pid := 0, "uint")
      return false
    ; Update caret position
    try {
      SendMessage(0x010f, 0, 0, hwnd) ; WM_IME_COMPOSITION
    }
    ; PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ
    if !hProcess := DllCall("OpenProcess", "uint", 1082, "int", false, "uint", pid, "ptr")
      return false
    hProcess := { Ptr: hProcess, __Delete: (_) => DllCall("CloseHandle", "ptr", _) }

    isX64 := isX64Process(hProcess)
    if isX64 && A_PtrSize == 4
      return false
    if !moduleBaseMap := getModulesBases(hProcess, ["kernel32.dll", "user32.dll", "combase.dll"])
      return false
    if isX64 {
      static shellcode64 := compile(true)
      shellcode := shellcode64
    }
    else {
      static shellcode32 := compile(false)
      shellcode := shellcode32
    }
    if !mem := DllCall("VirtualAllocEx", "ptr", hProcess, "ptr", 0, "ptr", shellcode.Size, "uint", 0x1000, "uint", 0x40, "ptr")
      return false
    mem := { Ptr: mem, __Delete: (_) => DllCall("VirtualFreeEx", "ptr", hProcess, "ptr", _, "uptr", 0, "uint", 0x8000) }
    link(isX64, shellcode, mem.Ptr, moduleBaseMap["user32.dll"], moduleBaseMap["combase.dll"], hwnd, tid, WM_GET_CARET_POS, &pThreadProc, &pRect)

    if !DllCall("WriteProcessMemory", "ptr", hProcess, "ptr", mem, "ptr", shellcode, "uptr", shellcode.Size, "ptr", 0)
      return false
    DllCall("FlushInstructionCache", "ptr", hProcess, "ptr", mem, "uptr", shellcode.Size)

    if !hThread := DllCall("CreateRemoteThread", "ptr", hProcess, "ptr", 0, "uptr", 0, "ptr", pThreadProc, "ptr", mem, "uint", 0, "uint*", &remoteTid := 0, "ptr")
      return false
    hThread := { Ptr: hThread, __Delete: (_) => DllCall("CloseHandle", "ptr", _) }

    if msgWaitForSingleObject(hThread)
      return false
    if !DllCall("GetExitCodeThread", "ptr", hThread, "uint*", exitCode := 0) || exitCode !== 0
      return false

    rect := Buffer(16)
    if !DllCall("ReadProcessMemory", "ptr", hProcess, "ptr", pRect, "ptr", rect, "uptr", rect.Size, "uptr*", &bytesRead := 0) || bytesRead !== rect.Size
      return false
    getRect(rect, &left, &top, &right, &bottom)
    scaleRect(getWindowScale(hwnd), &left, &top, &right, &bottom)
    return true

    static isX64Process(hProcess) {
      DllCall("IsWow64Process", "ptr", hProcess, "int*", &isWow64 := 0)
      if isWow64
        return false
      if A_PtrSize == 8
        return true
      DllCall("IsWow64Process", "ptr", DllCall("GetCurrentProcess", "ptr"), "int*", &isWow64)
      return isWow64
    }

    static getModulesBases(hProcess, modules) {
      hModules := Buffer(A_PtrSize * 350)
      if !DllCall("K32EnumProcessModulesEx", "ptr", hProcess, "ptr", hModules, "uint", hModules.Size, "uint*", &needed := 0, "uint", 3)
        return
      moduleBaseMap := Map()
      moduleBaseMap.CaseSense := false
      for v in modules
        moduleBaseMap[v] := 0
      cnt := modules.Length
      loop Min(350, needed) {
        hModule := NumGet(hModules, A_PtrSize * (A_Index - 1), "ptr")
        VarSetStrCapacity(&name, 12)
        if DllCall("K32GetModuleBaseNameW", "ptr", hProcess, "ptr", hModule, "str", &name, "uint", 13) {
          if moduleBaseMap.Has(name) {
            moduleInfo := Buffer(24)
            if !DllCall("K32GetModuleInformation", "ptr", hProcess, "ptr", hModule, "ptr", moduleInfo, "uint", moduleInfo.Size)
              return
            if !base := NumGet(moduleInfo, "ptr")
              return
            moduleBaseMap[name] := base
            cnt--
          }
        }
      } until cnt == 0
      if cnt == 0
        return moduleBaseMap
    }

    static compile(x64) {
      if x64
        shellcodeBase64 := "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABrnppSh2UjT6uenH1oPjxQAeiAqiEg0hGT4ABgsGe4blNldFdpbmRvd3NIb29rRXhXAAAAVW5ob29rV2luZG93c0hvb2tFeABDYWxsTmV4dEhvb2tFeAAAAAAAAFNlbmRNZXNzYWdlVGltZW91dFcAQ29DcmVhdGVJbnN0YW5jZQAAAAAAAAAASIlcJAhIiXQkEFdIg+wgSYvYSIvyi/mFyXgjSIXbdB6LBQb///9BOUAQdRJIjQ3d/v//6JgBAACJBfL+//9Iiw3L/v//SI0VdP///+jnAgAASIXAdRBIi1wkMEiLdCQ4SIPEIF/DTIvLTIvGi9czyUiLXCQwSIt0JDhIg8QgX0j/4MzMzMzMzDPAw8zMzMzMQFNWSIPsSIvySIvZSIXJdQy4VwAHgEiDxEheW8NIi0kISI1UJGBIiVQkKEG4/////0iNVCQwSIl8JEAz/0iJVCQgiXwkYIvWSIsBRI1PAf9QKIXAeHJIOXwkMHRrOXwkYHRlSItLCEiNVCR4SIl8JHhIiwH/UEiL+IXAeDJIi0wkeEiFyXQoSIsBSI1UJHBMi0QkMEyNSxBIiVQkIIvW/1AgSItMJHiL+EiLAf9QEEiLTCQwSIsB/1AQi8dIi3wkQEiDxEheW8NIi3wkQLgBAAAASIPESF5bw8zMzMzMzMxIhcl0VEiF0nRPTYXAdEpIiwJIhcB1HUi4wAAAAAAAAEZIOUIIdCxJxwAAAAAAuAJAAIDDSbkD6ICqISDSEUk7wXXkSLiT4ABgsGe4bkg5Qgh11EmJCDPAw7hXAAeAw8xAU0iD7EBIi9lIjZHYAAAASItJCOhPAQAASIXAdQu4AQAAAEiDxEBbwzPJx0QkWAEAAABIjVQkaEiJTCRoSIlUJCBMjUt4M9JIiUwkYEiJTCQwiUwkUEiNS2hEjUIX/9CFwA+I7wAAAEiLTCRoSIXJD4ThAAAASIsBSI1UJFD/UBiFwA+IhQAAAEiLTCRoSI1UJGBIiwH/UDiFwHhxSItMJGBIhcl0bEiLAUiNVCQw/1AwhcB4WEiLTCQwSIXJdGZIjUNISIlLMEiJQyhMjUMoSI0Vyf7//0G5AwAAAEiJEEiNBdH9//9IiUNQSI1UJFhIiUNYSI0Fxf3//0iJQ2BIiwFIiVQkIItUJFD/UBhIi0wkYEiLVCQwSIXSdA5IiwJIi8r/UBBIi0wkYEiFyXQGSIsB/1AQSItMJGhIhcl0BkiLAf9QEItEJFj32BvAg+AESIPEQFvDuAQAAABIg8RAW8PMzMzMzMxIiVwkCEiJbCQQSIl0JBhIiXwkIEyL2kyL0UiFyXRwSIXSdGtIY0E8g7wIjAAAAAB0XYuMCIgAAACFyXRSRYtMCiBJjQQKi3AkTQPKi2gcSQPyi3gYSQPqD7YaRTPA/89BixFJA9I6GnUZD7bLSYvDSSvThMl0Lw+2SAFI/8A6DAJ08EH/wEmDwQREO8d20TPASItcJAhIi2wkEEiLdCQYSIt8JCDDSWPAD7cMRotEjQBJA8Lr28zMSIlcJAhIiWwkEEiJdCQYSIl8JCBBVkiD7EBIixlIjZGIAAAASIv5SIvL6Bn///9IjZfEAAAASIvLSIvw6Af///9IjZecAAAASIvLSIvo6PX+//9Mi/BIhfZ0ZUiF7XRgSIXAdFtEi08YSI0VoPv//0UzwEGNSAT/1kiL8EiFwHUFjUYC6z+LVxwzwEiLTxBFM8lIiUQkMEUzwMdEJCjIAAAAiUQkIP/VSIvOSIvYQf/WSIXbdQWNQwPrCotHIOsFuAEAAABIi1wkUEiLbCRYSIt0JGBIi3wkaEiDxEBBXsM="
      else
        shellcodeBase64 := "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGuemlKHZSNPq56cfWg+PFAB6ICqISDSEZPgAGCwZ7huU2V0V2luZG93c0hvb2tFeFcAAABVbmhvb2tXaW5kb3dzSG9va0V4AENhbGxOZXh0SG9va0V4AAAAAAAAU2VuZE1lc3NhZ2VUaW1lb3V0VwBDb0NyZWF0ZUluc3RhbmNlAAAAAFZX6MkCAACDfCQMAIvwi3wkFHwYhf90FItPCDtOEHUMVuhqAQAAg8QEiUYUjYaIAAAAUP826J4CAACDxAiFwHUFX17CDABX/3QkFP90JBRqAP/QX17CDAAzwMIEAMzMzIPsFFaLdCQchfZ1DLhXAAeAXoPEFMIIAItOBI1UJARSjVQkEMdEJAgAAAAAUosBagFq//90JDBR/1AUhcB4bIN8JAwAdGWDfCQEAHRei04EjVQkHFfHRCQgAAAAAFKLAVH/UCSL+IX/eC2LVCQghdJ0JYsCi0gQjUQkDFCNRghQ/3QkGP90JDBS/9GL+ItEJCBQiwj/UQiLRCQQUIsI/1EIi8dfXoPEFMIIALgBAAAAXoPEFMIIAMyLTCQIVot0JAiF9nRfhcl0W4tUJBCF0nRTiwELQQR1IYF5CMAAAAB1CYF5DAAAAEZ0MscCAAAAALgCQACAXsIMAIE5A+iAqnXpgXkEISDSEXXggXkIk+AAYHXXgXkMsGe4bnXOiTIzwF7CDAC4VwAHgF7CDADMzMyD7BBWi3QkGI2GsAAAAFD/dgToMQEAAIvIg8QIhcl1CI1BAV6DxBDDjUQkBMdEJAQAAAAAUI1GUMdEJBwAAAAAUGoXagCNRkDHRCQYAAAAAFDHRCQgAAAAAMdEJCQBAAAA/9GFwA+IywAAAItMJASFyQ+EvwAAAIsBjVQkDFdSUf9QDIXAeHCLTCQIjVQkHFJRiwH/UByFwHhdi0wkHIXJdFmLAY1UJAxSUf9QGIXAeEaLfCQMhf90UI1OMIl+HLjcAQAAiU4YA8aNVhiJAYvGBRwBAACNTCQUUYlGNIlGOLgkAQAAagMDxlL/dCQciUY8iwdX/1AMi0wkHItUJAyF0nQKiwJS/1AIi0wkHF+FyXQGiwFR/1AIi0wkBIXJdAaLAVH/UAiLRCQQ99heG8CD4ASDxBDDuAQAAABeg8QQw7gAAAAAw8zMg+wIU1VWV4t8JByF/w+EgQAAAItcJCCF23R5i0c8g3w4fAB0b4tEOHiFwHRni0w4JDP2i1Q4IAPPi2w4GAPXiUwkEItMOBwDz4lUJByJTCQUTYorixSyA9c6KnUTis2LwyvThMl0FIpIAUA6DAJ080Y79Xcfi1QkHOvZi0QkEItMJBQPtwRwiwSBA8dfXl1bg8QIw19eXTPAW4PECMPMzFNVVleLfCQUizeNR2BQVuhM////iUQkHI2HnAAAAFBW6Dv///+L2I1HdFBW6C////+LTCQsg8QYi+iFyXRshdt0aIXtdGSLxwWUAwAAiXgBuMQAAAD/dwwDx2oAUGoE/9GJRCQUhcB1DF9eXbgCAAAAW8IEAGoAaMgAAABqAGoAagD/dxD/dwj/0/90JBSL8P/VhfZ1Cl+NRgNeXVvCBACLRxRfXl1bwgQAX15duAEAAABbwgQA"
      len := StrLen(shellcodeBase64)
      shellcode := Buffer(len * 0.75)
      if !DllCall("crypt32\CryptStringToBinary", "str", shellcodeBase64, "uint", len, "uint", 1, "ptr", shellcode, "uint*", shellcode.Size, "ptr", 0, "ptr", 0)
        return
      return shellcode
    }

    static link(x64, shellcode, shellcodeBase, user32Base, combaseBase, hwnd, tid, msg, &pThreadProc, &pRect) {
      if x64 {
        NumPut("uint64", user32Base, shellcode, 0)
        NumPut("uint64", combaseBase, shellcode, 8)
        NumPut("uint64", hwnd, shellcode, 16)
        NumPut("uint", tid, shellcode, 24)
        NumPut("uint", msg, shellcode, 28)
        pThreadProc := shellcodeBase + 0x4e0
        pRect := shellcodeBase + 56
      }
      else {
        NumPut("uint", user32Base, shellcode, 0)
        NumPut("uint", combaseBase, shellcode, 4)
        NumPut("uint", hwnd, shellcode, 8)
        NumPut("uint", tid, shellcode, 12)
        NumPut("uint", msg, shellcode, 16)
        pThreadProc := shellcodeBase + 0x43c
        pRect := shellcodeBase + 32
      }
    }

    static msgWaitForSingleObject(handle) {
      while 1 == res := DllCall("MsgWaitForMultipleObjects", "uint", 1, "ptr*", handle, "int", false, "uint", -1, "uint", 7423) { ; QS_ALLINPUT := 7423
        msg := Buffer(A_PtrSize == 8 ? 48 : 28)
        while DllCall("PeekMessageW", "ptr", msg, "ptr", 0, "uint", 0, "uint", 0, "uint", 1) { ; PM_REMOVE := 1
          DllCall("TranslateMessage", "ptr", msg)
          DllCall("DispatchMessageW", "ptr", msg)
        }
      }
      return res
    }
  }

  static guidFromString(str) {
    DllCall("ole32\CLSIDFromString", "str", str, "ptr", buf := Buffer(16), "hresult")
    return buf
  }

  static getRect(buf, &left, &top, &right, &bottom) {
    left := NumGet(buf, 0, "int")
    top := NumGet(buf, 4, "int")
    right := NumGet(buf, 8, "int")
    bottom := NumGet(buf, 12, "int")
  }

  static getWindowScale(hwnd) {
    if winDpi := DllCall("GetDpiForWindow", "ptr", hwnd, "uint")
      return A_ScreenDPI / winDpi
    return 1
  }

  static scaleRect(scale, &left, &top, &right, &bottom) {
    left := Round(left * scale)
    top := Round(top * scale)
    right := Round(right * scale)
    bottom := Round(bottom * scale)
  }

  static clientToScreenRect(hwnd, &left, &top, &right, &bottom) {
    w := right - left
    h := bottom - top
    pt := left | top << 32
    DllCall("ClientToScreen", "ptr", hwnd, "int64*", &pt)
    left := pt & 0xffffffff
    top := pt >> 32
    right := left + w
    bottom := top + h
  }
}

/**
 * Мигающий курсор существует?
 * Курсор в текстовом поле?
 * @returns {Integer} - true - если курсор в поле, false - если нет.
 */
CaretExist() {
    local x := 0
    local y := 0
    ; CaretGetPos() - в статус баре в хроме не работает. 
    ; Возвращает 0, когда курсор в поле.
    if (CaretGetPos(&x, &y)){
      ; Debug.log("CaretGetPos() = 1")
      return true
    }

    static OBJID_CARET:= 0xFFFFFFF8
    static IID_IAccessible:= guidFromString("{618736e0-3c3d-11cf-810c-00aa00389b71}")
    
    hwnd:= WinExist("A")
    if !hOleacc:= DllCall("LoadLibraryW", "str", "oleacc.dll", "ptr")
        return false
    hOleacc:= { Ptr: hOleacc, __Delete: (_) => DllCall("FreeLibrary", "ptr", _) }
    
    if !DllCall("oleacc\AccessibleObjectFromWindow", 
               "ptr", hwnd, "uint", OBJID_CARET, 
               "ptr", IID_IAccessible.Ptr, "ptr*", accCaret:= ComValue(13, 0), "int") {
        
        if accCaret.Ptr {
            if A_PtrSize == 8 {
                varChild:= Buffer(24, 0)
                NumPut("ushort", 3, varChild)  ; VT_I4
                hr:= ComCall(22, accCaret, 
                              "int*", &x:= 0, 
                              "int*", &y:= 0, 
                              "int*", &w:= 0, 
                              "int*", &h:= 0, 
                              "ptr", varChild, 
                              "int")
            } else {
                hr:= ComCall(22, accCaret, 
                              "int*", &x:= 0, 
                              "int*", &y:= 0, 
                              "int*", &w:= 0, 
                              "int*", &h:= 0, 
                              "int64", 3,    ; VT_I4
                              "int64", 0,    ; CHILDID_SELF
                              "int")
            }
            if !hr {
                return true
            }
        }
    }
    return false

    guidFromString(str) {
        DllCall("ole32\CLSIDFromString", "str", str, "ptr", buf:= Buffer(16), "hresult")
        return buf
    }
}




/**
 * Отправляет клавишу, пока клавиша удерживается.
 * С интервалом/скоростью sleepTimeout.
 * @param key 
 * @param {Integer} sleepTimeout - Не нужно указывать меньше 23. (Или будет
 * очень быстрое перемещение курсора).Это стандартно.
 */
sendKeyUntilItWillBeRelease(key, sleepTimeout := 23){
  while GetKeyState(key, "P"){
    ; Обязательно SendEvent, или клавиша key залипает.
    SendEvent "{" . key . "}"
    timeFromCtrlPress := A_TickCount
    Sleep sleepTimeout
  }
}
