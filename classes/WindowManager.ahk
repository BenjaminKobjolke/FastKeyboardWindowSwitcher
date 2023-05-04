fn_sortByName(o)
{
    title := o.title
    StringReplace, title, title, +, , All
    StringReplace, title, title, -, , All
    ;M sgBox, % "Sorting by title " . title
	return title
}

fn_sortByIsRunning(o)
{
	return o.isRunning =  0
}


class WindowManager {

    windows := Array()

    __New() {
        this.windows := Array()
    }

    setWithArray(windowArray) {
        this.clear()
        
        amount := windowArray.MaxIndex()
        if(amount < 1) {
            return
        }


        Loop, %amount%
        {
            window := windowArray[A_Index]

            isRunning := window.isRunning

            hwnd := window.hwnd
           
            if(isRunning = 1) {
                hwnd := -1
            }           
            title := window.title
            processName := window.processName
            desktop := window.desktop
            filePath := window.filePath
            ;M sgBox % "Adding window " . title . " " . processName . " " . filePath
            this.addNew(hwnd, title, processName, desktop, filePath, isRunning)
            
        }
    }

    removeNonExistent() {
        WinGet, windowlist, list, , , Program Manager 
        
        i := 1
        while i <= this.windows.MaxIndex()
        {
            window := this.windows[i]
            window_id := window.getHwnd()
            if(!this.windowWithIdExists(windowlist, window_id)) {
                this.windows.RemoveAt(i)
                i := i - 1
            } else {
                i := i + 1
            }
        }    
    }
    
    windowWithIdExists(windowlist, window_id) {
        Loop, %windowlist% 
        {               
            StringTrimRight, this_id, id%a_index%, 0 
            if(this_id = window_id) {
                return true
            }

        }    
        return false      
    }

    addIfNotExists(hwnd, title, processName, desktop, filePath := "", isRunning := 1) {
        ;M sgBox, the title is %title% --> do it!
        
        w := new WindowObject(hwnd, title, processName, desktop, filePath, isRunning)
        if(this.hasWindow(w, 1)) {            
            return false
        }
        this.add(w)
        return true         
    }

    addNew(hwnd, title, processName, desktop, filePath := "", isRunning := 1) {
        ;M sgBox, the title is %title% --> do it!
        
        w := new WindowObject(hwnd, title, processName, desktop, filePath, isRunning)

        this.windows.push(w)
        return true         
    }

    hasWindow(window, checkTitle := 0) {
        amount := this.windows.MaxIndex()
        ;MsgBox, % "Checking if window exists " . amount
        Loop, %amount%
        {
            currentWindow := this.windows[A_Index]
            if(currentWindow.isRunning() = 0) {
                continue
            }
            if(currentWindow.getProcessName() != window.getProcessName()) {
                continue
            }
            if(currentWindow.getHwnd() != window.getHwnd()) {
                continue
            }

            if(checkTitle = 1) {
                if(currentWindow.getTitle() != window.getTitle()) {
                    continue
                }
            }
            return true
        }
        return false
    }

    removeWindow(window) {
        amount := this.windows.MaxIndex()
        Loop, %amount%
        {
            currentWindow := this.windows[A_Index]
            if(currentWindow.getProcessName() != window.getProcessName()) {
                continue
            }
            if(currentWindow.getHwnd() != window.getHwnd()) {
                continue
            }
            this.windows.RemoveAt(A_Index)
            return
        }
    }

    add(window) {
        ; there might be a window with the same hwnd but different title
        ; so we need to check if it exists first
        if(this.hasWindow(window)) {
            this.removeWindow(window)
        }
        this.windows.push(window)
        ;amount := this.windows.MaxIndex()
        ;M sgBox % "Added existing window " . amount 
    }

    addArray(newArray) {
        amount := newArray.MaxIndex()
        Loop, %amount%
        {
            window := newArray[A_Index]
            this.windows.Push(window)
        }
    }

    addUniqueArray(newArray) {
        amount := newArray.MaxIndex()
        Loop, %amount%
        {
            window := newArray[A_Index]
            filePath := window.getFilePath()
            if(!this.hasFilePath(filePath)) {
                this.windows.Push(window)
            } else {
                ;M sgBox % "Already has file path " . filePath
            }
        }
    }

    hasFilePath(filePath) {
        amount := this.windows.MaxIndex()
        Loop, %amount%
        {
            window := this.windows[A_Index]
            currentFilePath := window.getFilePath()
            if(currentFilePath = filePath) {
                return true
            }
        }
        return false
    }

    removeElementWithFilePath(filePath) {
        amount := this.windows.MaxIndex()
        Loop, %amount%
        {
            window := this.windows[A_Index]
            currentFilePath := window.getFilePath()
            if(currentFilePath = filePath) {
                this.windows.RemoveAt(A_Index)
                return
            }
        }
    }

    length() {
        return this.windows.MaxIndex() 
    }

    clear() {
        this.windows := Array()
        this.amount := 0
    }

    get(index) {
        return this.windows[index]
    }

    getArray() {
        return this.windows
    }


    sort() {
        global

        ;newWindows := A.sortBy(this.windows, Func("fn_sortByIsRunning"))
        newWindows := A.sortBy(this.windows, Func("fn_sortByName"))
        this.windows := newWindows
        /*
        amount := newWindows.length()
        this.clear()
       
        Loop, %amount% 
        { 
            window := newWindows[A_Index]
            title := window.getTitle()
            
            if(title = "") {
                continue
            }
            
            this.add(window)

        }
        */
    }

    getActiveWindow(lastActiveWindowId) {
        amount := this.windows.MaxIndex()
        ;M sgBox, % "Amount of windows " . amount
        Loop, %amount%
        {
            window := this.windows[A_Index]
            ;M sgBox, % "Checking window " . window.getHwnd() . " " . lastActiveWindowId
            if(window.getHwnd() = lastActiveWindowId) {
                ;title := window.getTitle()
                ;MsgBox, found window %title%
                return window
            }
        }
        ;M sgBox, no window found
        return 0
    }

    storeMousePosForActiveWindow(lastActiveWindowId) {
        window := this.getActiveWindow(lastActiveWindowId)
        ;title := window.getTitle()

        ;ToolTip, >%title%<
        window.saveMousePos()
    }

    filterByDesktop(currentDesktop) {
        amount := this.windows.MaxIndex()
        newWindows := Array()
        Loop amount
        {
            
            window := this.windows[A_Index]
            desktop := elementsArray[A_Index][3]
            if(window.getDesktop() != currentDesktop) 
            {
                continue
            }
            newWindows.Push(window)
        }

        this.windows := newWindows
     }


     
}

