
/************************************************************************
 * @description Содержит стек кручения колеса. Время кручения. И функция
 * ожидания остановки колеса.
 * @author 
 * @date 2024/12/14
 * @version 0.0.0
 ***********************************************************************/

Class Wheel {
  ; Время последнего клика колеса
  ; lastTimeWheel: A_TickCount,
  clickTime := A_TickCount

  ; Массив кликов колеса вниз, для управления колеса программно через Send.
  ; Содержит массив из значений 1 (1,1,...).
  ; WheeldownStack: [],
  downStack := []

  ; Массив кликов колеса вверх.
  ; WheelupStack: []
  upStack := []

  ; Массив 2-ух последних времён кликов колеса.
  timeStack := []

  ; Вызывается на каждом клике колеса.
  ; Устанавливает время клика.
  ; ||..|......Check
  ; setLastTimeWheel() {
  setClickTime(*) {
    this.clickTime := A_TickCount
    this.timeStack.Push(this.clickTime)
    if(this.timeStack.Length > 2){
      this.timeStack.RemoveAt(1)
    }
  }

  /**
   * Скорость кручения колеса. 
   * Число миллисекунд между двумя последними кликами.
   * Самая высокая скорость 0 - 16.
   * Возвращает 2000 на первом клике.
   * Значение больше 400 - значит колесо на время остановилось.
   * Должно вызываться после клика колеса.
   * @returns {Integer | Number} 
   */
  getSpeed(){
    if(this.timeStack.Length < 2){
      return 2000
    }
    return this.timeStack[2] - this.timeStack[1]
  }

  ; Добавляет в массив клик колеса.
  ; setWheelDown() {
  _down() {
    this.downStack.Push("1")
  }

  ; setWheelUp() {
  _up() {
    this.upStack.Push("1")
  }

  ; Для программного управления колеса.
  ; Сохраняет клики колеса, и время последнего клика.
  ; Это должно быть в конце скрипта, чтобы установить #MaxThreadsPerHotkey, 2.
  ; WheelDownLabel(*){
  down() {
    this._down()
    this.setClickTime()
    ; this.fastSlowCallbacks_down()

  }

  ; WheelUpLabel
  up() {
    this._up()
    this.setClickTime()
    ; this.fastSlowCallbacks_up()
  }

  ; TODO: Error. Не нужно устанавливать - #MaxThreadsPerHotkey 1
  ; Если установить здесь #MaxThreadsPerHotkey 1, то функции
  ; Ctrl+Win+колесо перестают работать правильно.
  ; #MaxThreadsPerHotkey 1

  ; Ожидает остановки колеса.
  ; timeLimit - сколько миллисекунд нужно от последнего клика,
  ; чтобы считать что колесо остановилось.
  waitWheelStop(timeLimit := 120) {
    local timeToLastClickWheel
    Loop {
      timeToLastClickWheel := A_TickCount - this.clickTime
      ; TTip("timeToLastClickWheel = " timeToLastClickWheel, 30, 40)
      Sleep(1)
    } Until (timeToLastClickWheel > timeLimit)
    ; Until (False) - продолжает цикл.
    ; Когда станет True - выходит.
    return true
  }


  ; ----------------------------------------------------------

  class FastSlow{
    ; Определять только скорость кручения колеса сравнивая два последних
    ; значения, может быть ошибочно.
    ; Это может быть быстрое кручение, когда кручение медленное.
    ; Нужно оценивать группу кликов. Всё кручение колеса, до остановки колеса.
    ; Группа кликов быстрого кручения, должна занимать не много времени.
    ; Для проверки что группа кликов завершила кручение, вызывается таймер.

    ; Изначально счётчик устанавливается на ноль.
    ; Когда будет клик, это записывает время клика в массив кликов. 
    ; И вызывает таймер.
    ; Таймер слушает клики до остановки колеса, и принимает решение, 
    ; было ли это быстрое кручение, или обычное, или медленное, один клик.
    ; Когда колесо остановилось, массив кликов очищается, счётчик обнуляется.

    ; Куда крутится сейчас колесо?
    ; "down", "up".
    wheelUpOrDown := 0

    ; Колбэк который вызывается после завершения кручения колеса.
    ; Это принимает аргумент со свойствами:
    ; {
      ; upDown: "down"|"up"
      ; type: "slow"|"medium"|"quick" 
      ; Если type = "medium"|"quick", то ещё и следующие свойства:
      ; speedAverage: speedAverage,
      ; timeOfClickGroup: timeOfClickGroup,
      ; countClicks: this.wheelStack.clicks.Length,
    ; }
    callback_GroupWheel := 0
    ; Колбэк который вызывается сразу при кручении колеса.
    callback_Wheel := 0
    ; Функция таймера  слушающего остановку колеса.
    clickListener_Timer_function := {}

    /**
     * Устанавливает колбэк который срабатывает при остановке колеса.
     * @param callback Колбэк должен принимать один аргумент. Это объект
     * со свойствами группы кликов.
     */
    setCallback_GroupWheel(callback){
      this.callback_GroupWheel := callback
    }

    /**
     * Устанавливает колбэк который срабатывает на каждом клике.
     * @param callback Колбэк должен принимать один аргумент. Это объект
     * со свойствами клика.
     */
    setCallback_Wheel(callback){
      this.callback_Wheel := callback
    }

    ; Счётчик кликов.
    ; Группа кликов, до остановки колеса.
    ; Это может быть один клик, или несколько.
    wheelStack := {
      ; Время старта группы кликов.
      timeStart: 0,
      ; Клики колеса.
      clicks: [{
        ; Время клика.
        time: 0,
        ; Скорость, в сравнении с предыдущим кликом.
        ; Разница в миллисекундах.
        speed: 1000
      }]
    }

    ; Обнуляет счётчик кликов.
    clearWheelStack(){
      this.wheelStack := {
        ; Время старта группы кликов.
        timeStart: 0,
        ; Клики колеса.
        clicks: [{
          ; Время клика.
          time: 0,
          ; Скорость, в сравнении с предыдущим кликом.
          ; Разница в миллисекундах.
          speed: 1000
        }]
      }
    }


    down(){
      ; Debug().logF( "down()" )
      ; Обнуляем счётчик, если колесо начало крутится в обратном направлении.
      if(this.wheelUpOrDown == "up"){
        this.clearWheelStack()
      }
      this.wheelUpOrDown := "down"
      this.wheelClick()
    }

    up(){
      ; Обнуляем счётчик, если колесо начало крутится в обратном направлении.
      if(this.wheelUpOrDown == "down"){
        this.clearWheelStack()
      }
      this.wheelUpOrDown := "up"
      this.wheelClick()
    }

    ; Вызывается на каждом клике.
    ; Это добавляет клик в стэк, и вызывает таймер для проверки остановки колеса.
    wheelClick(){

      local timeNow := A_TickCount

      ; Время предыдущего клика.
      local prevClickTime := this.wheelStack.clicks[this.wheelStack.clicks.Length].time
      ; Время между двумя последними кликами.
      local speedTimeDistance := timeNow - prevClickTime

      ; Если кликов ещё не было, это первый клик.
      if(prevClickTime == 0){
        speedTimeDistance := 1000
      }

      ; Вызываем колбэк обычного клика.
      local clickArgs := {upDown: this.wheelUpOrDown, speed: speedTimeDistance}
      if(this.callback_Wheel != 0){
        SetTimer (*) => this.callback_Wheel(clickArgs), -1
      }

      ; Если это первый клик.
      ; Стартует таймер для проверки остановки колеса.
      if(this.wheelStack.timeStart == 0){
        this.wheelStack.timeStart := timeNow
        this.wheelStack.clicks := []
        this.clickListener_Timer_function := () => this.clickListener_Timer()
        SetTimer this.clickListener_Timer_function, 2
      }

      ; Записываем клик в массив кликов.
      local click := {
          ; Время клика.
          time: timeNow,
          ; Скорость, в сравнении с предыдущим кликом.
          ; Разница в миллисекундах.
          speed: speedTimeDistance
      }
      this.wheelStack.clicks.Push(click)

    }


    /**
     * Таймер, слушает когда колесо остановится.
     * Вызывается постоянно, и ждёт пока время от последнего клика 
    ;  будет больше таймаута, тогда будет считаться что колесо остановилось.
     */
    clickListener_Timer(){
      ; Время сейчас.
      local timeNow := A_TickCount
      ; Время последнего клика.
      local prevClickTime := this.wheelStack.clicks[this.wheelStack.clicks.Length].time
      ; Время между двумя последними кликами.
      local speedTimeDistance := timeNow - prevClickTime

      ; Когда считать что колесо остановилось?
      ; 60
      if(speedTimeDistance > 40){

        SetTimer this.clickListener_Timer_function, 0

        ; Это один клик, самое медленное кручение.
        if(this.wheelStack.clicks.Length == 1){
          if(this.callback_GroupWheel != 0){
            local args := {type: "slow", upDown: this.wheelUpOrDown}
            SetTimer () => this.callback_GroupWheel(args), -1
          }
        }else{
          ; Это несколько кликов кручения.
          ; Время от начала кручения колеса, до остановки.
          local timeOfClickGroup := prevClickTime - this.wheelStack.timeStart
          ; Сумма всех скоростей.
          local sumSpeed := 0
          for _, click in this.wheelStack.clicks{
            if(click.speed >= 1000){
              continue
            }
            sumSpeed := sumSpeed + click.speed
          }
          ; Средняя скорость кручения.
          local speedAverage := sumSpeed / this.wheelStack.clicks.Length
          local args := {
            speedAverage: speedAverage,
            timeOfClickGroup: timeOfClickGroup,
            countClicks: this.wheelStack.clicks.Length,
            upDown: this.wheelUpOrDown,
          }
 
          local isQuick := true

          ; Было два клика.
          if(this.wheelStack.clicks.Length == 2){
            ; isQuick := false
            ; if(timeOfClickGroup > 49){
            ;   isQuick := false
            ; }
            ; 16, >=24
            if(speedAverage > 16){
              isQuick := false
            }
          }

          ; Было больше чем два клика.
          if(this.wheelStack.clicks.Length > 2){
            ; if(timeOfClickGroup > 76){
            ;   isQuick := false
            ; }
            ; 37, 26
            if(speedAverage > 18){
              isQuick := false
            }
          }
          
          if(isQuick){
            args.type := "quick"
            ; Debug().logF("QUICK")
          }else{
            ; Debug().logF("Medium")
            args.type := "medium"
          }

          if(this.callback_GroupWheel != 0){
            SetTimer () => this.callback_GroupWheel(args), -1
          }
        }

        this.clearWheelStack()

      }

    } ; clickListener_Timer

    ; ---------------------------------------------------------
    ; EXAMPLES:
    ; fastSlow_ := Wheel.FastSlow()
    ; fastSlow_.setCallback_GroupWheel(groupWheelCallback)
    ; fastSlow_.setCallback_Wheel(wheelCallback)

    ; groupWheelCallback(fastSlow, args){
    ;   Debug().logF("groupWheelCallback()")
    ;   Debug().logF(args)
    ; }

    ; wheelCallback(fastSlow, args){
    ;   Debug().logF("callback_Wheel()")
    ; }

    ; Hotkey("*WheelDown", (*) => fastSlow_.down(), "On")
    ; Hotkey("*WheelUp", (*) => fastSlow_.up(), "On")

  } ; class FastSlow

} ; class Wheel