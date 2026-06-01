
#Include ../../Lib/CheckUpdateGithub.ahk
#Include ./NewVersionAvailableWindow/NewVersionAvailableHtml.ahk


; Требует уже установленные:
; Modules.Data
class Update {

  ; Стартовать проверку только при старте скрипта, не при перезагрузке.
  check() {
    global config
    ; Разница в часах, от последнего времени проверки новой версии.
    local dateDifTrial := DateDiff(A_Now, config.newVersionCheckTime, "h")
    if (dateDifTrial > config.newVersionCheckTimeout) {
      ; Выполняется только при старте, не перезагрузке скрипта.
      local commandLine := DllCall("GetCommandLine", "Str")
      if !InStr(commandLine, " /restart") {
        ; Это не перезагрузка, это старт скрипта.
        ; SetTimer () => (
        ;     checkUpdate()
        ; ), config.checkUpdate_FromStartTimeout
        SetTimer checkUpdate, config.checkUpdate_FromStartTimeout
      }
    }

    ; ==========================================================

    checkUpdate() {
      global config, Modules
      ; MsgBox "checkUpdate()"
      local CheckUpdate_Github := CheckUpdateGithub(config.gitReleasesUrl)
      CheckUpdate_Github.check(dataHdl)

      ; Обработчик, вызывается чтобы отобразить окно наличия новой версии.
      dataHdl(data) {
        for k, v in data.OwnProps() {
          config[k] := v
        }
        Modules.Data.save(data)
        ; MsgBox "newVersion = " . config.newVersion
        ; MsgBox "currentVersion = " . config.currentVersion
        ; Если появилась новая версия, tag который отличается от активного
        if (config.newVersion != config.currentVersion) {
          ; MsgBox "NewVersionAvailableHtml()"
          ; Открывает окно - есть новая версия
          NewVersionAvailableHtml(config)
        }
      }
    }
  }
}



