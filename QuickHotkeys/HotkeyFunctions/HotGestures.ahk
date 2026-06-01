
#Include ./../../Lib/HotGestures/HotGestures.ahk

/**
 * Включает/отключает жесты.
 * @param {Object} hotkeysJsonItem 
 */
gesture_EnableDisable(hotkeysJsonItem){
  global hotkeysActions
  if (hotkeysJsonItem.isEnable) {
    hotkeysActions.gestures := 1
  }else{
    hotkeysActions.gestures := 0
  }
}


VectorsDegree.setFunction_getZone4From360(gesture_getDefinedZone)

; arg1 - точность срабатывания. Чем меньше, тем точнее. Минимум 0.4.
; 0.1 - распознаёт плохо, с ошибками. Нужно установить 0.06.
; arg2 - длина линии чтобы сработало. 
; arg3 - цвет, в обратном порядке. BGR/
; #EC1894
; 0x0000FF - красный.
; #FF0000 - синий.
; #1062ED
; 0.12 - нормально. Но нужно больше образцов чтобы не ошибалось.
global hotGestures_ := HotGestures(0.14, 30, 0xFF0000)
global gesturesCommands := {
  ; ↖
  ; L_Linie
  toLeft_Line: HotGestures.Gesture("←:-10,0|-88,7|-78,3|-74,4|-65,4|-49,3|-35,1|-20,1|-11,0"),
  ; L_Down_U
  toLeft_DownU: HotGestures.Gesture("←L_DownU:-6,-2|-12,-1|-17,-1|-25,0|-36,0|-39,1|-42,4|-38,3|-34,3|-27,5|-21,5|-16,6|-11,5|-7,4|-5,4|-3,5|-2,5|-1,5|0,6|3,7|6,6|9,6|15,5|19,4"),
  ; toLeft_DownU: HotGestures.Gesture("←L_Down_U:-23,2|-33,2|-20,1|-10,1|-6,0|-4,0|-2,0|-2,0|-2,0|-1,-1|-2,0|-1,-1|-2,-1|-1,-1|-2,0|-1,-1|-1,-1|-2,-1|-1,-1|-2,-1|-1,-1|-2,-1|-1,0|-1,-1|-2,-1|-1,0|-2,0|-1,0|-1,0|-2,0|-1,1|-2,1|-1,1|-2,1|-1,0|-1,1|-2,1|-1,0|-1,1|-1,0|-1,1|-2,0|-1,0|-1,0|-2,0|-1,0|-2,0|-1,0|-1,0|-1,0|-1,0|-1,0|-2,0|-1,1|-2,1|-1,1|-1,1|-2,1|-1,1|-2,1|-1,1|-2,1|-1,2|-1,1|-2,2|-1,1|-2,1|-1,2|-2,1|-1,0|-1,0|-2,0|-1,0|-2,0|-1,-1|-2,0|-3,-1|-2,-1|-2,-1|-2,0|-1,0|-2,0|-1,0|-1,0|-2,0|-1,0|-1,0|-1,0|-1,0|-2,0|-2,0|-2,1|-2,0|-4,0|-4,1|-4,0|-4,1|-3,1|-2,1|-2,1|-1,0|-2,0|-1,0|-2,0|-1,0|-1,0|-2,1|-2,0|-3,0|-2,0|-3,1|-3,1|-2,1|-2,0|-2,0|-2,0|-1,0|-2,0|-1,0|-2,0|-1,0|-2,0|-1,0|-1,1|-2,0|-1,0|-2,0|-1,1|-2,1|-1,0|-1,0|-2,0|-1,1|-2,0|-2,1|-2,1|-2,1|-2,0|-2,1|-1,1|-2,0|-1,0|-2,0|-1,0|-2,0|-1,0|-1,0|-3,1|-2,0|-3,1|-2,1|-2,0|-2,0|-2,0|-1,0|-1,0|-2,0|-1,0|-2,1|-1,0|-2,0|-1,0|-1,0|-2,0|-1,0|-2,1|-1,1|-1,0|-2,0|-1,1|-2,0|-1,0|-1,1|-1,1|-1,0|-1,0|-2,0|-1,0|-2,0|-1,1|-2,0|-1,0|-1,0|-2,0|-1,0|-2,0|-1,0|-1,0|-2,0|-1,0|1,0|1,0|2,0|2,0|1,0|2,0|1,0|1,0|2,0|1,0|2,0|1,0|2,0|1,0|2,0|2,0|2,0|1,0|2,0|1,0|2,0|1,0|1,0|2,0|1,0|2,0|1,0|2,1|1,0|1,0|2,0|1,0|2,0|1,0|1,0"),
  ; L_Up_U
  toLeft_UpU: HotGestures.Gesture("←L_UpU:-3,0|-7,0|-14,2|-20,2|-28,2|-33,1|-37,0|-40,-2|-38,-2|-36,-5|-30,-7|-24,-7|-16,-7|-10,-6|-6,-5|-3,-4|1,-5|8,-7"),


  ; R_Line
  toRight_Line: HotGestures.Gesture("→:1,0|11,0|24,2|30,1|39,-1|43,0|42,0|38,-2|32,-1|25,1|16,1|10,1|5,1"),
  ; R_DownU
  ; toRight_DownU: HotGestures.Gesture("→R_DownU:4,1|55,2|46,2|39,5|32,5|26,5|19,6|13,6|7,7|3,6|-1,8|-7,11|-13,14|-19,15"),
  toRight_DownU: HotGestures.Gesture("→R_DownU:6,0|10,2|17,2|22,2|28,1|32,2|34,3|34,2|30,3|26,4|16,3|10,4|7,5|6,5|4,7|2,6|-6,10|-14,10|-22,12"),
  ; R_UpU
  ; toRight_UpU: HotGestures.Gesture("→R_UpU:0,1|73,20|57,10|50,4|43,1|37,-1|29,-3|18,-3|12,-2|6,-2|2,-4|-2,-6|-7,-10|-13,-11|-18,-12"),
  toRight_UpU: HotGestures.Gesture("→R_UpU:4,1|14,2|24,2|30,3|36,0|40,-3|50,-7|45,-8|34,-8|26,-8|15,-7|8,-6|3,-6|-2,-7|-12,-7|-21,-11"),

  ; closeTabLine
  closeTab_Line: HotGestures.Gesture("↙:-8,10|-8,10|-8,10|-8,10|-8,10|-8,10|-8,10|-8,10|-8,10|-8,10|-8,10"),
  ; closeTabRightU
  ; closeTab_RightU: HotGestures.Gesture("↙closeTabRightU:-22,32|-21,38|-17,40|-11,37|-6,30|-2,30|2,25|4,20|6,18|7,13|8,10|10,6|12,4|12,2|10,1|9,-1|9,-2"),
  ; closeTab_LeftU: HotGestures.Gesture("↙closeTab_LeftU:-1,0|-1,4|-3,11|-5,17|-7,19|-9,22|-12,22|-16,23|-19,24|-22,25|-23,25|-22,22|-20,19|-16,14|-13,11|-9,6|-7,3|-5,2|-4,0|-5,-2|-6,-4|-4,-4|-4,-5|-3,-4|-3,-4|-2,-5|-2,-4|-1,-3|0,-2|0,-2"),

  ; closeWin: HotGestures.Gesture("↘closeWinLine:3,10|3,10|3,10|3,10|3,10|3,10|3,10|3,10|3,10|3,10|3,10"),
  ; closeWin: HotGestures.Gesture("↘closeWinLine:3,5|45,64|32,44|25,35|23,28|23,22|19,19|17,17|16,15|13,14|10,11|8,8|5,7|3,5|2,4|1,2|1,2|2,2"),
  closeWinLine: HotGestures.Gesture("↘:1,1|7,13|11,27|14,38|19,50|22,60|23,61|18,55|13,44|11,34|8,26|5,17|3,11|2,6|1,4"),
  ; closeWin_RightU: HotGestures.Gesture("closeWin_RightU:2,9|7,20|13,28|12,30|11,32|11,28|11,26|11,21|10,14|10,8|12,3|10,-2|9,-8"),

  ; restoreTab: HotGestures.Gesture("↗:2,-10|4,-24|9,-36|11,-39|7,-34|6,-29|4,-22|2,-14|2,-10|1,-6|1,-3|1,1"),
  restoreTab: HotGestures.Gesture("↗:4,-10|4,-10|4,-10|4,-10|4,-10|4,-10|4,-10|4,-10|4,-10|4,-10|4,-10"),
  
  ; a: HotGestures.Gesture("A:-1,-2|-1,-1|-2,-1|-1,-1|-2,0|-1,0|-1,0|-2,0|-1,0|-2,1|-1,1|-2,2|-1,2|-1,2|0,3|0,3|0,2|0,2|1,2|1,1|1,1|1,0|1,0|2,0|3,-1|4,-3|4,-4|3,-5|3,-5|2,-6|1,-5|2,-6|1,-5|0,-5|0,-6|0,-5|0,-5|0,-6|0,-3|0,-2|0,-2|0,-2|0,3|0,5|0,8|0,10|0,9|0,7|0,8|1,6|2,6|1,5|2,4|2,3|1,2|1,2|2,1|1,2|2,1|1,1|1,1|3,1|2,1|2,0|4,0|5,0|4,0|2,0|2,-1|2,0|2,0|1,0"),
  a: HotGestures.Gesture(":1,0|2,0|5,-2|6,-2|9,-4|10,-5|13,-7|14,-7|14,-9|15,-11|12,-10|11,-11|10,-10|10,-11|8,-11|8,-11|7,-12|7,-12|6,-11|5,-11|4,-11|4,-12|4,-13|3,-10|3,-8|2,-8|1,-9|1,-8|0,-9|0,-8|0,-7|0,-6|0,-6|0,-5|0,-5|0,-4|-1,-2|-2,-3|-2,-2|-1,-2|-2,-2|-1,-1|-1,-1|-2,0|-1,0|-2,0|-2,0|-2,0|-2,1|-1,1|-2,0|-2,2|-2,3|-4,4|-3,5|-4,9|-4,10|-3,10|-2,11|-3,11|-1,10|-1,9|0,10|0,10|1,10|1,11|1,12|1,11|2,11|3,10|4,10|4,10|6,11|8,10|7,8|6,5|9,6|11,7|12,7|13,7|14,6|16,5|15,4|13,3|15,3|19,1|16,1|12,0|9,0|7,-1|5,0|3,-1|2,-1"),
  
  ; s: HotGestures.Gesture(":-1,0|-4,0|-4,1|-5,2|-6,2|-6,4|-5,3|-3,4|-3,3|-1,4|0,4|5,5|8,5|12,5|13,3|11,2|8,1|5,1|3,1|1,1|-2,1|-5,2|-10,4|-15,5|-18,4|-17,3|-14,3|-9,1|-5,1|-3,0"),
  s: HotGestures.Gesture(":-7,1|-9,1|-9,2|-9,2|-6,2|-5,1|-1,3|2,3|8,5|13,6|17,7|17,7|16,8|12,5|9,4|5,3|2,3|-1,3|-6,4|-12,3|-18,4|-22,5|-26,5|-27,5"),
  s1: HotGestures.Gesture(":0,-1|-1,-3|-1,-2|0,-2|-1,-1|-1,-1|-1,0|-2,0|-1,0|-2,1|-1,1|-1,1|-2,2|-1,2|0,3|0,4|0,5|1,4|2,5|2,4|2,4|2,4|2,4|2,3|1,3|0,3|0,4|-1,2|-2,4|-2,3|-2,2|-2,1|-2,0|-1,0|-2,0|-1,0|-2,-1|-1,-1|-2,-1|-1,-1|-1,-2|0,-2|0,-2|0,-2|0,-1"),
  
  ; c: HotGestures.Gesture(":0,-1|0,-3|0,-4|0,-4|-1,-4|-1,-4|-2,-4|-2,-2|-2,-1|-1,-1|-3,0|-4,1|-5,2|-6,4|-8,7|-7,8|-7,8|-6,8|-6,8|-3,8|-2,8|-1,8|1,8|2,8|3,7|4,5|5,5|5,5|5,4|4,3|4,2|4,1|3,2|5,1|5,0|4,0|5,0|4,-1|2,-1|3,-3|2,-3|2,-3|2,-3|1,-4|1,-4|0,-4|0,-2"),
  ; c1: HotGestures.Gesture(":0,1|0,1|1,2|0,1|1,1|1,0|1,-1|2,-3|1,-3|0,-3|0,-4|0,-3|-1,-3|-1,-2|-2,-1|-4,0|-4,0|-6,2|-8,4|-8,6|-7,5|-7,7|-4,8|-3,7|-2,7|-1,6|0,6|1,5|2,5|2,3|3,2|2,2|2,2|3,1|5,0|7,0|9,-3|9,-4|7,-4|6,-5|4,-3|3,-3|1,-2|1,-2|0,-1|0,-1|0,-2|0,-1|-1,1"),
  c: HotGestures.Gesture(":0,-2|0,-4|0,-4|-1,-7|-1,-8|-2,-7|-1,-4|-1,-2|-3,-1|-4,1|-4,3|-3,6|-3,8|-1,10|1,10|2,11|4,11|5,10|5,9|5,6|5,5|4,3|2,2|2,1|2,0|4,0|4,-1|5,-3|4,-6|6,-7|5,-11|4,-14|4,-17|4,-17|2,-14|1,-14|0,-10|0,-6|0,-4"),
  

  ; v: HotGestures.Gesture("V:3,2|4,4|5,3|5,5|6,4|5,4|6,5|5,4|4,3|4,4|2,3|2,2|2,2|2,-1|5,-7|7,-11|9,-13|9,-13|8,-9|6,-6|4,-4|2,-3|2,-1"),  
  ; v: HotGestures.Gesture("V:1,1|1,3|2,4|2,5|2,5|1,4|2,4|2,4|1,2|1,2|1,2|1,1|2,-3|2,-5|3,-5|4,-5|4,-6|5,-5|6,-6|5,-6|3,-4|3,-5|3,-3|1,-3|1,-2|1,-1|1,-2|1,-1"),  
  v: HotGestures.Gesture(":1,3|2,3|2,4|3,4|2,5|2,3|2,2|1,2|1,1|1,1|1,1|1,-1|3,-3|4,-5|6,-7|7,-8|7,-10|7,-9|7,-9|4,-7"),  
  v1: HotGestures.Gesture(":0,1|3,3|4,5|4,5|4,5|5,5|4,4|2,2|2,2|2,1|3,-4|7,-8|10,-12|12,-13|14,-15|10,-12|7,-7|4,-5"),  

  ; x: HotGestures.Gesture("x:1,0|1,0|1,0|1,1|2,0|1,1|1,1|2,1|2,2|2,1|2,1|1,2|2,1|2,2|2,1|2,2|1,1|1,1|2,2|1,1|2,2|1,1|2,1|1,1|1,1|2,1|1,2|1,1|1,2|1,2|2,2|1,2|1,1|0,2|1,1|0,1|0,2|0,1|1,2|1,1|0,1|0,2|1,1|0,2|0,1|0,2|1,1|1,1|0,2|0,1|0,2|0,1|0,2|0,1|0,1|0,1|-1,1|-1,1|-1,2|-1,1|-1,1|-1,2|-1,1|-2,2|-1,1|-1,1|-2,0|-1,0|-2,0|-1,0|-2,0|-1,0|-1,0|-2,0|-1,0|-2,0|-1,0|-1,0|-1,0|-1,-1|-1,-1|-1,-1|0,-1|0,-1|-1,-2|-1,-1|0,-2|0,-1|0,-1|0,-2|0,-1|0,-2|1,-1|1,-2|1,-1|1,-1|1,-2|1,-1|1,-2|1,-1|0,-2|0,-1|1,-1|1,-2|1,-1|2,-2|1,-1|2,-1|1,-3|2,-2|1,-2|2,-2|1,-2|1,-1|2,-2|1,-2|2,-2|1,-2|2,-1|1,-2|2,-1|1,-2|1,-1|2,-1|1,-2|2,-1|1,-1|2,0|1,-1|1,-1|1,-1|1,-1|1,-1|2,-1|1,-2|2,-1|1,-2|1,-1|2,-1"),
  ; x: HotGestures.Gesture("x:0,2|7,12|6,8|6,7|6,4|6,4|5,3|4,2|2,2|2,1|2,0|1,0|2,0|1,0|2,0|1,0|1,-1|2,-1|2,-3|3,-3|2,-4|2,-5|2,-4|2,-4|1,-3|1,-3|0,-2|0,-2|0,-1|0,-1|0,-1|0,-1|-1,-1|-1,0|-1,0|-1,0|-2,0|-4,0|-4,0|-5,1|-5,2|-5,3|-6,5|-7,5|-8,8|-8,8|-7,7|-6,6|-5,6|-3,5|-2,4|-2,3|-1,2|-1,2|-1,1|-1,0"),
  x: HotGestures.Gesture(":2,2|4,4|4,4|4,6|5,6|6,8|5,6|5,7|5,7|3,6|2,4|2,2|2,1|2,-2|1,-4|0,-5|0,-6|0,-6|0,-6|0,-5|0,-6|0,-3|0,-2|0,-1|-4,2|-6,4|-8,7|-8,8|-8,7|-9,7|-7,6|-5,4|-4,3|-2,2|-1,2"),
  
  ; b: HotGestures.Gesture(":12,0|19,0|23,0|23,1|17,1|11,0|6,0|4,0|2,1|1,1|-1,2|-4,3|-7,3|-9,4|-7,4|-5,4|-4,3|-2,3|-1,4|3,4|11,4|17,6|21,6|21,5|15,4|10,3|4,1|-5,1|-16,0|-25,0|-32,0|-35,0|-32,2|-25,2|-15,1|-9,0|-5,0|-3,0"),
  ; b2: HotGestures.Gesture(":29,0|34,0|38,0|32,0|27,0|16,0|9,0|6,0|3,0|2,1|0,1|-4,3|-7,4|-11,5|-13,7|-14,7|-11,7|-9,6|-6,5|-3,3|1,5|6,6|14,7|20,8|22,6|20,6|13,4|8,2|5,2|0,2|-5,3|-10,4|-13,3|-19,4|-23,5|-26,4|-30,3|-31,2|-33,1|-28,0|-19,0|-12,0|-7,0|-4,0"),
  b: HotGestures.Gesture(":4,0|10,2|17,1|22,0|24,0|21,0|14,0|8,0|5,0|-7,1|-10,2|-9,3|-8,2|-5,2|-3,2|-2,2|0,5|5,6|10,7|14,7|16,7|15,8|12,6|7,4|4,2|3,1|2,1|1,2|0,3|-2,3|-4,3|-8,4|-15,4|-21,5|-27,5|-32,5|-33,4|-28,5|-21,4|-14,3|-7,1"),
  
  ; z: HotGestures.Gesture("Z:2,-1|6,-1|6,0|4,0|3,0|1,1|2,1|1,1|0,1|0,2|-1,2|-1,3|-3,3|-5,5|-5,5|-6,5|-6,6|-5,5|-5,4|-3,3|-2,2|-2,1|-1,2|0,1|0,1|1,0|3,0|5,-1|6,-1|9,-2|8,-2|7,-1|5,0|3,0|2,0|2,0|1,0"),
  z: HotGestures.Gesture(":1,0|7,0|12,0|14,0|15,0|13,0|9,0|6,0|4,0|3,1|1,0|-2,2|-4,3|-6,3|-7,5|-8,6|-10,5|-10,6|-11,6|-11,6|-9,5|-6,3|-4,2|-1,1|2,1|6,0|9,0|11,-1|13,-1|15,-2|14,-1|15,0|13,0|8,0|5,0|3,0"),

  n: HotGestures.Gesture(":4,-8|5,-9|5,-9|6,-8|5,-6|3,-4|1,-1|1,3|0,5|0,8|0,7|0,6|-1,5|2,1|5,-5|7,-7|8,-8|8,-9|7,-7|5,-5"),
  m: HotGestures.Gesture(":0,-2|1,-3|1,-4|2,-5|1,-4|2,-5|1,-3|2,-3|1,-2|1,-2|1,-2|1,-1|1,-2|1,0|1,1|1,2|0,2|1,2|2,3|1,3|2,4|2,4|1,3|2,2|1,2|1,2|0,1|1,1|1,0|0,-1|0,-1|1,-1|1,-2|1,-4|2,-5|3,-5|4,-5|4,-6|5,-5|4,-5|3,-4|2,-3|2,-2|1,-1|0,1|1,3|2,3|1,3|0,3|1,4|0,5|1,4|2,4|2,4|1,2|2,3|1,2|1,2|1,1|0,2|1,1|1,2|2,1"),
  ; f: HotGestures.Gesture("f:-1,-1|-1,-1|-1,-1|-1,-2|-1,-1|-1,-2|-1,-1|-1,-1|-2,0|-2,1|-3,1|-2,1|-2,2|-1,2|0,3|0,3|0,3|0,3|0,3|0,3|1,3|0,3|0,3|0,5|0,5|0,5|0,5|-1,5|-1,6|-2,5|-2,7|-2,7|-2,8|-1,7|0,6|0,7|0,6|0,6|0,6|0,3|0,3|0,2|-1,1|0,-1|-1,-4|-2,-4|-2,-5|-2,-5|-3,-7|-3,-9|-3,-8|-2,-8|-2,-7|-2,-6|-2,-6|-2,-5|-1,-3|-1,-2|-1,-2|1,0|5,0|6,1|8,0|11,0|11,0|12,0|13,0|11,0|10,0|7,0|5,0|5,0|4,-1|2,-1|2,0"),
  f: HotGestures.Gesture(":0,6|0,7|0,7|0,8|0,11|0,12|0,11|0,14|0,14|0,16|0,14|0,16|0,15|0,14|0,12|0,10|-1,9|-1,9|0,8|0,8|0,7|-1,6|0,6|0,4|-1,3|-1,2|0,2|-1,1|-1,0|-1,0|-2,-2|-2,-3|-2,-2|-3,-3|-4,-3|-5,-3|-5,-5|-7,-7|-7,-6|-8,-6|-6,-6|-6,-6|-6,-5|-6,-5|-5,-5|-4,-4|-2,-3|-2,-2|-1,-2|-1,-1|0,-2|0,-1|0,-1|0,-2|0,-1|0,-2|3,-1|4,-2|5,-1|6,0|8,-1|9,-1|10,0|10,0|14,0|15,0|16,0|16,0|17,0|17,0|13,0|10,0|9,0|9,0|7,0|4,0"),
  
  ; e: HotGestures.Gesture(":-1,0|-3,0|-4,0|-6,0|-8,1|-10,1|-12,2|-13,2|-10,2|-8,2|-4,2|-3,1|-2,1|-1,1|0,2|0,1|1,1|2,2|4,2|4,2|6,2|9,2|8,2|8,2|8,2|4,1|3,1|1,0|-1,0|-5,0|-7,1|-9,2|-10,2|-9,2|-9,3|-7,2|-4,2|-3,2|-1,2|-1,1|0,1|0,2|0,1|0,2|1,2|1,2|2,2|3,1|4,2|6,2|10,2|13,1|15,1|16,0|13,-1|11,-1|7,-1|4,-1|3,0"),
  e: HotGestures.Gesture(":-2,0|-3,0|-8,0|-10,2|-7,1|-9,1|-7,1|-6,2|-5,2|-3,1|-3,3|-1,2|1,3|3,4|5,4|8,3|10,2|9,2|6,2|2,3|-3,3|-8,4|-11,4|-11,5|-10,5|-7,5|-4,4|-2,3|-1,4|3,5|10,5|17,5|24,4|26,2|28,1|26,0|20,0|12,0"),

  9: HotGestures.Gesture(":0,-2|0,-2|0,-2|0,-3|0,-5|0,-7|0,-8|0,-9|0,-11|0,-14|0,-14|0,-16|0,-16|0,-16|0,-15|0,-18|0,-15|0,-16|0,-14|0,-13|0,-12|0,-11|0,-9|0,-9|0,-7|0,-6|0,-6|0,-3|0,-3|0,-3|0,-2|0,-1|0,-2|1,0|2,2|2,3|3,4|2,4|3,5|3,5|4,6|5,6|6,9|5,9|6,9|5,7|4,6|4,6|4,5|2,4|3,5|3,3|1,2|1,2|1,2|1,1|0,2"),

  arrowToLeft: HotGestures.Gesture(":-5,0|-9,0|-15,0|-17,0|-19,0|-21,0|-21,1|-19,1|-13,1|-9,1|-5,0|-1,0|6,-3|9,-5|9,-5|7,-4|5,-3|4,-2|2,-1|0,1|-1,1|-1,1|-2,1|-2,2|-4,2|-5,2|-6,2|-6,2|-7,3|-6,3|-6,2|-3,2|-3,2|0,1|3,0|5,1|6,2|7,2|9,2|10,3|9,2|7,2|7,2|4,2|2,1|2,1"),
  ; arrowToRight: HotGestures.Gesture(":3,0|8,0|16,-2|20,-2|22,-1|22,0|23,2|25,2|23,2|18,1|16,1|12,1|9,2|7,1|5,0|3,1|2,0|2,0|2,0|1,0|1,0|-2,-1|-4,-3|-5,-3|-5,-4|-5,-3|-5,-4|-3,-2|-2,-2|-2,-2|0,-1|7,2|6,2|5,2|3,2|2,1|1,2|1,1|1,1|1,2|0,1|0,2|-1,2|-2,2|-3,3|-5,3|-5,3|-9,3|-6,3|-4,2|-3,1|-1,1|-1,1|-1,0"),
  arrowToRight: HotGestures.Gesture(":1,0|8,0|21,0|38,0|60,0|67,0|61,0|47,0|32,0|19,0|12,0|6,0|4,-1|2,-1|0,-2|-1,-1|-2,-2|-4,-3|-6,-5|-7,-4|-8,-7|-8,-7|-7,-5|-5,-3|-3,-2|4,2|8,5|13,6|15,7|15,7|13,6|10,4|5,3|3,2|3,1|1,2|1,2|0,3|-1,4|-4,5|-6,4|-9,6|-10,5|-10,5|-8,4|-7,3|-5,3|-3,1|-2,1"),

  arrowToDown: HotGestures.Gesture(":-1,0|-4,48|1,37|1,30|2,24|2,22|3,20|1,14|2,9|1,8|0,5|0,3|0,2|-1,1|-1,0|-1,0|-1,-1|-3,-1|-2,-1|-2,-2|-4,-3|-5,-3|-4,-3|-4,-2|-3,-2|-2,-2|-1,-1|-2,-1|0,1|1,2|3,2|4,4|4,3|3,3|5,3|5,4|4,3|4,3|4,2|2,2|2,1|1,0|1,-1|2,-3|2,-4|3,-5|3,-4|4,-5|5,-5|5,-5|5,-3|3,-2|2,-1|1,-1|1,-1|1,0|2,-1|1,-1|1,-1|1,0"),
  arrowToUp: HotGestures.Gesture(":0,-2|-1,-4|-1,-6|-1,-7|0,-7|0,-10|0,-13|3,-17|3,-19|3,-19|2,-17|2,-14|2,-11|1,-10|1,-9|0,-7|0,-10|0,-6|0,-4|0,-3|0,-2|1,-2|0,-2|0,-1|0,-2|0,-1|0,-2|0,-1|0,2|-1,3|-1,2|-1,2|-3,4|-6,7|-5,5|-5,4|-3,3|-2,2|-1,2|-1,1|0,-1|1,-2|3,-3|3,-4|2,-4|2,-5|2,-4|2,-3|1,-2|1,-1|1,-2|1,-1|1,-2|1,-1|1,-1|3,2|4,2|5,3|5,5|5,5|6,5|4,4|4,4|5,4|3,3|2,2|1,1|1,1"),
  showPrograms: HotGestures.Gesture("1:0,-6|1,-48|2,-34|1,-25|0,-23|0,-24|2,-23|1,-23|0,-21|0,-23|0,-19|0,-22|0,-19|0,-20|0,-16|0,-17|0,-13|0,-14|0,-12|0,-10|0,-7|0,-7|0,-7|0,-4|0,-3|0,-3|0,-3|0,-2|0,-2|0,-1|0,-1|-1,1|0,1|-1,0|-1,1|-1,1|-1,1|-1,3|-2,3|-1,3|-2,3|-1,2|-1,2|-1,2|-1,1|0,2"),
  squareRoot: HotGestures.Gesture(":1,-1|3,-1|4,0|4,0|2,0|2,0|2,0|1,0|1,3|1,4|2,6|2,5|2,6|2,5|2,5|1,4|1,3|1,3|1,2|1,1|0,-1|0,-3|0,-4|0,-6|0,-8|0,-11|0,-12|0,-11|-1,-11|-1,-8|-1,-7|-1,-5|-1,-3|0,-2|0,-1|1,-1|4,1|6,1|8,1|9,0|10,0|10,0|9,0|8,-1|5,-1|4,0|2,2|1,3|0,5|1,5|1,4|0,3|1,1"),

  ; l: HotGestures.Gesture(":-2,0|-3,0|-7,0|-10,0|-13,0|-19,0|-21,0|-22,0|-21,0|-19,0|-15,0|-11,0|-7,1|-4,1|-2,2|0,3|2,2|3,3|6,3|7,2|10,2|9,1|11,-1|10,-4|9,-6|8,-11|7,-14|6,-17|4,-19|4,-20|2,-18|1,-19|0,-18|0,-17|-1,-17|-1,-13|-1,-9|0,-6|-1,-5"),
  ; l: HotGestures.Gesture(":-2,-1|-3,-1|-4,-2|-10,-2|-17,-4|-25,-4|-30,-4|-26,-2|-22,-1|-19,2|-17,3|-13,5|-10,7|-6,7|-4,6|-2,6|0,6|1,5|1,4|1,2|2,2|3,1|5,0|7,-3|8,-8|8,-16|9,-21|8,-28|6,-30|4,-34|2,-31|1,-28|1,-20|0,-13|0,-7|0,-4"),
  l: HotGestures.Gesture(":3,0|13,0|29,0|45,0|53,0|54,0|45,0|40,1|30,3|22,4|14,4|9,3|5,5|3,3|1,4|0,4|-3,5|-8,7|-15,7|-19,6|-23,4|-25,4|-23,2|-23,-1|-21,-5|-16,-7|-13,-9|-10,-14|-8,-19|-7,-23|-5,-25|-2,-24|-1,-25|-1,-24|0,-22|0,-18|0,-14|0,-11|0,-7|0,-4"),

  r: HotGestures.Gesture(":-2,-4|-4,-9|-6,-15|-10,-20|-13,-24|-17,-31|-24,-42|-27,-47|-25,-44|-21,-36|-16,-27|-10,-19|-6,-12|-3,-7|0,-5|4,-2|9,1|15,4|19,7|21,10|21,13|20,15|17,14|12,10|8,6|4,4|2,3|-1,2|-6,1|-13,1|-21,0|-31,0|-34,0|-37,0|-35,0|-34,-2|-26,-2|-17,-2|-9,-1|-5,-1|-1,0"),


}

hotGestures_.Register(gesturesCommands.toLeft_Line, "Prev Tab")
; hotGestures_.Register(gesturesCommands.toLeft_DownU, "Prev Tab")
; hotGestures_.Register(gesturesCommands.toLeft_UpU, "Prev Tab")

hotGestures_.Register(gesturesCommands.toRight_Line, "Next Tab")
; hotGestures_.Register(gesturesCommands.toRight_DownU, "Next Tab")
; hotGestures_.Register(gesturesCommands.toRight_UpU, "Next Tab")

hotGestures_.Register(gesturesCommands.closeTab_Line, "Close Tab")
; hotGestures_.Register(gesturesCommands.closeTab_RightU, "Close Tab RightU")
; hotGestures_.Register(gesturesCommands.closeTab_LeftU, "Close Tab LeftU")

hotGestures_.Register(gesturesCommands.closeWinLine, "Close Window")
; hotGestures_.Register(gesturesCommands.closeWin_RightU, "Close Window closeWin_RightU")

hotGestures_.Register(gesturesCommands.restoreTab, "Restore Tab")

hotGestures_.Register(gesturesCommands.a, "Select All")
hotGestures_.Register(gesturesCommands.s, "Save")
hotGestures_.Register(gesturesCommands.s1, "Save")

hotGestures_.Register(gesturesCommands.c, "Copy")
; hotGestures_.Register(gesturesCommands.c1, "Copy")

hotGestures_.Register(gesturesCommands.v, "Paste")
; hotGestures_.Register(gesturesCommands.v1, "Paste v1")


hotGestures_.Register(gesturesCommands.x, "Cut")

hotGestures_.Register(gesturesCommands.z, "Undo")
hotGestures_.Register(gesturesCommands.b, "Ctrl+B")
; hotGestures_.Register(gesturesCommands.b2, "Ctrl+B")
hotGestures_.Register(gesturesCommands.n, "Ctrl+N")
; hotGestures_.Register(gesturesCommands.m, "Ctrl+M")
hotGestures_.Register(gesturesCommands.f, "Find")
; hotGestures_.Register(gesturesCommands.f2, "Find")
hotGestures_.Register(gesturesCommands.e, "Ctrl+E")
hotGestures_.Register(gesturesCommands.9, "Open file properties")
hotGestures_.Register(gesturesCommands.l, "Ctrl+L")
hotGestures_.Register(gesturesCommands.r, "Reload")


hotGestures_.Register(gesturesCommands.arrowToLeft, "Back (Alt + ←)")
hotGestures_.Register(gesturesCommands.arrowToRight, "Forward (Alt + →)")
hotGestures_.Register(gesturesCommands.arrowToDown, "Select all down")
hotGestures_.Register(gesturesCommands.arrowToUp, "Select all up")
; hotGestures_.Register(gesturesCommands.showPrograms, "Show programs")
hotGestures_.Register(gesturesCommands.squareRoot, "Run calculator")


/**
 * Вызывается при остановке записи жестов.
 * @param {Integer} isTriggeredHotkey Был нажат какой-нибудь хоткей в момент записи?
 * @param {Integer} winIdStartClicking Ид окна де было кликнуто в начале записи.
 */
stopRecordingGesture(isTriggeredHotkey := false, winIdStartClicking := 0){
  ; Stop recording
  global hotGestures_
  hotGestures_.Stop() 
  ; Check validity of result
  if hotGestures_.Result.Valid { 

    switch hotGestures_.Result.MatchedGesture { 

      case gesturesCommands.toLeft_Line, gesturesCommands.toLeft_DownU, gesturesCommands.toLeft_UpU, 
        gesturesCommands.toRight_Line, gesturesCommands.toRight_DownU, gesturesCommands.toRight_UpU, 
        ; gesturesCommands.toRight_ErrLikeV,
        ; gesturesCommands.closeTab_Line, gesturesCommands.closeTab_RightU, gesturesCommands.closeTab_LeftU,
        gesturesCommands.closeTab_Line,
        ; gesturesCommands.closeWin_RightU
        gesturesCommands.closeWinLine:
          gesture_testAll(hotGestures_, winIdStartClicking)

      case gesturesCommands.restoreTab: 
        ; Восстановить вкладку 
        BlockInput "On"
        SendEvent("^+{t}")
        BlockInput "Off"
       
      case gesturesCommands.a: 
        SendEvent gesture_getHoldingModsSymbols() . "{a}"
      case gesturesCommands.s, gesturesCommands.s1: 
        Send gesture_getHoldingModsSymbols()  . "{s}"
      ; case gesturesCommands.c, gesturesCommands.c1: 
      case gesturesCommands.c: 
        Send gesture_getHoldingModsSymbols() . "{c}"
      case gesturesCommands.v, gesturesCommands.v1:
        gesture_testV(hotGestures_)
      case gesturesCommands.x: 
        Send gesture_getHoldingModsSymbols() . "{x}"
      case gesturesCommands.z: 
        Send gesture_getHoldingModsSymbols()  . "{z}"      
      ; case gesturesCommands.b, gesturesCommands.b2: 
      case gesturesCommands.b: 
        Send gesture_getHoldingModsSymbols() . "{b}"      
      case gesturesCommands.n: 
        Send gesture_getHoldingModsSymbols() . "{n}"
      case gesturesCommands.m: 
        Send gesture_getHoldingModsSymbols()  . "{m}"
      case gesturesCommands.f: 
        Send gesture_getHoldingModsSymbols()  . "{f}"
      case gesturesCommands.e: 
        Send gesture_getHoldingModsSymbols()  . "{e}"
      case gesturesCommands.l: 
        Send gesture_getHoldingModsSymbols()  . "{l}"
      case gesturesCommands.r: 
        Send gesture_getHoldingModsSymbols()  . "{r}"
      case gesturesCommands.9: 
        local selectedFiles := getSelectedFilesInFileExplorer()
        if(selectedFiles != false && selectedFiles.Has(1)){
          Run 'properties "' . selectedFiles[1] . '"'
          local winId := WinWait("ahk_class #32770", , 4)
          ; Debug().logF(winId)
          if(winId){
            WinActivate "ahk_id " . winId
          }
        }

      case gesturesCommands.arrowToLeft: 
        Send gesture_getHoldingModsSymbols("!")  . "{Left}"
      case gesturesCommands.arrowToRight: 
        Send gesture_getHoldingModsSymbols("!")  . "{Right}"
      case gesturesCommands.arrowToDown: 
        Send "^+{End}"
      case gesturesCommands.arrowToUp: 
        Send "^+{Home}"
        
      case gesturesCommands.showPrograms: 
        gesture_testOpenPrograms(hotGestures_)
     
      case gesturesCommands.squareRoot: 
        SetTimer startProgram, -1
        
      ; hgs.Result.MatchedGesture is an empty string if no match
      case "": return 
    }
  }else {
    ; if no movement or track is too short, hgs.Result.Valid is false, 
    ; and a right click is expected.

    ; Какой-нибудь хоткей сработал?, во время записи.
    if(isTriggeredHotkey == false){
      ; Send("{RButton}")
      if GetKeyState("LButton", "P") {
        return
      }
      Click("R")
    }
  }

  ; =======================================================================
  ; Functions 


}


 /**
   * @param {String} mods - Default ^ - Означает что будет нажиматься модификатор Ctrl,
   * вместе с клавишей которая была нарисована.
   * @returns {String} Возвращает строку модификаторов которые нужно нажать - "^!".
   */
  gesture_getHoldingModsSymbols(mods := "^"){

    ; Если кроме модификатора mods, удерживается ещё какой-то модификатор, то
    ; этот модификатор дописывается в конец переменной mods.

    if(mods != "+" && GetKeyState("LShift", "P")){
      mods := mods . "+"
    }
    if(mods != "!" && GetKeyState("LAlt", "P")){
      mods := mods . "!"
    }
    if(mods != "#" && GetKeyState("LWin", "P")){
      mods := mods . "#"
    }
    if(mods != "^" && GetKeyState("LCtrl", "P")){
      mods := mods . "^"
    }

    ; Если какой-то модификатор удерживается при рисовании.
    if(StrLen(mods) > 1){
      ; Отжимаем модификаторы, 3 раза.
      ; Они могут залипать.
      SetTimer releaseModifiers, 60
      SetTimer releaseModifiers_disableTimer, -210
    }

    return mods
  }


/**
 * Проверяет все жесты: влево, вправо, закрыть вкладку, закрыть окно.
 * И стартует нужную команду.
 * @param hotGesture 
 * @param winIdStartClicking 
 */
gesture_testAll(hotGesture, winIdStartClicking){ 
  
  local gestureData := VectorsDegree.getSquareDimensionOfCurve(hotGesture.__vectors)

    ; Линия проводилась нормально, не очень медленно
    ; Начальное направление линии
    switch gestureData.startMaxSpeedVector.zone{
      ; closeTab Line
      case -3:
        gesture_closeTab()
        
      ; Случайно стартовое направление немного вправо, с верху. 
      case -2:
        ; Начальное направление кривой должно быть:
        ; Error, конфликт с toRight.
        if(gestureData.startDirectionDegree >= 310){
          nextTabByRButtonWheel("RButton")
          return
        }

        ; Квадрат кривой должен быть квадрат, вертикальный, не горизонтальный.
        if(gestureData.squareOfCurve.ratio <= 1){
          ; Error, конфликт с V.
          ; Результирующий вектор доложен быть внизу, чтобы это было меньше буквы V.
          if(gestureData.squareOfCurve.degreeResultVector < 330 &&
            gestureData.squareOfCurve.degreeResultVector > 220){
              gesture_closeWn(winIdStartClicking)
            ; MsgBox "Close Win"
          }
        }
      
      case -4, 4:
        prevTabByRButtonWheel("RButton")
      case -1, 1:
        nextTabByRButtonWheel("RButton")

    }
  ; rightOrLeft(){
  ; }
}


gesture_testV(hotGesture){
  local gestureData := VectorsDegree.getSquareDimensionOfCurve(hotGesture.__vectors)

  ; ratio < 1 - квадрат в высоту больше, чем в ширину.
  if(gestureData.squareOfCurve.ratio < 1.7){
    ; Debug.log("V")
    Send gesture_getHoldingModsSymbols() . "{v}"
  }else{
    ; Debug.log("->")
    nextTabByRButtonWheel("RButton")
  }

}


/**
 * Проверяет жест OpenPrograms на корректность.
 * И стартует или закрыть вкладку, или altTab().
 * @param hotGesture 
 */
gesture_testOpenPrograms(hotGesture){
  local gestureData := VectorsDegree.getSquareDimensionOfCurve(hotGesture.__vectors)
  if(gestureData.squareOfCurve.degreeResultVectorZone == -3){
    gesture_closeTab()
    return
  }
  if(gestureData.squareOfCurve.degreeResultVectorZone == 2 || 
    gestureData.squareOfCurve.degreeResultVectorZone == 3){
      ; altTab_gesture("T")
      altTab("T")
      return
  }
}


  /**
   * Не стандартные номера зоны. Угол первой зоны - 20.
   * !! Это не используется напрямую, а передаётся в класс VectorsDegree, при создании класса.
   * Возвращает номер зоны: 1,2,3,4 | -1,-2,-3,-4.
   * Эта функция передаётся в класс VectorsDegree, поэтому определено первый аргумент thisClassObj.
   * @param {Number} deg - Градус от 0 до 360.
   */
  gesture_getDefinedZone(thisClassObj, deg){

    if(!IsNumber(deg)){
      return ""
    }

    if(deg <= 20){
      return 1
    }
    if(deg > 20 && deg <= 90){
      return 2
    }
    if(deg > 90 && deg <= 160){
      return 3
    }
    if(deg > 160 && deg <= 180){
      return 4
    }
    if(deg > 180 && deg <= 200){
      return -4
    }
    if(deg > 200 && deg <= 267){
      return -3
    }
    if(deg > 267 && deg <= 340){
      return -2
    }
    if(deg > 340 && deg <= 360){
      return -1
    }
  }



gesture_closeTab(){
  ; Закрыть вкладку 
  BlockInput "On"
  SendEvent("^{w}")
  BlockInput "Off"
}

gesture_closeWn(winIdStartClicking){
  ; Закрывает окно. 
  PostMessage 0x0112, 0xF060,,, "ahk_id " . winIdStartClicking
}


