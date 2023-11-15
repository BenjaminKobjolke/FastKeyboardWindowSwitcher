class XDListView {

    vd :=
    s :=
    clv :=
    digitShortcuts :=


    _New() {
    }

    setup(vd, s, clv, digiShortcuts) {

        this.vd := vd
        this.s := s
        this.clv := clv
        this.digiShortcuts := digiShortcuts
   }

    updateColors(filteredWindows, contentType) {
        isTrayIconsContent := 0        
        if(contentType = this.s.contentTypeTrayIcons()) {            
            isTrayIconsContent := 1
        }
        
        useVirtualDesktops := this.s.useVirtualDesktops()
        amount := filteredWindows.length()
        textColor := this.s.guiTextColor()

        if(isTrayIconsContent = 1) {            
            textColor := this.s.guiTextColorTrayIcons()
        } else if useVirtualDesktops = 1
        { 
            if(desktop = 0) 
            {                
                textColor := this.s.virtualDesktopAllDesktopsTextColor()
            }            
            else if(desktop != currentDesktop)
            {
                textColor := this.s.virtualDesktopOtherDesktopsTextColor()
            }
        } 

        this.clv.clear()
        Loop % LV_GetCount()
        {
            window := filteredWindows.get(A_Index)
            if(!window.getIsRunning()) {
                this.clv.Row(A_Index, , this.s.guiTextColorHistory())
            } else {
                this.clv.Row(A_Index, , textColor)
            }                                  
        }
    }

    updateRows(filteredWindows, allWindows, windowHistory, contentType) {
        
        LV_Delete()  

        currentDesktop := this.vd.getCurrentDesktopNum()    
        
        ;filteredWindows.sort()

        if this.s.useVirtualDesktops() = 1
        { 
            filteredWindows.filterByDesktop(currentDesktop)
        }   

        amount := filteredWindows.length()
        counter := 1
        
        ;M sgBox, > %amount%
        Loop %amount%
        {
            window := filteredWindows.get(A_Index)
            title := window.getTitle()  
            runIndex := window.getRunIndex()
            title =  %runIndex% %title%
            ;M sgBox, %title%    
            counter := 3
            process_name := ""
            if(this.s.showProcessName()) {
                process_name := window.getProcessName()
            }
            if(this.s.useVirtualDesktops()) {
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

            pinned := ""
            if(allWindows.hasWindow(window)) {
                if(windowHistory.hasWindow(window)) {
                    pinned := "P"
                }       
            }
            
            LV_Add("", title, process_name, desktopText, pinned)  
    
            counter++  
        }

        this.updateColors(filteredWindows, contentType)
    }
}