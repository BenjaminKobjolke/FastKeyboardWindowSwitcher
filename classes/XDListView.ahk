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

    updateRows(filteredWindows, allWindows, windowHistory, contentType) {
        
        LV_Delete()  

        currentDesktop := this.vd.getCurrentDesktopNum()    
        
        ;filteredWindows.sort()

        if S.useVirtualDesktops() = 1
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
    
            if(contentType = contentTypeTrayIcons) {            
                this.clv.Row(A_Index, , S.guiTextColorTrayIcons())            
            } else if S.useVirtualDesktops() = 1
            { 
                if(desktop = currentDesktop) 
                {
                    this.clv.Row(A_Index, , S.guiTextColor())
                }
                else if(desktop = 0) 
                {                
                    this.clv.Row(A_Index, , S.virtualDesktopAllDesktopsTextColor())
                }            
                else
                {
                    this.clv.Row(A_Index, , S.virtualDesktopOtherDesktopsTextColor())
                }
            } else {
                if(!window.getIsRunning()) {
                   this.clv.Row(A_Index, , S.guiTextColorHistory())
                } else {
                    this.clv.Row(A_Index, , S.guiTextColor())
                }          
            }
            counter++  
        }
    }
}