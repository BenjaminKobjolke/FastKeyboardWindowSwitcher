class FilterLists {

    doNotTriggerList := []
    amountOfDoNotTrigger := 0

    __New() {

        ; List of windows for which the hotkey will not trigger
        FileRead, list_do_not_trigger, list_do_not_trigger.txt
        doNotTriggerList := []   
        this.amountOfDoNotTrigger := 0
        if list_do_not_trigger <> 
        { 
            index := 0
            loop, parse, list_do_not_trigger, `n, `r
            { 
                ;d := [] 
                ;shortcuts%a_index% = %A_LoopField% 
                
                ;M sgBox, %A_LoopField% 
                StringSplit, cArray, A_LoopField, |                 
                val = %cArray1%
                ;M sgBox, %val%                                
                this.doNotTriggerList[index] := val                
                index := index + 1             
            } 

            this.amountOfDoNotTrigger := index 
        }         
    }

    shouldNotTriggerForWindow(title) {
        index = 0
        amount := this.amountOfDoNotTrigger
        Loop, %amount%
        {
            cVal := % this.doNotTriggerList[index]                    
            if InStr(title, cVal)
            {
                ;M sgBox, %title% contains %cVal%
                return true
            }    
            index := index + 1
        }                   

        return false
    }
}