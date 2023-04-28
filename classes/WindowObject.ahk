class WindowObject {

    hwnd := 0
    title :=
    processName :=
    desktop :=
    filePath := 

    isRUnning := 1

    __New(hwnd, title, processName, desktop, filePath = "", isRunning = 1) {
        ;MsgBox, %hwnd% %title% %processName% %desktop% %filePath%
        
        this.title := title

        this.isRunning := isRunning
        
        this.hwnd := hwnd
        if(hwnd = -1) {
            ;M sgBox, creating new Window %hwnd%
            ;M sgBox, %filePath%
            this.setIsRunning(0)
        }

        this.processName := processName
        this.desktop := desktop
        if(filePath != "") {
            this.filePath := filePath
        } else {
            this.filePath := this.getFilePath()
        }

    }

    getIsRunning() {
        if(this.isRunning = 1) {
           return true
        }
        return false
    }
    
    setIsRunning(value) {
        ;title := this.title
        ;MsgBox, setIsRunning %value% for title %title%
        this.isRunning := value
        if(value = 0) {
            this.hwnd := -1
        }
    }
    
    getHwnd() {
        return this.hwnd
    }

    getTitle() {
        return this.title
    }

    getProcessName() {
        return this.processName
    }

    getDesktop() {
        return this.desktop
    }

    getFilePath() {
        if(this.filePath != "") {
            ;MsgBox, % "Returning 1" . this.filePath
            return this.filePath
        }
        WinGet, value, ProcessPath, % "ahk_id " . this.hwnd
        this.filePath := value
        ;MsgBox, % "Returning 2" . this.filePath . " " . this.hwnd
        return this.filePath
        ;MsgBox % "Added new window " . OutputVar
     }

}