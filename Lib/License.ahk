; License.ahk

; mj4njgk2lk1ji9ij
; Пароль для шифрования, расшифрования, всех шифрованных данных.
global encryptPassword := "mj4njgk2lk1ji9ij"

; SetWorkingDir("D:\Sources\Autohotkey\QuickHotkeys 2")
; #Include %A_ScriptDir%
; https://githb.com/jNizM/AHK_CNG
; A_ScriptDir - The full path of the directory where the current script 
; is located.

; For tests:
; #Include %A_ScriptDir%/Lib/AHK_CNG/src/Class_CNG.ahk
; #Include %A_ScriptDir%\Lib\ahk2_lib\WebView2\WebView2.ahk
; #Include %A_ScriptDir%\modules\LicenseExpired\LicenseExpired.ahk



; Содержит методы которые:
; Шифруют, расшифровывают.
; Возвращают id компьютера.
; Создают/возвращают файл регистрации в реестре.
; Проверяет действительность лицензии.
; Отправляет запрос на сервер для проверки лицензии.
class License{

    ; "HKLM\SOFTWARE\" appName (для все пользователей. Требует прав админ)
    ; "HKU\SOFTWARE\" appName (для активного пользователя)
    regKeyName := ""

    __New(regKeyName) {
        this.regKeyName := regKeyName
    }

    ; Возвращает id BaseBoard компьютера.
    getBaseBoardId(){
        ; https://www.autohotkey.com/boards/viewtopic.php?style=1&t=99741
        for objItem in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_BaseBoard"){
            return objItem.Manufacturer " " objItem.Product
        }
    }

    ; Шифрует строку, и возвращает зашифрованную.
    ; Поступает строка которую нужно зашифровать.
    encryptStr(str){
        global encryptPassword
        return Encrypt.String("AES", "CBC", str, encryptPassword, encryptPassword)
    }

    ; Расшифровывает строку, и возвращает расшифрованную.
    ; Поступает зашифрованная строка.
    decryptStr(encryptedStr){
        global encryptPassword
        return Decrypt.String("AES", "CBC", encryptedStr, encryptPassword, encryptPassword)
    }


    ; Создаёт reg файл.
    ; Который содержит зашифрованную строку, JSON с ключами:
    ; CompId, licenseKey, dateReg.
    createLicenseInFile(key, regFilePath){

        local compId := this.getBaseBoardId()

        local jsonMap := Map()
        jsonMap["compId"] := compId
        jsonMap["key"] := key
        jsonMap["dateCreate"] := A_Now

        local str := JSON.Stringify(jsonMap)

        str := this.encryptStr(str)

        if(FileExist(regFilePath)){
            FileSetAttrib "-SHR", regFilePath
            FileDelete regFilePath
        }
        FileAppend str, regFilePath

        ; Делаем файл скрытым h, и системным s (суперскрытым)
        ; S = SYSTEM, H = HIDDEN, R = READONLY
        FileSetAttrib "+SHR", regFilePath

    }


    ; Возвращает Map из лицензии, из файла.
    ; Или false если файла нет, или нельзя прочитать.
    ; Нужно вызывать в try, файл лицензии может быть повреждён.
    getLicenseFromFile(regFilePath){

        if(!FileExist(regFilePath)){
            return false
        }

        local regText := FileRead(regFilePath)
        if(!regText) {
            return false
        }
        regText := this.decryptStr(regText)
        return JSON.Parse(regText)
        
    }


    ; Добавляет в реестр переменную varName, с текстом str.
    ; varName := "Reg"
    setStrInRegistry(str, varName := false){

        ; local compId := this.getBaseBoardId()

        ; local jsonMap := Map()
        ; jsonMap["compId"] := compId
        ; jsonMap["key"] := key
        ; jsonMap["dateCreate"] := A_Now

        ; local str := JSON.Stringify(jsonMap)
        ; str := this.encryptStr(str)

        if(varName){
            RegWrite str, "REG_SZ", this.regKeyName, varName
        }else{
            ; varName = (default)
            RegWrite str, "REG_SZ", this.regKeyName
        }

    }

    
    ; Возвращает строку из реестра. 
    ; Или false если такого ключа в реестре нет.
    ; varName := "Reg"
    getStrFromRegistry(varName := false){
        
        if(varName){
            ; false - будет возвращаться если ключа не существует.
            return RegRead(this.regKeyName, varName, false)
        }else{
            return RegRead(this.regKeyName, , false)
        }

    }


    ; Возвращает Map.
    ; Поступает зашифрованная строка.
    ; Если строка повреждена, нельзя пропарсить, возвращает false.
    getMapFromEncryptedString(str){
        try{
            local decryptedText := this.decryptStr(str)
            return JSON.Parse(decryptedText)
        }catch as e{
            return false
        }
    }

    ; Возвращает зашифрованную строку.
    ; Поступает Map.
    getEncryptedStrFromMap(jsonMap){
        local str := JSON.Stringify(jsonMap)
        return this.encryptStr(str)
    }


    
    ; Проступает массив времён, вида A_Now.
    ; В конец массива добавляется ещё arr.Push(A_Now).
    ; Время в каждом следующем элементе должно быть больше чем в предыдущем.
    ; Если так, то возвращает true, иначе false.
    checkSequenceTime(arr){

        arr.Push(A_Now)

        local d2 := arr.Pop()

        while arr.Length{
            local d1 := arr.Pop()
            local dateDif := DateDiff(d2, d1, "Seconds") 
            if(dateDif < 0){
                return false
            }else{
                d2 := d1
            }

        }

        return true

    }


}








