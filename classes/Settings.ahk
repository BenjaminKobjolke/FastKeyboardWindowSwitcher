; MyClass.ahk
class Settings {


    DEFAULT_GUI_SPACING_HORIZONTAL := 20
    DEFAULT_GUI_SPACING_VERTICAL := 20

    SETTINGS_FILE := "settings.ini"

    _autoactivateifonlyone := -1

    __New() {
    }

    defaultGuiSpacingHorizontal() {
        return this.DEFAULT_GUI_SPACING_HORIZONTAL
    }

    defaultGuiSpacingVertical() {
        return this.DEFAULT_GUI_SPACING_VERTICAL        
    }

    moveMouse() {
        return this.getBool("mouse", "move", 1)
    }

    saveMousePos() {
        return this.getBool("mouse", "saveposperwindow", 1)
    }

    guiSpacingHorizontal() {        
        return this.getString("gui", "spacingHorizontal", this.DEFAULT_GUI_SPACING_HORIZONTAL)
    }

    guiSpacingVertical() {
        return this.getString("gui", "spacingVertical", this.DEFAULT_GUI_SPACING_VERTICAL)
    }

    guiShowHeader() {
        return this.getBool("gui", "showHeader", 1)
    }

    guiTextColor() {
        return this.getString("gui", "textColor", "0x33C4FF")
    }

    guiTextColorHistory() {
        return this.getString("gui", "textColorHistory", "0x999999")
    }

    guiTextColorTrayIcons() {
        return this.getString("trayicons", "textColor", "0x33C4FF")
    }

    showTrayIcons() {
        return this.getBool("trayicons", "show", 1)
    }

    guiTextColorInput() {
        return this.getString("gui", "textColorInput", "0xFFFFFF")
    }

    guiTextSize() {
        return this.getString("gui", "textSize", "20")
    }

    guiTransparency() {
        return this.getString("gui", "transparency", "180")
    }

    hotkeyReload() {
        return this.getBool("debug", "hotkeyReload", 0)
    }

    useVirtualDesktops() {
        return this.getBool("virtualdesktops", "active", 0)
    }

    virtualDesktopOtherTextColor() {        
        return this.getString("virtualdesktops", "otherDesktopsTextColor", "0x006868")
    }

    virtualDesktopAllDesktopsTextColor() {
        return this.getString("virtualdesktops", "allDesktopsTextColor", "0x333333")
    }
    
    virtualDesktopOtherDesktopsTextColor() {
        return this.getString("virtualdesktops", "otherDesktopsTextColor", "0x006868")        
    }

    useDelToEndTask() {
        return this.getBool("settings", "usedeltoendtask", 0)
    }

    showInput() {
        return this.getBool("settings", "showinput", 0)
    }

    searchMinLength() {
        return this.getString("settings", "searchminlength", 1)
    }

    alwaysStartWithTasks() {
        return this.getBool("trayicons", "alwaystartwithtasks", 1)
    }

    setAutoActivateIfOnlyOne(value) {
        this._autoactivateifonlyone := value
    }

    autoActivateIfOnlyOne() {
        if this._autoactivateifonlyone = -1 {
            this._autoactivateifonlyone := this.getBool("settings", "autoactivateifonlyone", 1)
        }
        return this._autoactivateifonlyone
    }

    showProcessName() {
        return this.getBool("settings", "showProcessName", 1)
    }

    tabComplete() {
        return this.getBool("settings", "tabComplete", 1)
    }

    /*
    *   set this to yes to enable digit shortcuts when there are ten or 
    *   less items in the list 
    */
    digitShortcuts() {
        return this.getBool("settings", "digitshortcuts", 1)
    }

    getBool(section, key, defaultValue) {
        value := this.getString(section, key, defaultValue)
        if (value == "1") {
            return true
        }
        return false
    }

    getString(section, key, defaultValue) {
        IniRead, value, % this.SETTINGS_FILE, %section%, %key% , %defaultValue%
        return value
    }
}
