;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName %A_ScriptDir%\bin\iswitch.exe

;https://autohotkey.com/board/topic/30487-iswitchw-cosmetically-enhanced-edition/page-3

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
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

#Include, %A_ScriptDir%/libraries/tray_lib.ahk
#Include, %A_ScriptDir%/autohotkey_libraries/WinTools.ahk
#Include, %A_ScriptDir%/github_modules/Class_LV_Colors/Sources/Class_LV_Colors.ahk

#Include %A_ScriptDir%\node_modules
#Include biga.ahk\export.ahk
A := new biga()

#Include %A_ScriptDir%\classes\TrayControl.ahk
trayControl := new TrayControl()


;-------------------------------------------------------------------------------
RunAsAdmin: ; run as administrator
;-------------------------------------------------------------------------------
If Not A_IsAdmin {
	Run, *RunAs %A_ScriptFullPath% ; Requires v1.0.92.01+
	ExitApp
}
; 
; iswitchw - Incrementally switch between windows using substrings
;
; [MODIFIED by ezuk, 3 July 2008, changes noted below. Cosmetics only.] 
; 
; Required AutoHotkey version: 1.0.25+ 
; 
; When this script is triggered via its hotkey the list of titles of 
; all visible windows appears. The list can be narrowed quickly to a 
; particular window by typing a substring of a window title. 
; 
; When the list is narrowed the desired window can be selected using 
; the cursor keys and Enter. If the substring matches exactly one 
; window that window is activated immediately (configurable, see the 
; "autoactivateifonlyone" variable). 
; 
; The window selection can be cancelled with Esc. 
; 
; The switcher window can be moved horizontally with the left/right 
; arrow keys if it blocks the view of windows under it. 
; 
; The switcher can also be operated with the mouse, although it is 
; meant to be used from the keyboard. A mouse click activates the 
; currently selected window. Mouse users may want to change the 
; activation key to one of the mouse keys. 
; 
; If enabled possible completions are offered when the same unique 
; substring is found in the title of more than one window. 
; 
; For example, the user typed the string "co" and the list is 
; narrowed to two windows: "Windows Commander" and "Command Prompt". 
; In this case the "command" substring can be completed automatically, 
; so the script offers this completion in square brackets which the 
; user can accept with the TAB key: 
; 
;     co[mmand] 
; 
; This feature can be confusing for novice users, so it is disabled 
; by default. 
; 
; 
; For the idea of this script the credit goes to the creators of the 
; iswitchb package for the Emacs editor 
; 
; 
;---------------------------------------------------------------------- 
; 
; User configuration 
; 

IniRead, hotkeyReload, settings.ini, debug, hotkeyReload , 0

DEFAULT_GUI_SPACING_HORIZONTAL := 20
DEFAULT_GUI_SPACING_VERTICAL := 20
IniRead, guiSpacingHorizontal, settings.ini, gui, spacingHorizontal , %DEFAULT_GUI_SPACING_HORIZONTAL%
IniRead, guiSpacingVertical, settings.ini, gui, spacingVertical , %DEFAULT_GUI_SPACING_VERTICAL%
IniRead, guiShowHeader, settings.ini, gui, showheader , 
IniRead, guiTextColor, settings.ini, gui, textColor , 33C4FF

IniRead, guiTextColor, settings.ini, gui, textColor , 33C4FF
IniRead, guiTextColorInput, settings.ini, gui, textColorInput , FFFFFF
IniRead, guiTextSize, settings.ini, gui, textSize , 20
IniRead, guiTransparency, settings.ini, gui, transparency , 180

IniRead, useVirtualDesktops, settings.ini, virtualdesktops, enable , 
IniRead, guiVirtualDesktopOtherTextColor, settings.ini, gui, otherDesktopsTextColor , 0x006868
IniRead, guiVirtualDesktopAllDesktopsTextColor, settings.ini, gui, allDesktopsTextColor , 0x333333

; set this to yes if you want to select the only matching window 
; automatically 
IniRead, autoactivateifonlyone, settings.ini, settings, autoactivateifonlyone , 1
IniRead, usedeltoendtask, settings.ini, settings, usedeltoendtask , 0

IniRead, showInput, settings.ini, settings, showinput, 0 

IniRead, searchMinLength, settings.ini, settings, searchminlength, 1 

sortedElementsArray := Array()
guiActive := 0
; set this to yes if you want to enable tab completion (see above) 
; it has no effect if firstlettermatch (see below) is enabled 
tabcompletion = yes

; set this to yes to enable digit shortcuts when there are ten or 
; less items in the list 
digitshortcuts = yes

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

; show process name before window title. 
showprocessname = 

; Close switcher window if the user activates an other window. 
; It does not work well if activateselectioninbg is enabled, so 
; currently they cannot be enabled together.    
closeifinactivated = 

selectedIndex := 1

showTrayIcons := 0

forceWindowListRefresh := 0

if useVirtualDesktops = 1
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
if useVirtualDesktops = 1
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

;M sgBox, %amountOfShortcuts%
;search = tb



;M sgBox, % shortcuts[1][1] 
;---------------------------------------------------------------------- 
; 
; I never use the CapsLock key, that's why I chose it. 
; 

windowIsOpen := 0

GoSub, SetupGui

return

#If hotkeyReload = 1
    if(!A_IsCompiled) {    
        if(hotkeyReload = 1) {
            #y::
                
                Send ^s
                reload
            return     
        }	
    }
#If

/*
#If useVirtualDesktops = 1
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
/*
^!c::
    GoSub, HotkeyAction
return
*/

SetupGui:
    Gui, +LastFound +AlwaysOnTop -Caption   
    Gui, Color, black,black
    WinSet, Transparent, %guiTransparency%
    
    Gui,Font,s14 c%guiTextColor% bold,Calibri
    Gui, Add, StatusBar,  vMyStatusBar  -Theme BackgroundSilver
    GoSub, UpdateStatusBar
    

    Gui,Font,s%guiTextSize% c%guiTextColor% bold,Calibri

    ;WS_EX_CLIENTEDGE = E0x200 removes the border
    ;Gui, Add, ListBox, vindex gListBoxClick x2 y2 -E0x200 AltSubmit -VScroll
    columns = Name
    if useVirtualDesktops = 1
    {
        columns := columns . "|Desktop"
    }

    
    if showInput = 1
    {
        Gui,Font,s%guiTextSize% c%guiTextColorInput% bold,Calibri
        Gui, Add, Text, vInputText, 
        Gui,Font,s%guiTextSize% c%guiTextColor% bold,Calibri
    }    

    Gui, Add, ListView, vindexListView gMyListView hwndHLV x20 y20 -E0x200 AltSubmit -VScroll  -Multi  -WantF2  -Hdr NoSort NoSortHdr -E0x200, %columns%
    if guiShowHeader = 1
    {
        GuiControl, +Hdr, indexListView
    }

    CLV := New LV_Colors(HLV)

return



MyListView:    
    
    if (A_GuiEvent = "DoubleClick")
    {
        LV_GetText(RowText, A_EventInfo)
        ;T oolTip You double-clicked row number %A_EventInfo%. Text: "%RowText%"        
    }
    if (A_GuiEvent = "I") 
    {        
        selectedIndex :=  A_EventInfo    
    }
    
return



CloseGui:
    guiActive := 0
    Gui, cancel 

    ; restore the originally active window if 
    ; activateselectioninbg is enabled 
    if activateselectioninbg <> 
        WinActivate, ahk_id %orig_active_id% 

return


HotkeyAction:

    search = 
    numallwin = 0 
    
    GuiControl,, Edit1 
    GuiControl,, InputText 
    GoSub, RefreshWindowList 

    WinGet, orig_active_id, ID, A 
    prev_active_id = %orig_active_id%

    dimensions := CalculateWindowDimensions(guiSpacingHorizontal, guiSpacingVertical)
    if(dimensions[3] <= 0 && dimensions[4] <= 0) {
        dimensions := CalculateWindowDimensions(DEFAULT_GUI_SPACING_HORIZONTAL, DEFAULT_GUI_SPACING_VERTICAL)
    } else if(dimensions[3] <= 0 ) {
        dimensions := CalculateWindowDimensions(DEFAULT_GUI_SPACING_HORIZONTAL, guiSpacingVertical)
    } else if(dimensions[4] <= 0 ) {
        dimensions := CalculateWindowDimensions(guiSpacingHorizontal, DEFAULT_GUI_SPACING_VERTICAL)
    }

    x := dimensions[1]
    y := dimensions[2]
    width := dimensions[3]
    height := dimensions[4]

    inputTextX := 28

    desktopColumnWith := 0
    if useVirtualDesktops = 1
    {
        desktopColumnWidth := width * 0.2
    }

    ;M sgbox, % "x" x " y" y " w" width " h" height 
    
    statusBarHeight := 50
    listWidth := width - 10
    listHeight := height - 10 - statusBarHeight
    litViewY := 0
    if showInput = 1
    {
        listHeight := listHeight - 50
        litViewY := 50
    }

    
    column1Width := listWidth - desktopColumnWidth

    LV_ModifyCol(1, column1Width)
    if useVirtualDesktops = 1
    {   
        LV_ModifyCol(2, desktopColumnWidth)
    }    

    ;MsgBox, %column1Width% %desktopColumnWidth% %listWidth%
    Gui, Show, % "x" x " y" y " w" width " h" height iSwitch      
    guiActive := 1
    
    WinSet, Redraw, , ahk_id %HLV%
    ;GuiControl,Move,index, % "w" listWidth  " h" listHeight 
    GuiControl,Move,indexListView, % "w" listWidth  " h" listHeight "y" litViewY
    GuiControl,Move,InputText, % "w" listWidth "x" inputTextX
    ; If we determine the ID of the switcher window here then 
    ; why doesn't it appear in the window list when the script is 
    ; run the first time? (Note that RefreshWindowList has already 
    ; been called above). 
    ; Answer: Because when this code runs first the switcher window 	
    ; does not exist yet when RefreshWindowList is called. 
    WinGet, switcher_id, ID, A 
    ;WinSet, AlwaysOnTop, On, ahk_id %switcher_id% 

    Loop 
    { 
        if closeifinactivated <> 
            settimer, CloseIfInactive, 200 

        Input, input, L1, {enter}{esc}{backspace}{up}{down}{pgup}{pgdn}{tab}{left}{right} 

        if closeifinactivated <> 
            settimer, CloseIfInactive, off 

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

        if ErrorLevel = EndKey:left 
        { 
            direction = -1 
            GoSuB MoveSwitcher 
            continue 
        } 

        if ErrorLevel = EndKey:right 
        { 
            direction = 1 
            GoSuB MoveSwitcher 
            continue 
        } 

        ; FIXME: probably other error level cases 
        ; should be handled here (interruption?) 

        ; invoke digit shortcuts if applicable 
        if digitshortcuts <> 
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

;---------------------------------------------------------------------- 
; 
; Refresh the list of windows according to the search criteria 
; 
; Sets: numwin  - see the documentation of global variables 
;       idarray - see the documentation of global variables 
; 
RefreshWindowList: 
    ; refresh the list of windows if necessary 
    
    if ( dynamicwindowlist = "yes" or numallwin = 0 or forceWindowListRefresh = 1) 
    {             
        forceWindowListRefresh := 0
        numallwin = 0 
        allwinDesktopIndex := Array()

        counter := 0
        if(showTrayIcons = 1) {            
            trayIcons := trayControl.list()
            numallwin := trayControl.Length()
            
            Loop, % numallwin {
                title := trayIcons[A_Index].process
                this_id := trayIcons[A_Index].hwnd
                ; replace pipe (|) characters in the window title, 
                ; because Gui Add uses it for separating listbox items 
                StringReplace, title, title, |, -, all  
                
                counter += 1 
                allwinarray%counter% = %title% 
                allwinidarray%counter% = %this_id%   
            }
        } else {
            WinGet, id, list, , , Program Manager 
            Loop, %id% 
            {               
                StringTrimRight, this_id, id%a_index%, 0 
                WinGetTitle, title, ahk_id %this_id% 

                hwnd := id%A_Index%    
                desktopNum := 0        
                if useVirtualDesktops = 1 
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

                ; show process name if enabled 
                if showprocessname <> 
                { 
                    WinGet, procname, ProcessName, ahk_id %this_id% 

                    stringgetpos, pos, procname, . 
                    if ErrorLevel <> 1 
                    { 
                        stringleft, procname, procname, %pos% 
                    } 

                    stringupper, procname, procname 
                    title = %procname%: %title% 
                } 

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
                
                numallwin += 1 
                allwinarray%numallwin% = %title% 
                allwinidarray%numallwin% = %this_id% 

                
                if useVirtualDesktops = 1
                {                
                    allwinDesktopIndex[numallwin] := desktopNum
                }            
            }             
        }       
    } 

    ; filter the window list according to the search criteria 

    winlist = 
    numwin = 0     
    Loop, %numallwin% 
    { 
        StringTrimRight, title, allwinarray%a_index%, 0 
        StringTrimRight, this_id, allwinidarray%a_index%, 0 
        this_desktop := allwinDesktopIndex[a_index]
        
        ; don't add the windows not matching the search string 
        ; if there is a search string 
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

        if winlist <> 
            winlist = %winlist%| 
        winlist = %winlist%%title%`r%this_id%`r%this_desktop%

        numwin += 1 
        winarray%numwin% = %title% 
    } 
    
    selectedIndex := 1
    ; if the pattern didn't match any window 
    if numwin = 0 
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

    ;T oolTip, %winlist%
    arrayindex = 1 
    
    LV_Delete()  
    
    sortedElementsArray := Array()
    elementsArray := Array()
    idArray := Array()
    
    loop, parse, winlist, | 
    { 
        ;MsgBox, %A_LoopField%
        winArray := StrSplit(A_LoopField, "`r")         
        elementsArray.Push(winArray)
        ++arrayindex 
    } 
    
    elementsArray := A.sortBy(elementsArray, 3)

    currentDesktop := VD.getCurrentDesktopNum()    
    numItems := arrayindex -1    
    
    if useVirtualDesktops = 1
    { 
        Loop %numItems%
        {
            desktop := elementsArray[A_Index][3]
            if(desktop != currentDesktop) 
            {
                continue
            }
            sortedElementsArray.Push(elementsArray[A_Index])
        }
        
        Loop %numItems%
        {
            desktop := elementsArray[A_Index][3]
            if(desktop = currentDesktop) 
            {
                continue
            }
            sortedElementsArray.Push(elementsArray[A_Index])
        }
    } else {
        sortedElementsArray := elementsArray
    }
    


    counter := 1
    Loop %numItems%
    {
        desktop := sortedElementsArray[A_Index][3]             
        title := sortedElementsArray[A_Index][1]        
        win_id := sortedElementsArray[A_Index][2]

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
        ;MsgBox, %A_Index% %title% %desktop%
        LV_Add("", title, desktopText)  
        ;LV_Insert(, , title, desktop)  
        idArray.Push(win_id)    

        if useVirtualDesktops = 1
        { 
            if(desktop = currentDesktop) 
            {
                CLV.Row(A_Index, , %guiTextColor%)
            }
            else if(desktop = 0) 
            {                
                CLV.Row(A_Index, , guiVirtualDesktopAllDesktopsTextColor)
            }            
            else
            {
                CLV.Row(A_Index, , guiVirtualDesktopOtherDesktopsTextColor)
            }
        }
        counter++  
    }

    if numwin = 1 
        if autoactivateifonlyone = 1 
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

    GoSub ActivateWindowInBackgroundIfEnabled 

    completion = 

    if tabcompletion = 
        return 

    ; completion is not implemented for first letter match mode 
    if firstlettermatch <> 
        return 

    ; determine possible completion if there is 
    ; a search string and there are more than one 
    ; window in the list 

    if search = 
        return 
    
    if numwin = 1 
        return 

    loop 
    { 
        nextchar = 

        loop, %numwin% 
        { 
            stringtrimleft, title, winarray%a_index%, 0 

            if nextchar = 
            { 
                substr = %search%%completion% 
                stringlen, substr_len, substr 
                stringgetpos, pos, title, %substr% 

                if pos = -1 
                    break 

                pos += %substr_len% 

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
             } 
             else 
             { 
                stringgetpos, pos, title, %substr% 
                if pos = -1 
                    break 
             } 
        } 

        if pos = -1 
            break 
        else 
            completion = %completion%%nextchar% 
    } 

    if completion <> 
        GuiControl,, Edit1, %search%[%completion%] 

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

#If guiActive = 1 and useVirtualDesktops = 1
    F1::  
        winid := sortedElementsArray[selectedIndex][2]        
        VD.MoveWindowToDesktopNum("ahk_id" winid,1)          
        title := sortedElementsArray[selectedIndex][1]        
        LV_Modify(selectedIndex,, title, 1)
    return
    F2::  
        winid := sortedElementsArray[selectedIndex][2]        
        VD.MoveWindowToDesktopNum("ahk_id" winid,2)          
        title := sortedElementsArray[selectedIndex][1]        
        LV_Modify(selectedIndex,, title, 2)
    return
    F3::  
        winid := sortedElementsArray[selectedIndex][2]        
        VD.MoveWindowToDesktopNum("ahk_id" winid,3)          
        title := sortedElementsArray[selectedIndex][1]        
        LV_Modify(selectedIndex,, title, 3)
    return    
    F10::
        winid := sortedElementsArray[selectedIndex][2]     
        VD.TogglePinWindow("ahk_id" winid)  
        title := sortedElementsArray[selectedIndex][1]        
        desktopNum := VD.getDesktopNumOfWindow("ahk_id" winid)      
        desktopText := desktopNum     
        if(desktopNum = 0) 
        {
        desktopText = pinned
        }
        LV_Modify(selectedIndex,, title, desktopText)        
    return
#If

#If guiActive = 1 and usedeltoendtask = 1
    DEL::        
        winid := sortedElementsArray[selectedIndex][2]        
        WinClose, ahk_id %winid% 
        LV_Delete(selectedIndex)        
    return
#If

#If guiActive = 1
    F9::
  
        if(autoactivateifonlyone = 1) {
            autoactivateifonlyone = 0            
        } else {
            autoactivateifonlyone = 1            
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


UpdateStatusBar:   
    newText = 
    if(showTrayIcons = 1) {
        newText = Listing tray icons
    } else {
        newText = Listing windows
    }   

    if(autoactivateifonlyone = 1) {
        if(showTrayIcons = 1) {
            newText = %newText% | Auto activate not supported for tray icons  
        } else {
            newText = %newText% | Auto activate enabled
        }                
    } else {
        newText = %newText% | Auto activate disabled
    }   
    
    if(useVirtualDesktops = 1) {
        newText = %newText% | Virtual Desktops enabled
    } else {
        newText = %newText% | Virtual Desktops disabled
    }

    if(usedeltoendtask = 1) {
        if(showTrayIcons = 1) {
            newText = %newText% | Kill tasks with DEL not supported for tray icons  
        } else {
            newText = %newText% | Kill tasks with DEL enabled
        }
    } else {
        newText = %newText% | Kill tasks with DEL disabled
    }    
    SB_SetText(newText, 1)
return

;---------------------------------------------------------------------- 
; 
; Activate selected window 
; 
ActivateWindow:
    winTools := new WinTools()
    if(showTrayIcons) {                      
        winTools.moveMouseToCurrentWindowCenter()    
    }

    window_id := idArray[selectedIndex]   
    

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
        
        Sleep, 200
        Gui, Submit    
        guiActive := 0 
        
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
    stringtrimleft, window_id, idarray%index%, 0 

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

;---------------------------------------------------------------------- 
; 
; Cancel keyboard input if GUI is closed. 
; 
GuiClose: 
    guiActive := 0
    send, {esc} 
return 

;---------------------------------------------------------------------- 
; 
; Handle mouse click events on the list box 
; 
ListBoxClick:    
    if (A_GuiControlEvent = "Normal"
        and !GetKeyState("Down", "P") and !GetKeyState("Up", "P"))
        {
            send, {enter} 
        }
return 

;---------------------------------------------------------------------- 
; 
; Move switcher window horizontally 
; 
; Input: direction - 1 for right, -1 for left 
; 
MoveSwitcher: 

    direction *= 100 
    WinGetPos, x, y, width, , ahk_id %switcher_id% 
    x += %direction% 

    if x < 0 
        x = 0 
    else 
    { 
    SysGet screensize, MonitorWorkArea 
    screensizeRight -= %width% 
    if x > %screensizeRight% 
        x = %screensizeRight% 
    } 

    prevdelay = %A_WinDelay%  
    SetWinDelay, -1 
    WinMove, ahk_id %switcher_id%, , %x%, %y% 
    SetWinDelay, %prevdelay% 

return 

;---------------------------------------------------------------------- 
; 
; Close the switcher window if the user activated an other window 
; 
CloseIfInactive: 

    ifwinnotactive, ahk_id %switcher_id% 
        guiActive := 0
        send, {esc} 

return

CoordXCenterScreen(WidthOfGUI,ScreenNumber)
{
SysGet, Mon1, Monitor, %ScreenNumber%
	return (( Mon1Right-Mon1Left - WidthOfGUI ) / 2) + Mon1Left
}

CoordYCenterScreen(HeightofGUI,ScreenNumber)
{
SysGet, Mon1, Monitor, %ScreenNumber%
	return (Mon1Bottom - 30 - HeightofGUI ) / 2
}

GetClientSize(hwnd, ByRef w, ByRef h)
{
    VarSetCapacity(rc, 16)
    DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
    w := NumGet(rc, 8, "int")
    h := NumGet(rc, 12, "int")
}

CalculateWindowDimensions(guiSpacingHorizontal, guiSpacingVertical) {
    
    winTools := new WinTools()
    CurrentMonitorIndex := winTools.getCurrentMonitorIndex()	
    SysGet, MonitorWorkArea, MonitorWorkArea, %CurrentMonitorIndex%
    
    monitorWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
    monitorHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
   
    spacingHorizontalPx := monitorWidth * (guiSpacingHorizontal / 100)
    width := monitorWidth - (spacingHorizontalPx * 2) 

    spacingVerticalPx := monitorHeight * (guiSpacingVertical / 100)
    height := monitorHeight - (spacingVerticalPx * 2)
    
    x := MonitorWorkAreaLeft + spacingHorizontalPx
    y := MonitorWorkAreaTop + spacingVerticalPx

    array := [x, y, width, height]
    return array
}