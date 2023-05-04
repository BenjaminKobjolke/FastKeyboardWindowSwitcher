class CommandFactory {

    commands := Array()

    __New() {
    }

    create() {
     
        this.commands := Array()

        command := new CommandObject("help", "Show help screen")
        this.commands.push(command)

        return this.commands
    }    
        
}