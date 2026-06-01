

; Этот класс должен создаваться только один раз, в начале скрипта.
; WinEvent WinTitle - не распознаёт заголовков где есть слово File.
; И слушание окон отключается.
class RememberWindowsSizes {

  ; Файл json запомненных окон.
  jsonPath := config.appDataDir  . "/rememberedWindows.json"
  ; Map() из файла json, где ключи - это окна (текст ahk_class).
  ; {"#32200": {width: 200, height: 100}, ...}
  ; {"ahk_class": [
  ;   {exe: "", title: "", width: 200, height: 100, x: 0, y: 0},
  ;   {exe: "", title: "Open", width: 200, height: 100, x: 0, y: 0},
  ; ]
  rememberedWindows := {}
  ; Объект активного окна, свойства: ahk_class, ahk_title.
  activeWindow := {ahk_class: "", ahk_title : "", ahk_exe: ""}
  gui := {}

  resize_Callback_func := {}
  stopResize_Callback_func := {}
  moveEnd_Callback_func := {}
  close_Callback_func := {}

  __new(){
    local json := ConfigReader.get(this.jsonPath, true)
    if(json){
      this.rememberedWindows := json
      ; Включаем слушать все окна.
      for ahk_class, rememberedWindowsOfClass in this.rememberedWindows.OwnProps(){
        ; rememberedWindowOfClass - окно определённого класса.
        for _, rememberedWindowOfClass in rememberedWindowsOfClass{
          this.startListenCreate(rememberedWindowOfClass.listenString)
        }
      }
    }

    this.resize_Callback_func := ObjBindMethod(this, "resize_Callback")
    this.stopResize_Callback_func := ObjBindMethod(this, "stopResize_Callback")
    this.moveEnd_Callback_func := ObjBindMethod(this, "moveEnd_Callback")
    this.close_Callback_func := ObjBindMethod(this, "close_Callback")

  }

  ; Открывает Gui, получает данные об активном окне.
  ; Ищет в файле.
  openGui() {

    try{
      this.activeWindow.ahk_id := WinGetID("A")
      this.activeWindow.ahk_title := WinGetTitle("A")
      this.activeWindow.ahk_class := WinGetClass("A")
      this.activeWindow.ahk_exe := WinGetProcessName("A")
    }catch{
      return false
    }

    ; https://www.autohotkey.com/docs/v2/lib/Gui.htm#Appear
    ; iconsize := 32  ; Ideal size for alt-tab varies between systems and OS versions.
    ; hIcon := LoadPicture("My Icon.ico", "Icon1 w" iconsize " h" iconsize, &imgtype)
    ; MyGui := Gui()
    ; SendMessage(0x0080, 1, hIcon, MyGui)  ; 0x0080 is WM_SETICON; and 1 means ICON_BIG (vs. 0 for ICON_SMALL).
    ; MyGui.Show()

    local options := "+Resize -DPIScale"
    this.gui := Gui(options, "Remembering window sizes", )
    ; Bahnschrift
    this.gui.SetFont("s17", "Trebuchet MS")
    this.gui.MarginY := 8

    local width := "w730"

    ; Совпавшее окно в запомненных окнах.
    ; false - если  не найдено.
    ; Объект вида:
    ; {index: index, rating: rating, window: rememberedWindow}
    local windowFromRememberedList := this.windowExist(
      this.activeWindow.ahk_title,
      this.activeWindow.ahk_class, 
      this.activeWindow.ahk_exe
    )

    ; MsgBox this.activeWindow.ahk_title

    ; this.gui.MarginY := 0
    local text := "This window "
    if(windowFromRememberedList){
      text .= "already exists. Update window size?"
    } else{
      text .= "is not yet in the list. Remember this window?"
    }
    local textElement1 := this.gui.Add("Text", width . "" , text)

    ; Флажок class.
    local class_CheckboxControl := this.gui.Add(
      "CheckBox", 
      "y+20", 
      "Class: " . this.activeWindow.ahk_class
    )
    class_CheckboxControl.Enabled := 0
    class_CheckboxControl.value := 1

    ; Флажок exe.
    local exe_CheckboxControl := this.gui.Add("CheckBox", "", this.activeWindow.ahk_exe)
    ; Отмечаем флажок, если такое окно уже есть в списке, и установлен exe.
    if(windowFromRememberedList && windowFromRememberedList.window.exe){
      exe_CheckboxControl.value := 1
    }

    ; Флажок Title.
    ; local title_TextControl := this.gui.Add("Text", "w100", "Title: ")
    local title_CheckboxControl := this.gui.Add("CheckBox", "", "")
    ; Отмечаем флажок, если такое окно уже есть в списке, и установлен заголовок.
    if(windowFromRememberedList && windowFromRememberedList.window.title){
      title_CheckboxControl.value := 1
    }
    ; Нажатие на флажок.
    title_CheckboxControl.OnEvent("Click", title_CheckboxControl_changeCallback)
    title_CheckboxControl_changeCallback(*){
      if(title_CheckboxControl.value){
        title_EditControl.Enabled := 1
      }else{
        title_EditControl.Enabled := 0
      }
    }
    ; Title текстовое поле.
    if(windowFromRememberedList){
      ; Такое окно уже есть в списке.
      local title_EditControl := this.gui.Add("Edit", "R1 w600 xp20 yp", windowFromRememberedList.window.title)
    }else{
      ; Такого окна ещё нет в списке.
      ; R1 - только одна строка.
      local title_EditControl := this.gui.Add("Edit", "R1 w600 xp20 yp", this.activeWindow.ahk_title)
      title_EditControl.Enabled := 0
    }

    ; Флажок Remember position.
    local rememberPosition_CheckboxControl := this.gui.Add("CheckBox", "xm0", "Remember position on screen")
    if(windowFromRememberedList && windowFromRememberedList.window.rememberPosition){
      rememberPosition_CheckboxControl.value := 1
    }

    ; Флажок remember on close.
    local rememberOnClose_CheckboxControl := this.gui.Add("CheckBox", "", "Remember on close")
    if(windowFromRememberedList && windowFromRememberedList.window.rememberOnClose){
      rememberOnClose_CheckboxControl.value := 1
    }

    local text2 .= "Check the boxes above to limit the scope of the window's match. For the title (checkbox 3), you can specify only one word, not the entire title text. `nThe next time you open this window, it will open with the same sizes as now."
    local textElement2 := this.gui.Add("Text", width . " y+30", text2)
    textElement2.SetFont("s13", "Bahnschrift")

    if(windowFromRememberedList){
      ; Default - фокус устанавливается на эту кнопку. 
      local updateWindowButton := this.gui.Add("Button", "Default " . width . " y+-40" , "Update")
      updateWindowButton.OnEvent("Click", addWindow_ClickCallback)  
    }else{
      local addWindowButton := this.gui.Add("Button", "Default " . width . " y+-40" , "Remember")
      addWindowButton.OnEvent("Click", addWindow_ClickCallback) 
    }

    addWindow_ClickCallback(args*){
      local selectedItems := getValues()
      if(selectedItems == false){
        return
      }
      this.addWindow_ClickCallback(selectedItems, windowFromRememberedList)
    }

    if(windowFromRememberedList){
      local removeActiveWindowButton := this.gui.Add("Button", width, "Remove active window")
      removeActiveWindowButton.OnEvent("Click", removeActiveWindow_ClickCallback)  

      removeActiveWindow_ClickCallback(*){
        this.removeActiveWindow_ClickCallback(windowFromRememberedList)
      }
    }

    local removeAllButton := this.gui.Add("Button", width, "Remove all windows")
    removeAllButton.OnEvent("Click", (*) => this.removeAllWindows_ClickCallback())  

    this.gui.OnEvent("Escape", (*) => this.gui.Destroy())
    this.gui.Show("y40 h900")

    ; -------------------------------------------------------------------

    ; Возвращает объект значений флажков, и полей.
    ; Или false если указанные значения не допустимы.
    getValues(){

      ; Какие флажки отмечены, дефаулт значения.
      local selectedItems := {
        class: this.activeWindow.ahk_class,
        exe: "",
        title: "",
        rememberOnClose: 0,
        rememberPosition: 0
      }
      
      if(exe_CheckboxControl.value){
        selectedItems.exe := this.activeWindow.ahk_exe
      }

      if(title_CheckboxControl.value){
        title_EditControl.value := Trim(title_EditControl.value)
        if(title_EditControl.value == ""){
          MsgBox "You cannot check the box and specify an empty value for the Title."
          return false
        }
        if(this.activeWindow.ahk_title && !InStr(this.activeWindow.ahk_title, title_EditControl.value)){
          MsgBox "The specified text in the Title field was not found in the window title. The specified text must be present in the window title."
          return false
        }
        selectedItems.title := title_EditControl.value
      }

      if(rememberOnClose_CheckboxControl.value){
        selectedItems.rememberOnClose := 1
      }

      if(rememberPosition_CheckboxControl.value){
        selectedItems.rememberPosition := 1
      }
      
      return selectedItems
    }

  }

  ; Окно существует в списке запомненных окон?
  ; Поступают значения окна.
  ; Возвращает самое соответствующее окно, объект:
  ; {index: index, rating: 0, window: rememberedWindow}
  windowExist(window_title, window_class, window_exe){

    ; Такого ahk_class не существует в запомненных окнах.
    if(this.rememberedWindows.HasOwnProp(window_class) == false){
      return false
    }

    ; Массив запомненных окон, определённого класса ahk_class.
    local rememberedWindowsOfClass := this.rememberedWindows[window_class]

    local ratingWindows := []
    ; Перебираем массив запомненных окон, определённого класса.
    ; И находим самое соответствующее окно.
    ; Самое соответствующее окно, это - совпадает exe, и больше длина заголовка.
    ; Окно не соответствует если: существует запомненный заголовок, 
    ; и такой заголовок не совпадает.
    ; Существует запомненный exe, и такой exe не совпадает.
    ; Если не существует запомненного заголовка, то совпадает.
    ; Если не существует запомненного exe, то совпадает.
    for index, rememberedWindow in rememberedWindowsOfClass{
      ; 0 - означает что окно не совпадает.
      ; 1 - окно совпадает только в ahk_call, и там не определены Title,
      ; или Exe.
      local rating := 1

      ; У запомненного окна exe существует.
      if(rememberedWindow.exe && window_exe){
        ; Exe активного окна window_exe, равно exe запомненного окна.
        if(window_exe == rememberedWindow.exe){
          rating := rating + 1000
        }else{
          ; exe не совпало.
          ; Значит это окно не совпадает.
          ratingWindows.Push({index: index, rating: 0, window: rememberedWindow})
          continue
        }
      }

      ; У запомненного окна title существует.
      if(rememberedWindow.title && window_title){
        ; Title совпало.
        if(InStr(window_title, rememberedWindow.title)){
          rating := rating + StrLen(rememberedWindow.title)
        }else{
          ; Title не совпало.
          ; Значит это окно не совпадает.
          ratingWindows.Push({index: index, rating: 0, window: rememberedWindow})
          continue
        }
      }

      ; Окно совпадает.
      ; Записываем рэйтинг.
      ratingWindows.Push({index: index, rating: rating, window: rememberedWindow})
    }

    ; Находим окно с большим рейтингом.
    local matchedWindow := ratingWindows[1]
    for _, ratingWindow in ratingWindows{
      if(matchedWindow.rating < ratingWindow.rating){
        matchedWindow := ratingWindow
      }
    }

    if(matchedWindow.rating == 0){
      return false
    }else{
      return matchedWindow
    }

  }

  /**
   * Вызывается при нажатии на кнопку Remember or Update.
   * Добавляет окно к запомненным, и записывает в файл.
   * @param newTitle - Текст из поля Title.
   * @param newExe - Текст из поля Exe.
   * @param oldRememberedWindow - Если равно false, значит это новое окно.
   * Или это объект со свойствами: index, window.
   * index - индекс прежднего окна в массиве запомненных окон.
   * window - объект окна.
   * @returns {Integer} 
   */
  addWindow_ClickCallback(values, oldRememberedWindow){
  ; values:
    ; class: this.activeWindow.ahk_class,
    ; exe: "",
    ; title: "",
    ; rememberOnClose: 0,
    ; rememberPosition: 0

    try{
      WinGetPos(&x, &y, &width, &height, "ahk_id " . this.activeWindow.ahk_id)
    }catch{
      return false
    }
 
    values.x := x
    values.y := y
    values.width := width
    values.height := height

    values.listenString := ""
    if(values.title){
      values.listenString .= values.title . " "
    }
    values.listenString .= "ahk_class " . values.class
    if(values.exe){
      values.listenString .= " ahk_exe " . values.exe
    }

    ; Это новое окно.
    if(oldRememberedWindow == false){
      if(this.rememberedWindows.HasOwnProp(this.activeWindow.ahk_class)){
        this.rememberedWindows[this.activeWindow.ahk_class].Push(values)
      }else{
        local newAhkClassWindows := []
        newAhkClassWindows.Push(values)
        this.rememberedWindows[this.activeWindow.ahk_class] := newAhkClassWindows
      }
    }else{
      ; Это уже существующее окно.
      ; Обновляем записи этого окна в массиве.
      local activeWindow := this.rememberedWindows[this.activeWindow.ahk_class][oldRememberedWindow.index]
      this.stopListenCreate(activeWindow.listenString)
      Utils.updateObject(activeWindow, values)
    }

    ConfigReader.set(this.rememberedWindows, this.jsonPath)
    this.gui.Destroy()
    this.startListenCreate(values.listenString)

    if(!values.rememberPosition){
      WinEvent.Stop("MoveEnd", values.listenString)
    }
    if(!values.rememberOnClose){
      WinEvent.Stop("Close", values.listenString)
    }

    this.createCallback(this.activeWindow.ahk_id)
  }


  ; Убирает активное окно из запомненных, и из файла.
  removeActiveWindow_ClickCallback(windowFromRememberedList){
    this.stopListenCreate(this.rememberedWindows[this.activeWindow.ahk_class][windowFromRememberedList.index].listenString)
    this.rememberedWindows[this.activeWindow.ahk_class].RemoveAt(windowFromRememberedList.index)
    if(this.rememberedWindows[this.activeWindow.ahk_class].Length == 0){
      this.rememberedWindows.DeleteProp(this.activeWindow.ahk_class)
    }
    ConfigReader.set(this.rememberedWindows, this.jsonPath)
    this.gui.Destroy()
  }


  ; Убирает все окна из запомненных, и из файла.
  removeAllWindows_ClickCallback(){
    this.rememberedWindows := {}
    ConfigReader.set(this.rememberedWindows, this.jsonPath)
    this.gui.Destroy()
    this.stopListenCreateAll()
  }


  startListenCreate(winTitle){
    local createCallback := ObjBindMethod(this, "createCallback")
    ; Show, а не Create, потому-что Create не распознаёт заголовок WinTitle,
    ; который ещё не был создан.
    WinEvent.Show(createCallback, winTitle)
  }

  stopListenCreate(winTitle){
    WinEvent.Stop("Show", winTitle)
  }

  stopListenCreateAll(){
    WinEvent.Stop("Show")
  }

  /**
   * Когда окно создаётся, то вызывается этот колбэк. 
   * @param hWnd - Окно которое создаётся.
   * @param eventObj 
   * @param dwmsEventTime 
   * @param args 
   */
  createCallback(hWnd, eventObj := "", dwmsEventTime := "", args*){

    local timeCallCreateCallback := A_TickCount

    ; Ждём когда окно откроется.
    local targetWindow := WinWait("ahk_id " . hWnd, , 2)
    if(targetWindow == 0){
      return
    }
    
    try{
      local ahk_title := WinGetTitle("ahk_id " . hWnd)
      local ahk_class := WinGetClass("ahk_id " . hWnd)
      local ahk_exe := WinGetProcessName("ahk_id " . hWnd)
    }catch{
      return
    }

    ; Находим самое соответствующее окно в списке.
    local matchedWindow_withIndex := this.windowExist(ahk_title, ahk_class, ahk_exe)
    if(matchedWindow_withIndex == false){
      return
    }

    ; class: this.activeWindow.ahk_class,
    ; exe: "",
    ; title: "",
    ; rememberOnClose: 0,
    ; rememberPosition: 0
    local matchedWindow := matchedWindow_withIndex.window
    if(matchedWindow.rememberPosition){
      windowMove(true)
    }else{
      windowMove(false)
    }

    local x := matchedWindow.x
    local y := matchedWindow.y
    local width := matchedWindow.width
    local height := matchedWindow.height

    ; Стартуется когда завершено перемещение окна, или изменение размеров.
    ; Move, а не MoveEnd, потому-что MoveEnd не распознаёт программное перемещение,
    ; а только через заголовок. 
    WinEvent.Move(moveEnd_Callback, "ahk_id " . hWnd)
    moveEnd_Callback(hWnd, eventObj, dwmsEventTime, args*){
      ; Если программа при отрытии изменит размер, то исправим:
      if(A_TickCount - timeCallCreateCallback < 2000){      
        if(matchedWindow.rememberPosition){
          windowMove(true)
        }else{
          windowMove(false)
        }
      }
      WinGetPos(&x, &y, &width, &height, "ahk_id " . hWnd)
    }

    ; При закрытии, записываем положение окна.
    WinEvent.Close(close_Callback, "ahk_id " . hWnd)
    close_Callback(hWnd, eventObj, dwmsEventTime, args*){
      WinEvent.Stop("Move", "ahk_id " . hWnd)
      WinEvent.Stop("Close", "ahk_id " . hWnd)
      if(matchedWindow.rememberOnClose){
        if(matchedWindow.rememberPosition){
          matchedWindow.x := x
          matchedWindow.y := y
        }
        matchedWindow.width := width
        matchedWindow.height := height
        ConfigReader.set(this.rememberedWindows, this.jsonPath)
      }
    }

    ; -------------------------------------------------------------------
    windowMove(includePosition := false){
      if(includePosition){
        WinMove(
          matchedWindow.x, 
          matchedWindow.y,
          matchedWindow.width, 
          matchedWindow.height, 
          "ahk_id " . hWnd
        )
      }else{
        WinMove(
          , 
          ,       
          matchedWindow.width, 
          matchedWindow.height, 
          "ahk_id " . hWnd
        )
      }
    }


  }

  resize_Callback(hWnd, eventObj, dwmsEventTime, args*){
    
  }

  stopResize_Callback(hWnd, eventObj, dwmsEventTime, args*){
    
  }

  moveEnd_Callback(hWnd, eventObj, dwmsEventTime, args*){
    
  }

  close_Callback(hWnd, eventObj, dwmsEventTime, args*){
    
  }


}