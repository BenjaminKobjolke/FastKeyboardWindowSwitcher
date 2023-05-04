class Commands {

    commands := Array()

    __New() {
        commandFactory := new CommandFactory()
        this.commands := commandFactory.create()
    }

    getArray() {
        return this.commands
    }
}