; MyClass.ahk
class TrayControl {

    trayArray := Array()

    __New() {
    }

    list() {
        this.trayArray := TrayIcon_GetInfo()
        return this.trayArray
    }

    length() {
        return this.trayArray.MaxIndex()
    }

    leftClick(windId) {
        this.click(windId, "L", false)
    }    

    doubleClick(windId) {
        this.click(windId, "L", true)
    }       

    rightClick(windId) {
        this.click(windId, "R", false)
    }

    get(hwnd) {
        maxIndex := this.trayArray.MaxIndex()
        targetIndex := 0

        Loop, %maxIndex%
        {
            currentHwnd := this.trayArray[A_Index].hwnd   
        
            if(hwnd = currentHwnd) {
                targetIndex := A_Index
                break
            }
        } 
        
        element := this.trayArray[targetIndex]
        element.index := targetIndex
        return element
    }

    click(windId, command = "L", doubleClick = false) {        
        element := this.get(windId)

        ;M sgBox, %index% %name% %msgid% %hwnd% uid %uid%
        
        TrayIcon_Click(element.msgid, element.uid, element.hwnd, command, doubleClick)
    }

    ; not working
    remove(hwnd) {

        element := this.get(hwnd)
        ;MsgBox, % element.index
        ;TrayIcon_Hide(element.index, "Shell_TrayWnd", False)
    }

}
