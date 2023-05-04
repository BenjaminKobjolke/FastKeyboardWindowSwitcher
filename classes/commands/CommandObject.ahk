class CommandObject {

    id := ""
    title := ""

    __New(id, title) {
        this.id := id
        this.title := title 
    }

    getTitle() {
        return this.title
    }
        
}