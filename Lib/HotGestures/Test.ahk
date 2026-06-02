#Include HotGestures.ahk

leftSlide := HotGestures.Gesture("←:-1,0")
rightSlide := HotGestures.Gesture("→:1,0")
lineToBottomRight := HotGestures.Gesture("↘:1,1")
s := HotGestures.Gesture("S:0,-1|0,-1|-1,-1|-1,-1|-2,-1|-1,-1|-1,-1|-1,0|-2,-1|-2,-2|-3,-1|-4,-2|-5,-1|-7,-1|-7,0|-9,0|-8,0|-9,0|-8,0|-6,0|-4,2|-4,1|-4,2|-4,3|-4,3|-5,3|-5,3|-4,3|-4,4|-4,4|-5,5|-4,5|-3,6|-1,7|-1,7|0,8|0,9|2,8|2,7|3,5|3,4|5,4|7,4|9,4|11,5|13,6|14,5|13,5|15,5|14,5|11,5|10,4|7,3|5,2|3,2|2,2|1,2|1,1|1,1|0,2|0,2|0,3|0,4|0,3|-2,4|-2,5|-3,4|-5,5|-6,6|-7,5|-8,6|-10,6|-11,6|-12,5|-11,4|-12,4|-10,4|-7,2|-9,1|-8,1|-8,1|-6,1|-5,0|-3,0|-2,0")
selectAll := HotGestures.Gesture(":0,-1|2,-1|2,-1|3,-2|3,-2|5,-2|5,-3|5,-4|6,-3|5,-4|6,-4|5,-3|4,-3|5,-3|5,-3|4,-4|4,-3|3,-2|2,-2|1,-1|2,-1|1,-2|2,-1|1,-2|2,-1|2,-2|2,-1|1,-2|2,-1|1,-1|2,-2|1,-1|2,-2|1,-1|1,-1|2,-2|1,-1|2,-2|1,-1|2,-2|1,-1|1,-1|2,-2|1,-1|2,-2|1,-1|2,-2|1,-1|1,-1|2,-2|1,-1|1,-2|1,-1|1,-2|1,-1|2,-1|1,-2|2,-2|1,-2|2,-2|1,-1|2,-2|1,-1|1,-1|2,-1|1,-1|2,-1|1,-2|2,-1|1,-1|1,-1|1,-1|1,1|1,1|2,2|2,2|3,3|3,2|4,2|3,2|4,3|4,2|5,2|5,4|6,4|5,4|5,3|5,2|5,3|4,2|3,3|2,2|2,2|2,1|2,2|1,1|1,1|2,2|1,1|2,2|1,1|1,1|2,2|1,1|2,2|1,1|1,2|1,1|1,1|1,2|2,1|1,2|2,1|1,2|2,1|1,1|1,2|2,1|1,2|1,1|1,1|1,2|2,1|1,2|1,1|2,2|1,1|2,1|1,2|1,1|2,2|1,1|2,2|1,1|2,1|1,2|1,1|2,2|1,1|1,2|1,1|1,1|2,1|1,1|1,1|0,1|1,0|0,1|1,1|1,1|1,2|1,1|1,1|1,0|1,1|1,1|1,1|2,1|1,1|1,1")

hgs := HotGestures(0.1)

hgs := HotGestures()
hgs.Register(s, "Save", _ => Send("^s"))
hgs.Register(selectAll, "Select All", _ => Send("^a"))
hgs.Register(rightSlide, "Close Tab", _ => Send("^w"))
hgs.Register(lineToBottomRight, "Close Window", _ => Send("!{F4}"))


; hgs.Hotkey("RButton")

*RButton::{
  hgs.Start() ; Start recording
  KeyWait("RButton") ; Keep recording until RButton is released
  hgs.Stop() ; Stop recording
  ; Check validity of result
  if hgs.Result.Valid { 
    ; hgs.Result.MatchedGesture is the matched gesture object
      switch hgs.Result.MatchedGesture { 
          case rightSlide: 
          ; hgs.Result.MatchedGesture is an empty string if no match
          case "": return 
      }
  }
  ; if no movement or track is too short, hgs.Result.Valid is false, and a right click is expected
  else {
      Send("{RButton}")
  }
}


   