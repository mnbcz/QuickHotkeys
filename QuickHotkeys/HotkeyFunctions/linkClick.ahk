
global linkClick_isEnable

linkClick_setHotkeys(hotkeysJsonItem){
  if(hotkeysJsonItem.isEnable){
    global linkClick_isEnable := true
  }else{
    global linkClick_isEnable := false
  }
}


