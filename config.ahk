;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName %A_ScriptDir%\bin\fast_keyboard_window_switcher.exe

#NoEnv 
SendMode Input
#SingleInstance force
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
ListLines Off
SetBatchLines -1