un_sortByName(o)
{
    title := o.title
    StringReplace, title, title, +, , All
    StringReplace, title, title, -, , All
    ;M sgBox, % "Sorting by title " . title
	return title
}

fn_sortByRunIndex(o)
{
    index := o.getRunIndex()
    return index
}

fn_sortByNameAndRunIndex(o)
{
    return o.getRunIndexAndTitle()
}

fn_sortByIsRunning(o)
{
	return o.isRunning =  0
}


class WindowManager {

    debug := 0
    debugPrefix := 
    windows := Array()

    __New() {
        this.windows := Array()
    }

    enableDebug(prefix) {
        this.debug := 1
        this.debugPrefix := prefix
    }

    increaseRunIndexForActiveWindow(activeWindowId, newIndex) {
        amount := this.windows.MaxIndex()
        if(amount < 1) {
            return
        }
        Loop, %amount%
        {
            window := this.windows[A_Index]
            title := window.getTitle()
            windowId := window.getHwnd()
            if(windowId = activeWindowId) {
                title := window.getTitle()
                window.setRunIndex(newIndex)
                this.sort()                
                return 1
            }
        }
        return 0
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

    getProcessName(ahkID) {
        WinGet, procname, ProcessName, ahk_id %ahkID% 

        stringgetpos, pos, procname, . 
        if ErrorLevel <> 1 
        { 
            stringleft, procname, procname, %pos% 
        } 

        return procname
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
        DetectHiddenWindows, On
        WinGet, List, List, ahk_class AutoHotkey
        scripts := ""
        Loop % List {
            ahkID := List%A_Index%
            if(ahkID = window_id) {
                return true
            }
        }        
        DetectHiddenWindows, Off
        return false      
    }

    addIfNotExists(hwnd, title, processName, desktop, filePath := "", isRunning := 1, className := "") {
        if(className = "tooltips_class32") {
            return false
        }
        ;M sgBox, the title is %title% --> do it!
        
        ; replace pipe (|) characters in the window title, 
        ; because Gui Add uses it for separating listbox items 
        StringReplace, title, title, |, -, all             

        w := new WindowObject(hwnd, title, processName, desktop, filePath, isRunning, className)
        if(this.hasWindow(w, 1)) {            
            return false
        }
        this.add(w)
        return true         
    }

    addNew(hwnd, title, processName, desktop, filePath := "", isRunning := 1, className := "") {
        ;M sgBox, the title is %title% --> do it!
        
        ; replace pipe (|) characters in the window title, 
        ; because Gui Add uses it for separating listbox items 
        StringReplace, title, title, |, -, all             

        w := new WindowObject(hwnd, title, processName, desktop, filePath, isRunning)
        this.add(w)
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
        title := window.getTitle()
        length := StrLen(title)
        if(length < 1) {
            return
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
            this.add(window)
        }
    }

    addUniqueArrayAtTheBottom(newArray) {
        amount := newArray.MaxIndex()
        Loop, %amount%
        {
            window := newArray[A_Index]
            filePath := window.getFilePath()
            if(!this.hasFilePath(filePath)) {
                ;this.windows.Push(window)
                this.Array_Unshift(this.windows, window)
            } else {
                ;M sgBox % "Already has file path " . filePath
            }
        }
    }

    /*
    * Add at the beginning of the array
    */
    Array_Unshift(ByRef arr, value)
    {
        ; Calculate new length
        newLength := ObjMaxIndex(arr) + 1

        ; Shift all elements one position to the right
        Loop, %newLength%
        {
            index := newLength - A_Index + 1
            arr[index] := arr[index - 1]
        }

        ; Insert the new value at the beginning
        arr[1] := value
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
        debug := this.debug
        debugPrefix := this.debugPrefix
        debugFileName = logs/log_%debugPrefix%.txt
        if(debug = 1) {
            FileDelete, %debugFileName%
        }
        ;newWindows := this.windows
        newWindows := A.sortBy(this.windows, Func("fn_sortByNameAndRunIndex"))
        this.clear()
        
        amount := newWindows.MaxIndex()
        Loop, %amount%
        {
            targetIndex := amount - A_Index + 1
            window := newWindows[targetIndex]
            runIndex := window.getRunIndex()
            window.setRunIndex(runIndex)
            this.add(window)
        }
        
        Loop, %amount%
        {
            window := this.windows[A_Index]
            sortableTitle := window.getRunIndexAndTitle()
            hdnw := window.getHwnd()
            if(debug = 1) {
                FileAppend, >%hdnw%< - %sortableTitle%`n, %debugFileName%
            }
        }
    }

    getWindowWithId(windowId) {
        amount := this.windows.MaxIndex()
        Loop, %amount%
        {
            window := this.windows[A_Index]
            if(window.getHwnd() = windowId) {
                return window
            }
        }
        return 0
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

