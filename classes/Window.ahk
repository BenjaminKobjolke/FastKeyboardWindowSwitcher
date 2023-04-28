class Window {

    hwnd := 0
    title :=
        processName :=
        desktop :=
        __New(hdnw, title, processName, desktop) {
        this.hwnd := hdnw
        this.title := title
        this.processName := processName
        this.desktop := desktop
    }


}