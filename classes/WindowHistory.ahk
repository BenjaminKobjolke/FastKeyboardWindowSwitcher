class WindowHistory {

    windows := 

    __New() {     
        this.setup()
    }

    setup() {
        this.windows := new WindowManager()    
        FileCreateDir, %A_ScriptDir%/history    
        FileRead, str, %A_ScriptDir%\history\history.json
        ;M sgBox, %str%
        ;obj := Jxon_Load( ByRef str  , object_base := "", array_base := ""  )
        obj := JSON.parse(str)
        
        this.windows.setWithArray(obj)
    }

    add(window) {

        filePath := window.getFilePath()
        if(this.windows.hasFilePath(filePath)) {
            this.windows.removeElementWithFilePath(filePath)
        } else {
            window.setIsRunning(0)
            title := window.getTitle()

            this.windows.add(window)
        }

        amount := this.windows.length()
        data := this.windows.getArray()

        ;str := Jxon_Dump( data, 4 )
        str := JSON.stringify(data)
        ;MsgBox, %str%
        FileDelete, %A_ScriptDir%\history\history.json
        FileAppend, %str%, %A_ScriptDir%\history\history.json
    
        this.setup()
    }

    hasWindow(window) {
        windowArray := this.windows.getArray()
        amount := windowArray.MaxIndex()
        ;MsgBox, % "Checking if window exists " . amount
        Loop, %amount%
        {
            currentWindow := windowArray[A_Index]
            
            if(currentWindow.getProcessName() != window.getProcessName()) {
                continue
            }
            if(currentWindow.getFilePath() != window.getFilePath()) {
                continue
            }
            return true
        }
        return false
    
    }

    getArray() {
        return this.windows.getArray()
    }

    sort() {    
        this.windows.sort()
    }

    list() {
        counter := 1
        for window in this.windows {
            window := this.windows.get(counter)
            title := window.title
            counter := counter + 1
        }
    }     
}

