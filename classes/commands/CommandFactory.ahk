class CommandFactory {

    commands := Array()

    __New() {

        this.commands := Array()

        command := new CommandObject("updatewindowarray", "Update Window Array", "updatewindowarray")
        this.commands.push(command)
        ;command1 := new CommandObject("help", "Show help screen", "showHelp")
        ;this.commands.push(command1)
        command := new CommandObject("reload", "Reload", "reload")
        this.commands.push(command)
        ;command3 := new CommandObject("quit" "Quit", "quit")
        ;this.commands.push(command3)
        command := new CommandObject("quit", "Quit", "quit")
        this.commands.push(command)
    }

    create() {
        wManager := new WindowManager()
        ; loop this.commands
        amount := this.commands.length()
        ;M sgBox, %amount%
        Loop, %amount%
        {
            command := this.commands[A_Index]
            cID := command.getID()
            cTitle := command.getTitle()
            ;MsgBox, %cID% %cTitle%
            wManager.addNew(cID, cTitle, 0, 0)
        }

        return wManager
    }    
        
}