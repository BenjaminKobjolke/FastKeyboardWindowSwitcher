SetupGui:
    Gui, +LastFound +AlwaysOnTop -Caption   
    Gui, Color, black,black
    WinSet, Transparent, % S.guiTransparency()
    
    Gui,Font,s14 c%guiTextColor% bold,Calibri
    Gui, Add, StatusBar,  vMyStatusBar  -Theme BackgroundSilver
    GoSub, UpdateStatusBar
    
    textSize := S.guiTextSize()
    textColor := S.guiTextColor()
    Gui,Font,s%textSize% c%textColor% bold,Calibri

    ;WS_EX_CLIENTEDGE = E0x200 removes the border
    ;Gui, Add, ListBox, vindex gListBoxClick x2 y2 -E0x200 AltSubmit -VScroll
    columns = Name
    columns := columns . "|Process"
    
    columns := columns . "|Desktop"
    
    columns := columns . "|Pinned"
    
    if S.showInput()
    {
        textColorInput := S.guiTextColorInput()
        Gui,Font,s%textSize% c%textColorInput% bold,Calibri
        Gui, Add, Text, vInputText, 
        Gui,Font,s%textSize% c%textColor% bold,Calibri
    }    

    Gui, Add, ListView, vindexListView gMyListView hwndHLV x20 y20 -E0x200 AltSubmit -VScroll -HScroll -Multi -WantF2 -Hdr NoSort NoSortHdr 0x2000 -E0x200, %columns%
    if S.guiShowHeader()
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

    SetTimer,CheckIfGuiStillActive, Off
    ; restore the originally active window if 
    ; activateselectioninbg is enabled 
    if activateselectioninbg <> 
        WinActivate, ahk_id %orig_active_id% 

return

CheckIfGuiStillActive:
    Return
    
    id := WinActive("A")
    
    if(id <> switcher_id)
    {
        GoSub, CloseGui
    }
return

UpdateStatusBar:   
    newText = 
    if(showTrayIcons = 1) {
        newText = Listing tray icons
    } else {
        newText = Listing windows
    }   
    
    if(autoActivateIfOnlyOne) {
        if(showTrayIcons = 1) {
            newText = %newText% | Auto activate not supported for tray icons  
        } else {
            newText = %newText% | Auto activate enabled
        }                
    } else {
        newText = %newText% | Auto activate disabled
    }   
    
    if(S.useVirtualDesktops() = 1) {
        newText = %newText% | Virtual Desktops enabled
    } else {
        newText = %newText% | Virtual Desktops disabled
    }

    if(S.useDelToEndTask()) {
        if(showTrayIcons = 1) {
            newText = %newText% | Kill tasks with DEL not supported for tray icons  
        } else {
            newText = %newText% | Kill tasks with DEL enabled
        }
    } else {
        newText = %newText% | Kill tasks with DEL disabled
    }    

    if(showTrayIcons = 1) {
        newText = %newText% | Pin tasks with F2 not supported for tray icons  
    } else {
        newText = %newText% | Pin / unpin tasks with F2 
    }    
    SB_SetText(newText, 1)
return

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

CalculateWindowDimensions(guiSpacingHorizontal, guiSpacingVertical) {
    
    winTools := new WinTools()
    scale := A_ScreenDPI / 96
    
    CurrentMonitorIndex := winTools.getCurrentMonitorIndex()	
    SysGet, MonitorWorkArea, MonitorWorkArea, %CurrentMonitorIndex%
    
    monitorWidth := MonitorWorkAreaRight - MonitorWorkAreaLeft
    monitorHeight := MonitorWorkAreaBottom - MonitorWorkAreaTop
   
    spacingHorizontalPx := monitorWidth * (guiSpacingHorizontal / 100)
    width := monitorWidth - (spacingHorizontalPx * 2) 
    width := width / scale
    spacingVerticalPx := monitorHeight * (guiSpacingVertical / 100)
    height := monitorHeight - (spacingVerticalPx * 2)
    height := height / scale
    x := MonitorWorkAreaLeft + spacingHorizontalPx
    y := MonitorWorkAreaTop + spacingVerticalPx

    array := [x, y, width, height]
    return array
}

UpdateGui:
    GuiControl,, Edit1 
    GuiControl,, InputText 
    GoSub, RefreshWindowList 

    WinGet, orig_active_id, ID, A 
    prev_active_id = %orig_active_id%

    dimensions := CalculateWindowDimensions(S.guiSpacingHorizontal(), S.guiSpacingVertical())
    if(dimensions[3] <= 0 && dimensions[4] <= 0) {
        dimensions := CalculateWindowDimensions(S.defaultGuiSpacingHorizontal(), S.defaultGuiSpacingVertical())
    } else if(dimensions[3] <= 0 ) {
        dimensions := CalculateWindowDimensions(S.defaultGuiSpacingHorizontal(), S.guiSpacingVertical())
    } else if(dimensions[4] <= 0 ) {
        dimensions := CalculateWindowDimensions(S.guiSpacingHorizontal(), S.defaultGuiSpacingVertical())
    }

    x := dimensions[1]
    y := dimensions[2]
    width := dimensions[3] 
    height := dimensions[4]
    ;M sgBox, %x% %y% %width% %height%
    inputTextX := 28

    processColumnWidth := 0
    if S.showProcessName()
    {
        processColumnWidth := width * 0.2
    }

    desktopColumnWidth := 0
    if S.useVirtualDesktops()
    {
        desktopColumnWidth := width * 0.2
    }

    statusColumnWidth := 150

    ;M sgbox, % "x" x " y" y " w" width " h" height 
    
    statusBarHeight := 50
    listWidth := width - 10
    listHeight := height - 10 - statusBarHeight
    litViewY := 0
    if S.showInput()
    {
        listHeight := listHeight - 50
        litViewY := 50
    }

    
    column1Width := listWidth - processColumnWidth - desktopColumnWidth - statusColumnWidth
    ;MsgBox, 1 %listWidth% 2 %column1Width% 3 %processColumnWidth% 4 %desktopColumnWidth %
    ;MsgBox, %column1Width%
    LV_ModifyCol(1, column1Width)
    counter := 2
    LV_ModifyCol(counter, processColumnWidth)
    counter := counter + 1

    LV_ModifyCol(counter, desktopColumnWidth)
    counter := counter + 1

    LV_ModifyCol(counter, statusColumnWidth)

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
        
    SetTimer, CheckIfGuiStillActive, 500
return