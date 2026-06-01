
;  A hotkey press will be ignored whenever that hotkey is already running 
#MaxThreadsBuffer 0
#MaxThreadsPerHotkey 1

; vk07 is unassigned. 
; vkE8
A_MenuMaskKey := "vk07"  
; #UseHook

; Только один экземпляр такого скрипта может работать. Заменяет преждний.
#SingleInstance Force
; Recommended for performance and compatibility with future AutoHotkey releases.
; REMOVED: #NoEnv 
; Recommended for new scripts due to its superior speed and reliability.
SendMode("Input")

; Hooks:
; Чтобы работала переменная A_TimeIdlePhysical - число милисекунд с момента нажатия кнопки.
; Учитывать только физический ввод.
InstallKeybdHook()
InstallMouseHook()
; KeyHistory()

; -1 - скрипт никогда не засыпает, работает на максимальной скорости.
; REMOVED: SetBatchLines, -1
SetWorkingDir(A_ScriptDir)

; Скорость обновления картинки для окон.
; Больше значение, меньше качество, но лучше для CPU.
SetWinDelay(9)

; 2 - В функциях WinTitle, устанавливает совпадения заголовка везде в строке.
SetTitleMatchMode 2

; Чтобы одновременно нажатые клавиши не вызывали окно сообщения.
A_MaxHotkeysPerInterval := 200

; Требуется для правильной работы класса WinEvent.
; Если включить true, то весь скрипт не работает.
; DetectHiddenWindows true

; Add manifest to exe.
; 24 - (RT_MANIFEST)
; 1 - Resource name
;@Ahk2Exe-AddResource *24 QuickHotkeys.exe.manifest, 1

; Устанавливаем картинку программы
;; @Ahk2Exe-SetMainIcon icons/Key.ico
;; @Ahk2Exe-AddResource icons/Key.ico, 160  ; Replaces 'H on blue'
;; @Ahk2Exe-AddResource icons/Key.ico, 206  ; Replaces 'S on green'
;; @Ahk2Exe-AddResource icons/Key.ico, 207  ; Replaces 'H on red'
;; @Ahk2Exe-AddResource icons/Key.ico, 208  ; Replaces 'S on red'

;@Ahk2Exe-SetMainIcon icons/logo.ico
;@Ahk2Exe-AddResource icons/logo.ico, 160  ; Replaces 'H on blue'
;@Ahk2Exe-AddResource icons/logo.ico, 206  ; Replaces 'S on green'
;@Ahk2Exe-AddResource icons/logo.ico, 207  ; Replaces 'H on red'
;@Ahk2Exe-AddResource icons/logo.ico, 208  ; Replaces 'S on red'

