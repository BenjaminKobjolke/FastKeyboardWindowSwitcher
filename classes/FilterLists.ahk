class FilterLists {

    doNotTriggerList := []
    amountOfDoNotTrigger := 0

    __New(filename) {

        ; List of windows for which the hotkey will not trigger
        FileRead, list_do_not_trigger, %filename%
        doNotTriggerList := []   
        this.amountOfDoNotTrigger := 0
        if list_do_not_trigger <> 
        { 
            index := 0
			Loop, Parse, list_do_not_trigger, `n, `r
			{
				StringSplit, cArray, A_LoopField, |  ; Split the line into parts separated by |

				Loop, % cArray0  ; cArray0 contains the number of elements in cArray
				{
					val := cArray%A_Index%  ; Get each element
					;M sgBox, %val%
					this.doNotTriggerList[index] := val
					index := index + 1
				}
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