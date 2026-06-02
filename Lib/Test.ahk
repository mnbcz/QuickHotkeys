#Include Utils.ahk


class T1{

    __New(){
        MsgBox "T1 __New()"
    }

}


class T2 extends T1{

    __New(){
        MsgBox "T2 __New()"
        super.__New()
    }

}

obj := T2()










