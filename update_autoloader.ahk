#Requires AutoHotkey v1.1
#Include %A_ScriptDir%\config.ahk

mergeIncFilePath := A_ScriptDir . "\includes\inc_autoload.ahk"
FileDelete, %mergeIncFilePath%
;iterate over classes dir and include all .ahk files
classes_dir := A_ScriptDir . "\classes"
Loop Files, %classes_dir%\*.ahk, FR
{
    filePath := A_LoopFileFullPath
    ;MsgBox, %filePath%
    includeString = #Include, %filePath%
    FileAppend, %includeString%`n, %mergeIncFilePath%

}
