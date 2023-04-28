#Requires AutoHotkey v1.1
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName %A_ScriptDir%\bin\iswitch.exe

#NoEnv 
SendMode Input
#SingleInstance force
SetTitleMatchMode, 2
SetWorkingDir %A_ScriptDir%
ListLines Off
SetBatchLines -1

; close script from another script by sending exit as argument
command := A_Args[1]
if (command == "exit") 
{
	ExitApp
}

#Include %A_ScriptDir%\classes\Window.ahk
#Include %A_ScriptDir%\classes\Windows.ahk

#Include, %A_ScriptDir%/libraries/tray_lib.ahk
#Include, %A_ScriptDir%/autohotkey_libraries/WinTools.ahk
#Include, %A_ScriptDir%/github_modules/Class_LV_Colors/Sources/Class_LV_Colors.ahk

#Include %A_ScriptDir%\node_modules
#Include biga.ahk\export.ahk
A := new biga()

#Include %A_ScriptDir%\classes\TrayControl.ahk
trayControl := new TrayControl()

#Include %A_ScriptDir%\classes\Settings.ahk
S := new Settings()

filteredWindows := new Windows()
allWindows := new Windows()

If Not A_IsAdmin {
	Run, *RunAs %A_ScriptFullPath% ; Requires v1.0.92.01+
	ExitApp
}

;---------------------------------------------------------------------- 
; 
; User configuration 
; 

autoActivateIfOnlyOne := S.autoActivateIfOnlyOne()

sortedElementsArray := Array()
guiActive := 0

; set this to yes to enable first letter match mode where the typed 
; search string must match the first letter of words in the 
; window title (only alphanumeric characters are taken into account) 
; 
; For example, the search string "ad" matches both of these titles: 
; 
;  AutoHotkey - Documentation 
;  Anne's Diary 
; 
firstlettermatch = 

; set this to yes to enable activating the currently selected 
; window in the background 
activateselectioninbg =  

; number of milliseconds to wait for the user become idle, before 
; activating the currently selected window in the background 
; 
; it has no effect if activateselectioninbg is off 
; 
; if set to blank the current selection is activated immediately 
; without delay 
bgactivationdelay = 300 


; Close switcher window if the user activates an other window. 
; It does not work well if activateselectioninbg is enabled, so 
; currently they cannot be enabled together.    
closeifinactivated = 

selectedIndex := 1

showTrayIcons := 0

forceWindowListRefresh := 0

if S.useVirtualDesktops() = 1
{
    DetectHiddenWindows On
    #Include, %A_ScriptDir%/github_modules/VD.ahk/_VD.ahk
    dummyFunction1() {
        static dummyStatic1 := VD.init()
    }   
    
    ;VD.createUntil(2)

    
}

if activateselectioninbg <> 
    if closeifinactivated <> 
    { 
        msgbox, activateselectioninbg and closeifinactivated cannot be enabled together 
        exitapp 
    } 

; List of subtsrings separated with pipe (|) characters (e.g. carpe|diem). 
; Window titles containing any of the listed substrings are filtered out 
; from the list of windows. 
; list is loaded from file filterlist.txt
; example asticky|blackbox|app center
FileRead, filterlist, filterlist.txt

; List of shortcuts for window titles
; one shortcut per line
; example: tb|thunderbird
FileRead, shortcutslist, shortcutslist.txt


; Set this yes to update the list of windows every time the contents of the 
; listbox is updated. This is usually not necessary and it is an overhead which 
; slows down the update of the listbox, so this feature is disabled by default. 
dynamicwindowlist = 
if S.useVirtualDesktops() = 1
{
    dynamicwindowlist = yes
}

; path to sound file played when the user types a substring which 
; does not match any of the windows 
; 
; set this to blank if you don't want a sound 
; 

/*
nomatchsound = %windir%\Media\ding.wav 

if nomatchsound <> 
    ifnotexist, %nomatchsound% 
        msgbox, Sound file %nomatchsound% not found. No sound will be played. 
*/

;---------------------------------------------------------------------- 
; 
; Global variables 
; 
;     numallwin      - the number of windows on the desktop 
;     allwinarray    - array containing the titles of windows on the desktop 
;                      dynamicwindowlist is disabled 
;     allwinidarray  - window ids corresponding to the titles in allwinarray 
;     numwin         - the number of windows in the listbox 
;     idarray        - array containing window ids for the listbox items 
;     orig_active_id - the window ID of the originally active window 
;                      (when the switcher is activated) 
;     prev_active_id - the window ID of the last window activated in the 
;                      background (only if activateselectioninbg is enabled) 
;     switcher_id    - the window ID of the switcher window 
;     filters        - array of filters for filtering out titles 
;                      from the window list 
;     shortcuts        - array of shortcuts for filtering out titles 
;                      from the window list 
; 
;---------------------------------------------------------------------- 
allwinDesktopIndex := Array()
allwinProcessName := Array()

if (!a_iscompiled) {
	Menu, tray, icon, icon.ico,0,1
}

AutoTrim, off 

if filterlist <> 
{ 
    loop, parse, filterlist, | 
    { 
        filters%a_index% = %A_LoopField% 
    } 
} 

shortcuts := []   
amountOfShortcuts := 0
if shortcutslist <> 
{ 
    index := 0
    loop, parse, shortcutslist, `n, `r
    { 
        ;d := [] 
        ;shortcuts%a_index% = %A_LoopField% 
        
        ;M sgBox, %A_LoopField% 
        StringSplit, cArray, A_LoopField, | 
        val = %cArray2%
        ;M sgBox, %val%
        ; string split pipe
        val = %cArray1%
        shortcuts[index, 0] := val
        ;d.Push(1)
        val = %cArray2%
        shortcuts[index, 1] := val
        ;d.Push(2)
        ;M sgBox, %d%
        ;c.Push(d)
        index := index + 1 
       
    } 

    amountOfShortcuts := index 
} 

windowIsOpen := 0

#Include %A_ScriptDir%\includes\inc_gui.ahk

return

#If S.hotkeyReload()
    if(!A_IsCompiled) {            
        #y::                
            Send ^s
            reload
        return             
    }
#If

/*
#If S.useVirtualDesktops() = 1
    !F1::VD.goToDesktopNum(1)
    !F2::VD.goToDesktopNum(2)
    +F1::VD.MoveWindowToDesktopNum("A", 1)
    +F2::VD.MoveWindowToDesktopNum("A", 2)

    +F10::VD.TogglePinWindow("A")
#If
*/

CapsLock:: 
    SetTimer, CheckHotkey, Off
    SetTimer, StartHotkeyChecking, 300
    GoSub, HotkeyAction
    SetTimer, StartHotkeyChecking, Off
    SetTimer, CheckHotkey, Off
return

StartHotkeyChecking:
    SetTimer, StartHotkeyChecking, Off
    SetTimer, CheckHotkey, 10
return

CheckHotkey:
    FormatTime, Time
    keystate := GetKeyState("CapsLock", "P")
    ;T oolTip, %Time% >%keystate%<
    if(keystate = "1") {
        SetTimer, CheckHotkey, Off
        send, {esc} 
        GoSub, CloseGui
    }
return

HotkeyAction:    
    search = 
    numallwin = 0 
    if(S.alwaysStartWithTasks())  {
        if(showTrayIcons = 1) {
            forceWindowListRefresh = 1
            showTrayIcons = 0
        }        
    }

    GoSub, UpdateGui

    Loop 
    {  
        Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right} 

        if ErrorLevel = EndKey:enter 
        { 
            GoSub, ActivateWindow             
            
            break 
        } 

        if ErrorLevel = EndKey:escape 
        { 
            GoSub, CloseGui 
            break
        } 

        if ErrorLevel = EndKey:backspace 
        { 
            GoSub, DeleteSearchChar 
            continue 
        } 

        if ErrorLevel = EndKey:tab 
            if completion = 
                continue 
            else 	
                input = %completion% 
        
        ; pass these keys to the selector window 

        if ErrorLevel = EndKey:up 
        {         
            Send, {up} 
            GoSuB ActivateWindowInBackgroundIfEnabled 
            continue 
        } 

        if ErrorLevel = EndKey:down 
        { 
            Send, {down} 
            GoSuB ActivateWindowInBackgroundIfEnabled 
            continue 
        } 

        if ErrorLevel = EndKey:pgup 
        { 
            Send, {pgup} 

            GoSuB ActivateWindowInBackgroundIfEnabled 
            continue 
        } 

        if ErrorLevel = EndKey:pgdn 
        { 
            Send, {pgdn} 
            GoSuB ActivateWindowInBackgroundIfEnabled 
            continue 
        } 

        ; FIXME: probably other error level cases 
        ; should be handled here (interruption?) 

        ; invoke digit shortcuts if applicable 
        if S.digitShortcuts() <> 
            if numwin <= 10 
                if input in 1,2,3,4,5,6,7,8,9,0 
                { 
                    if input = 0 
                        input = 10  

                    if numwin < %input% 
                    { 
                        if nomatchsound <> 
                            SoundPlay, %nomatchsound% 
                        continue 
                    } 

                    ;T oolTip, %input%
                    ;GuiControl, choose, indexListView, %input%                     
                    selectedIndex = %input%
                    GoSub, ActivateWindow 
                    break 
                } 

        ; process typed character 

        search = %search%%input% 
        ;T oolTip, %search%

        ; check if the search matches a shortcut
        ; iterate shortcuts
        index = 0
        Loop, %amountOfShortcuts%
        {
            cVal := % shortcuts[index, 0]        
            ;M sgBox, %search% %cVal%
            if(search = cVal)
            {
                search = % shortcuts[index, 1]
                break
            }    
            index := index + 1
        }    

        ;T oolTip, %search%
        GuiControl,, Edit1, %search% 
        GuiControl,, InputText, %search% 
        length := StrLen(search)
        if(length > 1)  {
            GoSub, RefreshWindowList 
        }
    } 
    
    Gosub, CleanExit 

return 


RefreshWindowList: 
    ; refresh the list of windows if necessary 
    filteredWindows.clear()

    if ( dynamicwindowlist = "yes" or numallwin = 0 or forceWindowListRefresh = 1) 
    {          
        allWindows.clear()   
        forceWindowListRefresh := 0

        if(showTrayIcons = 1) {            
            trayIcons := trayControl.list()
            numallwin := trayControl.Length()
            
            Loop, % numallwin {
                title := trayIcons[A_Index].process
                this_id := trayIcons[A_Index].hwnd
                ; replace pipe (|) characters in the window title, 
                ; because Gui Add uses it for separating listbox items 
                StringReplace, title, title, |, -, all  
                allWindows.addNew(this_id, title, 0,0)

            }
        } else {
            WinGet, id, list, , , Program Manager 
            Loop, %id% 
            {               
                StringTrimRight, this_id, id%a_index%, 0 
                WinGetTitle, title, ahk_id %this_id% 

                hwnd := id%A_Index%    
                desktopNum := 0        
                if S.useVirtualDesktops() = 1 
                {                
                    desktopNum := VD.getDesktopNumOfWindow("ahk_id" hwnd)
                    If (desktopNum < 0) ;-1 for invalid window, 0 for "Show on all desktops", 1 for Desktop 1
                    {
                        continue
                    }
                    if desktopNum = 2
                    {
                        ;MsgBox, %title% >%desktopNum%<
                        ;continue
                    }
                    
                }            

                ; FIXME: windows with empty titles? 
                if title = 
                    continue 

                ; don't add the switcher window 
                if switcher_id = %this_id% 
                    continue 

                ; don't add titles which match any of the filters 
                if filterlist <> 
                { 
                    filtered = 

                    loop 
                    { 
                        stringtrimright, filter, filters%a_index%, 0 
                        if filter = 
                        break 
                        else 
                            ifinstring, title, %filter% 
                            { 
                            filtered = yes 
                            break 
                            } 
                    } 

                    if filtered = yes 
                        continue 
                } 

                ; replace pipe (|) characters in the window title, 
                ; because Gui Add uses it for separating listbox items 
                StringReplace, title, title, |, -, all 
                

                ; show process name if enabled 
                if S.showProcessName()
                { 
                    WinGet, procname, ProcessName, ahk_id %this_id% 

                    stringgetpos, pos, procname, . 
                    if ErrorLevel <> 1 
                    { 
                        stringleft, procname, procname, %pos% 
                    } 
                
                } 
               
                ;MsgBox, %title%
                allWindows.addNew(this_id, title, procname, desktopNum)           
            }             
        }       
    } 


    amount := allWindows.length()

    Loop, %amount% 
    { 
        window := allWindows.get(A_Index)
        title := window.getTitle()
        ;MsgBox, title %title%
        if search <> 
            if firstlettermatch = 
            { 
                if title not contains %search%, 
                    continue 
            } 
            else 
            { 
                stringlen, search_len, search 

                index = 1 
                match = 

                loop, parse, title, %A_Space% 
                {                    
                    stringleft, first_letter, A_LoopField, 1 

                    ; only words beginning with an alphanumeric 
                    ; character are taken into account 
                    if first_letter not in 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z 
                        continue 

                    stringmid, search_char, search, %index%, 1 

                    if first_letter <> %search_char% 
                        break 

                    index += 1 

                    ; no more search characters 
                    if index > %search_len% 
                    { 
                        match = yes 
                        break 
                    } 
                } 

                if match = 
                    continue    ; no match 
            } 
        ;MsgBox, %title%
        filteredWindows.add(window)
    } 

    noWindowsFound := false
    amount := filteredWindows.length()
    if(amount < 1) {
        noWindowsFound := true
        filteredWindows.addNew(0, "No windows found", "", 0)
    }
    ;MsgBox, %amount%
    selectedIndex := 1
    ; if the pattern didn't match any window 
    if amount = 0 
        ; if the search string is empty then we can't do much 
        if search = 
        { 
            Gui, cancel 
            Gosub, CleanExit 
        } 
        ; delete the last character 
        else 
        { 
            if nomatchsound <> 
                SoundPlay, %nomatchsound% 

            GoSub, DeleteSearchChar 
            return 
        } 

    
    LV_Delete()  

    currentDesktop := VD.getCurrentDesktopNum()    

    filteredWindows.sort()
    
    if S.useVirtualDesktops() = 1
    { 
        filteredWindows.filterByDesktop(currentDesktop)
    }   

    amount := filteredWindows.length()
    counter := 1
    ;MsgBox, > %amount%
    Loop %amount%
    {
        window := filteredWindows.get(A_Index)
        title := window.getTitle()   
        ;MsgBox, %title%    
        counter := 3
        process_name := ""
        if(S.showProcessName()) {
            process_name := window.getProcessName()
        }
        if(S.useVirtualDesktops()) {
            desktop := window.getDesktop()
        }

        if digitshortcuts <> 
        {
            if numwin < 10 
            {      
                title = %counter% %title%
            }
        }   
        desktopText := desktop
        if(desktop = 0) {
            desktopText = pinned
        }
        LV_Add("", title, process_name, desktopText)  
  
        
        if(showTrayIcons = 1) {            
            CLV.Row(A_Index, , S.guiTextColorTrayIcons())            
        } else if S.useVirtualDesktops() = 1
        { 
            if(desktop = currentDesktop) 
            {
                CLV.Row(A_Index, , S.guiTextColor())
            }
            else if(desktop = 0) 
            {                
                CLV.Row(A_Index, , S.virtualDesktopAllDesktopsTextColor())
            }            
            else
            {
                CLV.Row(A_Index, , S.virtualDesktopOtherDesktopsTextColor())
            }
        } else {
            CLV.Row(A_Index, , S.guiTextColor())            
        }
        counter++  
    }

    if(noWindowsFound) {
      return
    } 

    if amount = 1 
        if autoActivateIfOnlyOne 
        { 
            if showTrayIcons = 0
            {
                ; only autoactivate if the search string is not empty
                ; otherwise the gui would close if only one windows is available
                ; and you think the app doesnt work
                if search != 
                {
                    while(A_TimeIdle < 100) 
                    {                
                        Sleep, 100
                    }            
                    GoSub, ActivateWindow 
                    Gosub, CleanExit             
                }
            }
        } 

    GoSub, ActivateWindowInBackgroundIfEnabled 
    GoSub, CheckCompletion

return 

CheckCompletion:

    if(S.tabComplete()) {
        return
    }
    completion = 

    ; completion is not implemented for first letter match mode 
    if firstlettermatch <> 
        return 

    ; determine possible completion if there is 
    ; a search string and there are more than one 
    ; window in the list 

    if search = 
        return 

    amount := filteredWindows.length()
    if amount = 1 
        return 

    loop 
    { 
        nextchar = 

        loop, %amount% 
        { 
            window := filteredWindows.get(A_Index)
            title := window.getTitle()

            if nextchar = 
            {
                substr = %search%%completion% 
                stringlen, substr_len, substr 
                stringgetpos, pos, title, %substr% 
                ;MsgBox, %pos% %substr% %title%
                if pos = -1 
                {                   
                    break 
                }
                pos += %substr_len% 
                ;ToolTip, %title% %pos%
                ; if the substring matches the end of the 
                ; string then no more characters can be completed 
                stringlen, title_len, title 
                if pos >= %title_len% 
                { 
                    pos = -1 
                    break 
                } 

                ; stringmid has different position semantics 
                ; than stringgetpos. strange... 
                pos += 1 
                stringmid, nextchar, title, %pos%, 1 
                substr = %substr%%nextchar%
                ;MsgBox, %substr% 
            } 
            else 
            { 
                stringgetpos, pos, title, %substr% 
                if pos = -1 
                {
                    break 
                }
            } 
        } 

        if pos = -1 
            break 
        else 
        {

            completion = %completion%%nextchar% 
        }
    } 

    if completion <> 
    {
        GuiControl,, Edit1, %search%[%completion%] 
        GuiControl,, InputText, %search%[%completion%] 
    }
return

WaitForUserToEndTyping:
    if(A_TimeIdle > 100) {
        SetTimer, WaitForUserToEndTyping, Off
        GoSub, ActivateWindow 
        Gosub, CleanExit     
    }
return
;---------------------------------------------------------------------- 
; 
; Delete last search char and update the window list 
; 
DeleteSearchChar: 
    if search = 
        return 

    StringTrimRight, search, search, 1 
    GuiControl,, Edit1, %search% 
    GuiControl,,InputText, %search% 
    GoSub, RefreshWindowList 

return 

#If guiActive = 1 and S.useVirtualDesktops() = 1
    F2::  
        window := filteredWindows.get(selectedIndex)
        winid := window.getHwnd()   
        title := window.getTitle()
        VD.MoveWindowToDesktopNum("ahk_id" winid,1)          
        LV_Modify(selectedIndex,, title, 1)
    return
    F3::  
        window := filteredWindows.get(selectedIndex)
        winid := window.getHwnd()   
        title := window.getTitle()
        VD.MoveWindowToDesktopNum("ahk_id" winid,2)          
        LV_Modify(selectedIndex,, title, 2)
    return
    F4::  
        window := filteredWindows.get(selectedIndex)
        winid := window.getHwnd()   
        title := window.getTitle()
        VD.MoveWindowToDesktopNum("ahk_id" winid,3)          
        LV_Modify(selectedIndex,, title, 3)
    return    
    F10::
        window := filteredWindows.get(selectedIndex)
        winid := window.getHwnd()   
        title := window.getTitle()
        VD.TogglePinWindow("ahk_id" winid)  
            
        desktopNum := VD.getDesktopNumOfWindow("ahk_id" winid)      
        desktopText := desktopNum     
        if(desktopNum = 0) 
        {
            desktopText = pinned
        }
        LV_Modify(selectedIndex,, title, desktopText)        
    return
#If

#If guiActive = 1 and S.useDelToEndTask()
    DEL::        
        window := filteredWindows.get(selectedIndex)
        winid := window.getHwnd()  
        if(showTrayIcons = 1) {
            ;trayControl.remove(winid)
        } else {
            WinClose, ahk_id %winid% 
        }
        LV_Delete(selectedIndex)        
    return
#If

#If guiActive = 1
    F9::
        if(autoActivateIfOnlyOne) {
           autoActivateIfOnlyOne := false        
        } else {
            autoActivateIfOnlyOne := true          
        }
        GoSub UpdateStatusBar
    return
#If

#If guiActive = 1
    F1::  
        if(showTrayIcons = 1) {
            showTrayIcons = 0            
        } else {
            showTrayIcons = 1            
        }
        forceWindowListRefresh = 1      
        GoSub UpdateStatusBar
        GoSub RefreshWindowList
    return
#If

;---------------------------------------------------------------------- 
; 
; Activate selected window 
; 
ActivateWindow:

    winTools := new WinTools()
    if(showTrayIcons) {                      
        winTools.moveMouseToCurrentWindowCenter()    
    }

    window := filteredWindows.get(selectedIndex)
    title := window.getTitle()
    ;MsgBox, %title%
    window_id := window.getHwnd() 
    if(window_id = 0) {
        Gui, Submit    
        guiActive := 0 
        return
    }

    if(showTrayIcons) {            
        GetKeyState, state, Ctrl
        if (state = "D") {
            GetKeyState, state, Alt
            if (state = "D") {
                trayControl.doubleClick(window_id)       
            } else {
                trayControl.leftClick(window_id)       
            }
            
        } else {
            trayControl.rightClick(window_id)       
        }
        
        Sleep, 100
        Gui, Submit    
        guiActive := 0 
        /*
        WinGet, ID, List
        Loop %ID%
        {
            WinActivate, ahk_id  ID%A_Index%
            winTools.moveMouseToCurrentWindowCenter() 
            break
        }
        */
        return
    }

    Gui, Submit    
    guiActive := 0 
    
    WinActivate, ahk_id %window_id% 

    GetKeyState, state, Alt
    if (state = "D") {
        guiActive := 0
        WinClose, ahk_id %window_id%
        return
    } 

    winTools.moveMouseToCurrentWindowCenter()    
    /*
    GetKeyState, state, Ctrl
    if (state = "D") {
        Send, ^!m
        
    } 
    */


    ;T ooltip winTopL_x:%winTopL_x% winTopL_y:%winTopL_y% winCenter_x:%winCenter_x% winCenter_y:%winCenter_y%    
    
return 



;---------------------------------------------------------------------- 
; 
; Activate selected window in the background 
; 
ActivateWindowInBackground:           
    guicontrolget, index,, ListView1 
    window := filteredWindows.get(index)
    window_id := window.getHwnd()

    if prev_active_id <> %window_id% 
    { 
        WinActivate, ahk_id %window_id% 
        WinActivate, ahk_id %switcher_id% 
        prev_active_id = %window_id% 
    } 

return 

;---------------------------------------------------------------------- 
; 
; Activate selected window in the background if the option is enabled. 
; If an activation delay is set then a timer is started instead of 
; activating the window immediately. 
; 
ActivateWindowInBackgroundIfEnabled: 

    if activateselectioninbg = 
        return 

    ; Don't do it just after the switcher is activated. It is confusing 
    ; if active window is changed immediately. 
    WinGet, id, ID, ahk_id %switcher_id% 
    if id = 
        return 

    if bgactivationdelay = 
        GoSub ActivateWindowInBackground 
    else 
        settimer, BgActivationTimer, %bgactivationdelay% 

return 

;---------------------------------------------------------------------- 
; 
; Check if the user is idle and if so activate the currently selected 
; window in the background 
; 
BgActivationTimer: 

    settimer, BgActivationTimer, off 

    GoSub ActivateWindowInBackground 

return 

;---------------------------------------------------------------------- 
; 
; Stop background window activation timer if necessary and exit 
; 
CleanExit: 

    settimer, BgActivationTimer, off 

exit 

