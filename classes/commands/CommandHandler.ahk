class CommandHandler {
    
    isDone := false
    subRoutine := ""

    __New(windowObject) {
        commandID := windowObject.getHwnd()
        ;M sgBox, %commandID%
        switch commandID {
            case "updatewindowarray":
                this.isDone := false
                this.subRoutine := "UpdateWindowArrays"
            case "reload":
                this.isDone := true
                Reload
            case "quit":
                this.isDone := true
                ExitApp
        }
    }

    getIsDone() {
        return this.isDone
    }

    getSubRoutine() {
        return this.subRoutine
    }
}