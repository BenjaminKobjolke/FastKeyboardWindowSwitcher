fn_sortByFunc(o)
{
	return o.title
}

class Windows {

    windows := Array()

    __New() {
    }


    addNew(hdnw, title, processName, desktop) {
        w := new Window(hdnw, title, processName, desktop)
        this.windows.push(w)

    }

    add(window) {
        this.windows.push(window)
        ;amount := this.windows.MaxIndex()
        ;MsgBox % "Added existing window " . amount 
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



    sort() {
        global
        newWindows := A.sortBy(this.windows, Func("fn_sortByFunc"))
        this.windows := newWindows
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

