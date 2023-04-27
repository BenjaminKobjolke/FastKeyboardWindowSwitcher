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

    click(windId, command = "L", doubleClick = false) {        
        maxIndex := this.trayArray.MaxIndex()
        targetIndex := 0
        Loop, %maxIndex%
        {
            hwnd := this.trayArray[A_Index].hwnd            
            if(windId = hwnd) {
                targetIndex := A_Index
                break
            }
        }        
        name := this.trayArray[targetIndex].process
        msgid := this.trayArray[targetIndex].msgid
        hwnd := this.trayArray[targetIndex].hwnd
        uid := this.trayArray[targetIndex].uid
        ;M sgBox, %index% %name% %msgid% %hwnd% uid %uid%
        
        TrayIcon_Click(msgid, uid, hwnd, command, doubleClick)
    }

}
