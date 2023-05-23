class CommandHandler {
    
    __New(windowObject) {
        commandID := windowObject.getHwnd()
        ;M sgBox, %commandID%
        switch commandID {
            case "reload":
                Reload
            case "quit":
                ExitApp
        }
    }
}