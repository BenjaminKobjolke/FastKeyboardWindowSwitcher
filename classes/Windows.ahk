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


class Windows {

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

    addNew(hwnd, title, processName, desktop, filePath := "", isRunning := 1) {
        ;M sgBox, the title is %title% --> do it!
        
        w := new WindowObject(hwnd, title, processName, desktop, filePath, isRunning)
        this.windows.push(w)
        title := w.getTitle()
        ;M sgBox, the title is %title%         
    }

    add(window) {
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

