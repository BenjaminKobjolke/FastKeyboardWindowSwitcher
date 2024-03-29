class WindowObject {

    hwnd := 0
    title :=
    processName :=
    desktop :=
    filePath := 
    className :=
    isRunning := 1

    isMouseSaved := 0
    mouseX := 0
    mouseY := 0

    ; the index will increase everyt time the window is in focus
    runIndex := 0

    __New(hwnd, title, processName, desktop, filePath = "", isRunning = 1, className = "") {
        ;MsgBox, %hwnd% %title% %processName% %desktop% %filePath%
        this.title := title
        
        this.isRunning := isRunning
        
        this.hwnd := hwnd
        this.className := className
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

    getClassName() {
        return this.className
    }
    getRunIndexAndTitle() {
        titleString := this.getTitle()
        StringReplace, titleString, titleString, +, , All
        StringReplace, titleString, titleString, -, , All                        
        runIndex := this.getRunIndex()
        runIndexPadded := Format("{:05}", runIndex)
        sortableString := runIndexPadded . "_" . titleString            
        return sortableString
    }

    setRunIndex(value) {
        this.runIndex := value
    }

    getRunIndex() {
        return this.runIndex
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

    setTitle(value) {
        this.title := value
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

    activate(moveMouse = 1, restoreMousePos = 1) {
        title := this.getTitle()
        window_id := this.getHwnd()

        isRunning := this.getIsRunning()
        ;ToolTip, 1 %title% 2 %isHistory% 3 %window_id% 4 %isRunning%

        if(isRunning = 0) {
            filePath := this.getFilePath()
            Run, %filePath%
            return true
        }

        if(window_id = 0) {
            return false
        }    

        GetKeyState, state, Alt
        if (state = "D") {
            guiActive := 0
            WinClose, ahk_id %window_id%
            return false
        } 
        WinActivate, ahk_id %window_id% 

        if(moveMouse = 1) {
            if(restoreMousePos = 1) {
                this.restoreMousePos()
            } else {
                winTools := new WinTools()
                winTools.moveMouseToCurrentWindowCenter() 
            }
        }
        ;ToolTip, is active now %title%
        return true
    }

    restoreMousePos() {
        mouseSaved := this.isMouseSaved
        mouseX := this.mouseX
        mouseY := this.mouseY
        title := this.getTitle()
        id := this.getHwnd()
        if(mouseSaved = 0) {
            ;M sgBox, %title% %id% no mouse saved!!!! %mouseX% %mouseY%
            winTools := new WinTools()
            winTools.moveMouseToCurrentWindowCenter()
            return
        }
        MouseMove, this.mouseX, this.mouseY
    }

    saveMousePos() {
        CoordMode, Mouse, Screen 
        
        win_id := this.getHwnd()

        ; Get the active window's position and size
        WinGetPos, win_x, win_y, win_width, win_height, ahk_id %win_id%
        MouseGetPos, mouse_x, mouse_y
        if (mouse_x >= win_x) and (mouse_x <= win_x + win_width) and (mouse_y >= win_y) and (mouse_y <= win_y + win_height)
        {
            ;CoordMode, Mouse, Window
            MouseGetPos, mouse_x, mouse_y
            
            this.mouseX := mouse_x
            this.mouseY := mouse_y

            this.isMouseSaved := 1
            ;M sgBox, %title% mouse IS in the bounds of the window %win_x% %win_y% %win_width% %win_height% %mouse_x% %mouse_y%
        }
        else
        {
            ;title := this.getTitle()
            ;M sgBox, %title% mouse is not in the bounds of the window %win_x% %win_y% %win_width% %win_height% %mouse_x% %mouse_y%
            this.isMouseSaved := 0
        }   
    }

    isActiveWindow() {
        if(this.isRunning() = 0) {  
            ;M sgBox, 1
            return false
        }

        window_id := this.getHwnd()
        if(window_id = -1) {
            ;M sgBox, 2
            return false
        }
        WinGet, activeWindowdId,, A
        ;M sgBox, 1 %window_id% 2 %activeWindowdId%
        if(window_id = activeWindowdId) {
            return true
        }
        ;M sgBox, 4
        return false
    }
}   