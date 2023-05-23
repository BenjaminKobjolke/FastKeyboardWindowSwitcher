class Commands {

    commands := Array()

    __New(commands) {
        this.commands := Commands
        
    }

    getArray() {
        amount := this.commands.length()
        return this.commands
    }

    getCommand(index) {
        commandObject := this.commands[index]
        return commandObject
    }
}