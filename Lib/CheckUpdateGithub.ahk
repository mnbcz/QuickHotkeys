
; Делает запрос на Github, и устанавливает результат в Config.

; Использование:

; Обработчик, вызывается чтобы отобразить окно наличия новой версии.
; showUpdateWindowHdl(CheckUpdateGithub){
;    Код отображения окна о наличии новой версии.
; }
; CheckUpdate := CheckUpdateGithub(showUpdateWindowHdl)
; CheckUpdate.checkUpdateOnStart()
class CheckUpdateGithub{

    gitReleasesUrl := "" 


    __New(gitReleasesUrl) {
        this.gitReleasesUrl := gitReleasesUrl
    }


    ; Отправляет запрос на Github.
    ; Возвращает Map последнего релиза, или false если нельзя получить,
    ; таймаут, ответ не успешен, интернет отключен, и тд. 
    getLastRelease(){

        try{

            local whr := ComObject("WinHttp.WinHttpRequest.5.1")
            
            ; arg-3 - true - async. Вызов метода Send() возвращает сразу, и не ждёт ответа.
            ;         false - sync. Send() ждёт ответа.
            whr.Open("GET", this.gitReleasesUrl, true)
            
            ; whr.Open("GET", "http://localhost:3000/test", true)
            
            whr.SetRequestHeader("Accept", "application/vnd.github+json")
            whr.SetRequestHeader("X-GitHub-Api-Version", "2022-11-28")

            whr.Send()

            ; Таймаут в секундах
            local res := whr.WaitForResponse(20, false)
            if(!res){
                ; Превышен таймаут запроса
                ; MsgBox "Timeout Request"
                return false
            }


            if(whr.Status != 200){
                ; Status =:
                ; 404 - Resource not found. Страница не найдена.
                ; 200 - OK
                ; MsgBox whr.Status
                return false
            }

            local resJson := Map()

            ; Ответ от сервера
            try{
                resJson := JSON.Parse(whr.ResponseText)
            }catch as e {
                ; Ответ не JSON
                ; MsgBox "An error was thrown!`nSpecifically: " e.Message
                return false
            }

            ; Тип переменной resJson = Array or Map
            ; MsgBox type(resJson)

            ; Получаем первый элемент массива, и возвращаем
            for k, v in resJson{
                local tag_name := v.Get("tag_name", false)
                if(!tag_name){
                    return false
                }

                return v
            }

        }catch as e {
            ; Интернет отключен.
            ; MsgBox "An error was thrown!`nSpecifically: " e.Message
            ; Exit
            return false
        }

    }




    ; Отправляет запрос на Github, о наличии новой версии.
    ; Возвращает false, если есть ошибки запроса.
    ; Возвращает true, и вызывает колбэк dataHdl(data), если успешно.
    check(dataHdl){

        local config := {}

        ; Проверяем не прошёл ли таймаут запроса на сервер:

        ; Делаем запрос на сервер о наличии новой версии, если таймаут прошёл:
        local currentVersionFromGit := this.getLastRelease()

        ; Убеждаемся что нужные данные не пустые:

        if(!currentVersionFromGit){
            return false
        }

        ; Последняя версия из Git.
        local tag_name_git := currentVersionFromGit.Get("tag_name", false)
        if(!tag_name_git){
            return false
        }

        ; Устанавливаем глобальные переменные:

        config.newVersionUrl := currentVersionFromGit.Get("html_url", "")
        config.downloadUrl := currentVersionFromGit.Get("assets")[1].Get("browser_download_url", "")
        config.newVersion := currentVersionFromGit.Get("tag_name", "")
        config.newVersionCheckTime := A_Now

        dataHdl(config)

        return true

    }


    


}



