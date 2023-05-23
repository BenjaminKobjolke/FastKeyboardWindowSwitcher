class CommandObject {

    _id := ""
    _title := ""
    _commandString := ""

    __New(id, title, commandString) {
        this._id := id
        this._title := title 
        ;MsgBox, my title!  %title%
        this._commandString := commandString
    }

    getID() {
        return this._id
    }

    getTitle() {
        title := this._title
        ;MsgBox, my title!  %title%   
        return title
    }

    getCommandString() {
        return this._commandString
    }
        
}