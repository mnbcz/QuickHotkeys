

/**
 * Назначает Hotkey(), или отключает Hotkey().
 * @param {Integer} isEnable 
 */
RButtonAndWheel_SetFunction(hotkeysJsonItem) {
  global Modules, hotkeysActions
  
  if (hotkeysJsonItem.isEnable) {
    hotkeysActions.RButtonAndWheel := hotkeysJsonItem.list.value
  } else {
    hotkeysActions.RButtonAndWheel := 0
  }

}


