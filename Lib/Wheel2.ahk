
class Wheel2 {
  
  wheelDownCallback := 0
  wheelUpCallback := 0

  setWheelDownCallback(wheelDownCallback){
    this.wheelDownCallback := wheelDownCallback
  }

  setWheelUpCallback(wheelUpCallback){
    this.wheelUpCallback := wheelUpCallback
  }

  down(){
    if(this.wheelDownCallback){
      this.wheelDownCallback()
    }
  }

  up(){
    if(this.wheelUpCallback){
      this.wheelUpCallback()
    }
  }

}

