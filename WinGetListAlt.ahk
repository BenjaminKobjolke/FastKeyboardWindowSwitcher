WinGetListAlt(params*) ;                       v0.21 by SKAN for ah2 on D51K/D51O @ autohotkey.com/r?t=99157
{
    Static S_OK      :=  0

    Local  hModule   :=  DllCall("Kernel32\LoadLibrary", "str","dwmapi", "ptr")
        ,  List      :=  []
        ,  ExMin     :=  0
        ,  Style     :=  0
        ,  ExStyle   :=  0
        ,  hwnd      :=  0

    While params.Length > 4
          ExMin := params.pop()

    For ,  hwnd in WinGetList(params*)
       If  IsVisible(hwnd)
      and  StyledRight(hwnd)
      and  NotMinimized(hwnd)
      and  IsAltTabWindow(hwnd)
           List.Push(hwnd)

    DllCall("Kernel32\FreeLibrary", "ptr",hModule)
    Return List

    ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

                    IsVisible(hwnd, Cloaked:=0)
                    {
                        If S_OK  =   0
                           S_OK  :=  DllCall( "dwmapi\DwmGetWindowAttribute", "ptr",hwnd
                                            , "int",   14                   ; DWMWA_CLOAKED
                                            , "uintp", &Cloaked
                                            , "int",   4                    ; sizeof uint
                                            )

                        Style  :=  WinGetStyle(hwnd)
                        Return (Style & 0x10000000) and not Cloaked         ; WS_VISIBLE
                    }


                    StyledRight(hwnd)   
                    {
                        ExStyle := WinGetExStyle(hwnd)

                        Return (ExStyle & 0x8000000) ? False                ; WS_EX_NOACTIVATE
                             : (ExStyle & 0x40000)   ? True                 ; WS_EX_APPWINDOW
                             : (ExStyle & 0x80)      ? False                ; WS_EX_TOOLWINDOW
                                                     : True
                    }


                    NotMinimized(hwnd)
                    {
                        Return ExMin ? WinGetMinMax(hwnd) != -1 : True
                    }


                    IsAltTabWindow(Hwnd)
                    {

                        ExStyle  :=  WinGetExStyle(hwnd)
                        If  ( ExStyle  &  0x40000 )                         ; WS_EX_APPWINDOW
                              Return True

                        While  hwnd := DllCall("GetParent", "ptr",hwnd, "ptr")
                        {
                           If IsVisible(Hwnd)
                              Return False

                           ExStyle  :=  WinGetExStyle(hwnd)

                                If ( ExStyle  &  0x80 )                     ; WS_EX_TOOLWINDOW
                           and not ( ExStyle  &  0x40000 )                  ; WS_EX_APPWINDOW
                               Return False
                        }

                        Return !Hwnd
                    }
} ; ________________________________________________________________________________________________________
