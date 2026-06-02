
class VectorsDegree {
  
  static getZone4From360_function := VectorsDegree.getZone4From360_standard

  /**
   * Возвращает номер зоны: 1,2,3,4 | -1,-2,-3,-4.
   * @param {Number} deg - Градус от 0 до 360.
   */
  static getZone4From360(degree){
    return VectorsDegree.getZone4From360_function(degree)
  }

  /**
   * Устанавливает функцию getZone4From360().
   * @param func 
   */
  static setFunction_getZone4From360(func){
    VectorsDegree.getZone4From360_function := func
  }

  /**
   * JavaScript функция Math.atan2().
   * https://autohotkey.com/board/topic/88476-vincenty-formula-for-latitude-and-longitude-calculations/
   */
  static ATan2(X, Y){
    return (DllCall('msvcrt.dll\atan2', 'Double', Y, 'Double', X, 'Cdecl Double'))
  }

  /**
   * Возвращает градусы координаты точки, от 0 до 180, и -180.
   * Движение на круге - справа, вверх, влево - положительное. 
   * Движение на круге справа, вниз, влево - отрицательное.
   * @param x - Вправо - положительное, влево - отрицательное.
   * @param y - Вниз - положительное, вверх - отрицательное.
   */
  static getDegree180(x, y) {
    y := y * -1
    local rad := VectorsDegree.ATan2(x, y)
    local deg := rad * (180 / 3.141592653589793)
    return deg
  }

  /**
   * Возвращает градусы координаты точки, от 0 до 360.
   * Движение на круге - справа, вверх, влево, вниз, и обратно.
   * @param x - Координата точки x. Вправо - положительное, влево - отрицательное.
   * 
   * @param y - Координата точки y. Вниз - положительное, вверх - отрицательное.
   * ; 10, 0 - 0
   *   ; 10, -10 - 45
   *   ; 0, -10 - 90
   *   ; -10, -10 - 135
   *   ; -10, 0 - 180
   *   ; -10, 10 - 225
   *   ; 0, 10 - 270
   *   ; 10, 10 - 180 + 90 + 45 = 315
   * Зоны: 0, 45, 90, 135, 180, 225, 270, 315, 360/0. 
   */
  static getDegree360(x, y) {
    y := y * -1
    local rad := VectorsDegree.ATan2(x, y)
    local deg := rad * (180 / 3.141592653589793)
    return Mod(((Mod(deg, 360)) + 360), 360)
  }

  /**
   * Возвращает наименьшее расстояние между двумя точками на круге, в градусах 360.
   * @param degPrev - Предыдущая точка в градусах 360.
   * @param degNow - Активная точка в градусах 360.
   * @returns {Number} 
   */
  static getDistance360BetweenDegrees(degPrev, degNow){
    ; Найти самую ближайшую к нулю точку.
    local closerToZero := 0
    local furtherFromZero := 0
    if(degNow < degPrev){
      closerToZero := degNow
      furtherFromZero := degPrev
    }else{
      closerToZero := degPrev
      furtherFromZero := degNow
    }
    ; Вычисляем два расстояния от одной точки до другой, в градусах.
    ; В одну сторону круга, и в другую сторону круга.

    ; В сторону меньше нуля, вниз
    local rightDist := closerToZero + (360 - furtherFromZero)
    ; В сторону больше нуля, вверх
    local leftDist := furtherFromZero - closerToZero

    return rightDist < leftDist ? rightDist : leftDist

  }


  /**
   * Возвращает номер зоны: 1,2,3,4 | -1,-2,-3,-4.
   * @param {Number} deg - Градус от 0 до 360.
   */
  static getZone4From360_standard(deg){

    if(!IsNumber(deg)){
      return ""
    }

    if(deg <= 45){
      return 1
    }
    if(deg > 45 && deg < 90){
      return 2
    }
    if(deg >= 90 && deg < 135){
      return 3
    }
    if(deg >= 135 && deg < 180){
      return 4
    }
    if(deg >= 180 && deg < 225){
      return -4
    }
    if(deg >= 225 && deg < 270){
      return -3
    }
    if(deg >= 270 && deg < 315){
      return -2
    }
    if(deg >= 315 && deg <= 360){
      return -1
    }
  }

  /**
   * Возвращает размеры квадрата, всей нарисованной кривой, и направление результирующего вектора.
   * Поступают векторы, координаты точек кривой.
   * [[x, y], [x, y], ...].
   * Возвращает объект с данными о кривой.
   */
  static getSquareDimensionOfCurve(curve := []) {
    ; Представим вертикальную линию на нуле координат.
    ; Эта линия должна перемещаться когда рисуется следующий вектор,
    ; в место этого вектора.
    ; Записываем самые крайние границы этой линии, которые были, в переменные.

    ; Самая левая координата x
    local minLeftX := 0
    ; Самая правая координата x
    local maxRightX := 0
    ; Самая меньшая координата y (самая верхняя)
    local minY := 0
    ; Самая большая координата y (самая нижняя)
    local maxY := 0

    ; Сумма всех x координат
    local sumX := 0
    ; Сумма всех y координат
    local sumY := 0

    ; ---------------------------------------------------------

    local returnObj := {
      ; Квадрат кривой
      squareOfCurve: {
        ; Длина квадрата кривой на оси x
        xLength: 0,
        ; Высота квадрата кривой на оси y
        yLength: 0, 
        ; Градус результирующего вектора кривой
        degreeResultVector: 0, 
        ; Номер зоны результирующего вектора кривой (1,2,3,4).
        degreeResultVectorZone: 0 
      },
      ; Лог начальных векторов кривой.
      ; Обычно векторы в начале кривой, до длины кривой 20.
      ; Может быть пустым, потому-что вся длина кривой меньше чем 20,
      ; если кривая проводилась медленно.
      startCurveByLength: {},
      ; Лог начальных векторов кривой.
      ; Обычно векторы в начале кривой, обычно до 6-ого вектора.
      startCurveByCountVectors: {},
      ; Вектор где самая высокая скорость.
      ; Это первая самая высокая скорость, где следующий вектор - с меньшей
      ; скоростью.
      startMaxSpeedVector: {},
      ; Начальное направление кривой. Обычно это направление 2-ого вектора.
      startDirectionDegree: 0,
      startDirectionDegreeZone: 0,
      ; Данные каждого вектора, обычно до 10-ого вектора. 
      /**
       * {
        index: 0,
        degree: 0,
        lineLengthAll: 0,
        lineLengthOne: 0,
        x: 0,
        y: 0,
        zone: 0
      },...
       */
      firstXYProps: []
    }

    ; Длина кривой в данный момент, в цикле. 
    local lineLength := 0
    ; Длина начальной кривой.
    local maxLineLength := 20
    ; Записывать первую максимальную скорость?
    local isRecordStartMaxSpeedVector := true

    for k_vector, vector in curve {
      ; Rectangle
      ; -------------------------------------------------
      local x := vector[1]
      local y := vector[2]
      sumX := sumX + x
      sumY := sumY + y
      if (sumX < minLeftX) {
        minLeftX := sumX
      }
      if (sumX > maxRightX) {
        maxRightX := sumX
      }
      if (sumY < minY) {
        minY := sumY
      }
      if (sumY > maxY) {
        maxY := sumY
      }
      ; --------------------------------------------------

      ; Второй вектор будет определять начальное направление. 
      if(k_vector == 2){
        returnObj.startDirectionDegree := VectorsDegree.getDegree360(x, y)
        returnObj.startDirectionDegreeZone := VectorsDegree.getZone4From360(returnObj.startDirectionDegree)
      }

      ; Собираем данные только о первых 10-ти векторах, из-за производительности.
      if(k_vector <= 10){
        ; Собираем данные о этом векторе.
        ; Длина этого вектора
        local lineLengthOne := Sqrt(x*x + y*y)
        ; Всего длина кривой
        lineLength := lineLength + lineLengthOne
        ; Градус направление этого вектора
        local degree360xy := VectorsDegree.getDegree360(x, y)
        ; Zone: -1,-2,-3,-4.
        local degree360xy_zone := VectorsDegree.getZone4From360(degree360xy)

        ; Объект с данными активного вектора
        local xyProps := {
          index: k_vector, 
          x: x, 
          y: y, 
          degree: degree360xy, 
          zone: degree360xy_zone,
          lineLengthOne: lineLengthOne, 
          lineLengthAll: lineLength
        }
        returnObj.firstXYProps.Push(xyProps)

        ; Вектор начальной максимальной скорости
        if(ObjOwnPropCount(returnObj.startMaxSpeedVector) == 0){
          returnObj.startMaxSpeedVector := xyProps
        }else{
          if(isRecordStartMaxSpeedVector && lineLengthOne >= returnObj.startMaxSpeedVector.lineLengthOne){
            returnObj.startMaxSpeedVector := xyProps
          }else{
            isRecordStartMaxSpeedVector := false
          }
        }

        ; Если длина линии стала больше maxLineLength,
        ; То собираем данные о первых векторах, в startVectors.
        if(lineLength >= maxLineLength && ObjOwnPropCount(returnObj.startCurveByLength) == 0){
          local prevDegree := 0
          local distanceAll := 0
          ; Индекс последнего вектора
          local startCurveByLength_EndIndex := 0
          for k, v in returnObj.firstXYProps{
            if (k == 1){
              prevDegree := v.degree
              continue
            }
            distanceAll := distanceAll + VectorsDegree.getDistance360BetweenDegrees(prevDegree, v.degree)
            prevDegree := v.degree
            startCurveByLength_EndIndex := k
          }
          ; Результирующее направление первых векторов
          local startVectorsDegree360 := VectorsDegree.getDegree360(sumX, sumY)
          ; startVectors := {curveChangeDegree: curveChangeDegree, degree: startVectorsDegree360, degree_debug_zone: VectorsDegree.getZone4From360(startVectorsDegree360), startDirectionDegree: startDirectionDegree, startDirectionDegreeDebug: startDirectionDebug}
          returnObj.startCurveByLength := {
            curveChangeDegree: distanceAll, 
            degreeResultVector: startVectorsDegree360, 
            degreeResultVectorZone: VectorsDegree.getZone4From360(startVectorsDegree360), 
            endIndex: startCurveByLength_EndIndex      
          }

        }

      }

    } ; for curve

    ; Длина рамки кривой
    local rectangleLengthX := 0
    local rectangleLengthY := 0

    if (minLeftX < 0) {
      rectangleLengthX := Abs(minLeftX) + maxRightX
    } else {
      rectangleLengthX := maxRightX
    }

    if (minY < 0) {
      rectangleLengthY := Abs(minY) + maxY
    } else {
      rectangleLengthY := maxY
    }


    if(rectangleLengthY == 0){
      rectangleLengthY := 0.1
    }
    ; 30 / 90 = 0.3 - x меньше y (направление сверху вниз). Меньше 1.
    ; 90 / 90 = 1
    ; 90 / 30 = 3
    ; Тип квадрата кривой. Больше горизонтальный, или вертикальный.
    local xyRatio := rectangleLengthX/rectangleLengthY

    returnObj.squareOfCurve.xLength := rectangleLengthX
    returnObj.squareOfCurve.yLength := rectangleLengthY
    returnObj.squareOfCurve.ratio := xyRatio
    returnObj.squareOfCurve.degreeResultVector := VectorsDegree.getDegree360(sumX, sumY)
    returnObj.squareOfCurve.degreeResultVectorZone := VectorsDegree.getZone4From360(returnObj.squareOfCurve.degreeResultVector)

    return returnObj
    
  }

}

