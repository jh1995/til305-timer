' TIL305 display driver
' by Paolo Cravero
' multiplexing by column
'

$regfile = "attiny4313.dat"                                 ' specify the used micro
'$regfile = "attiny2313.dat"                                 ' specify the used micro
$crystal = 4000000                                          ' used crystal frequency
$hwstack = 32                                               ' default use 32 for the hardware stack
$swstack = 10                                               ' default use 10 for the SW stack
$framesize = 40                                             ' default use 40 for the frame space


' input pin in place of interrupt
Config Pinb.1 = Input
Fakeint Alias Pinb.1
Dim In_state As Byte
Dim In_state_old As Byte
In_state = 0
In_state_old = 0

Declare Sub Fetchsymbol(index As Byte)

'Declare Sub Allrowsoff

' I/O registers. 1 is for output, 0 is for input.
' Columns are used as virtual inputs, so that the pull-up resistor can be used as current limiting for each pixel.
' Rows are controlled with output pins.
Config Pinb.6 = Output
Config Pinb.5 = Output
Config Pinb.4 = Output
Config Pinb.3 = Output
Config Pinb.2 = Output
Config Pinb.0 = Output
'Config Portb = &B00001110                                   ' xxxC_RRRC

' *** specific for tiny2313
Config Pina.1 = Output
Config Pina.0 = Output


Config Portd = &B00111110                                   ' xxCR_RRCx



' ************* CONFIG OPTIONS ************



Const Pixelpersistance = 1                                  ' pixel ON time in milliseconds
'Dim Pixelpersistance As Byte
'Pixelpersistance = 1

'$prog &HFF , &H64 , &HDF , &HFF                             ' generated. Take care that the chip supports all fuse bytes.

' ************* VARIABLES ***************

Dim Seconds As Word                                         ' seconds elapsed since start
Seconds = 0
Dim Minutes As Word
Minutes = 0
Dim Hours As Word
Hours = 0

'Const Messagelength = 5
'Dim Message As String * Messagelength
'Dim Messagearray(messagelength) As Byte At Message Overlay
'Message = "00000"                                           ' remember, use upper case only!!
'Dim Messagearray(messagelength) As Byte At Minutes Overlay
Dim Messagearray(5) As Word


Dim Tmp1 As Byte
Dim Tmp2 As Byte
Dim Tmp3 As Byte
Dim Tmp4 As Byte
Dim Tmp5 As Byte

Dim Tmp1horiz As Byte
Dim Tmp2horiz As Byte
Dim Tmp3horiz As Byte
Dim Tmp4horiz As Byte
Dim Tmp5horiz As Byte

'Dim Abc As Byte
Dim Abc2 As Byte
'Abc = 0

Dim Tmpdiv As Word


' ************* ALIAS DEFINITIONS ***********

' Define column aliases
Col5 Alias Portb.2
Col4 Alias Portb.6
Col3 Alias Portd.5
Col2 Alias Portd.1
Col1 Alias Porta.1

' Define row aliases
Row7 Alias Portb.5
Row6 Alias Porta.0
Row5 Alias Portb.4
Row4 Alias Portb.3
Row3 Alias Portd.2
Row2 Alias Portd.3
Row1 Alias Portd.4

' define dot
Dot Alias Portb.0

' ************* END ALIAS DEFINITIONS ***********

'Call Allrowsoff
' switch off every row pulling outputs to 1
Set Row1
Set Row2
Set Row3
Set Row4
Set Row5
Set Row6
Set Row7


' pull high all columns
Reset Col1
Reset Col2
Reset Col3
Reset Col4
Reset Col5
Reset Dot

' ## RULES ##
' ## first bit of each byte is always 0
' ## 0 will turn OFF the pixel
' ## 1 will turn ON  the pixel



Do

   In_state = Fakeint
   If In_state <> In_state_old Then
      If In_state = 1 Then
         Seconds = Seconds + 1

         If Seconds = 120 Then
            Minutes = Minutes + 1

            If Minutes = 60 Then
               Hours = Hours + 1
               Minutes = 0
            End If
            Seconds = 0
         End If

         If Hours > 0 Then
            Tmpdiv = Hours                                  ' once 1h has passed, show hours
         Else
            Tmpdiv = Minutes                                ' switch to displaying only minutes if 1 hour has passed
         End If


         Messagearray(5) = Tmpdiv Mod 10                    ' LSD
         Tmpdiv = Tmpdiv \ 10
         Messagearray(4) = Tmpdiv Mod 10
         Tmpdiv = Tmpdiv \ 10
'         Messagearray(3) = Tmpdiv Mod 10
         Tmpdiv = Tmpdiv \ 10
'         Messagearray(2) = Tmpdiv Mod 10
'         Messagearray(1) = Tmpdiv \ 10                      ' MSD
         Abc2 = Messagearray(4) * 5
         Abc2 = Abc2 + 50                                   ' get the LHS pattern

         If Hours > 0 And Hours < 10 Then
               Abc2 = 150                                   ' showing symbol 'h' in LHS pattern
         End If

         Tmp5 = 0
         Tmp4 = 0
         Tmp3 = 0
         Tmp2 = 0
         Tmp1 = 0
         Call Fetchsymbol(abc2)

         Abc2 = Messagearray(5) * 5
         Abc2 = Abc2 + 100                                  ' get the RHS pattern

         If Minutes < 10 And Hours = 0 Then                 ' blank out the LHS pattern
            Tmp5 = 0
            Tmp4 = 0
            Tmp3 = 0
            Tmp2 = 0
            Tmp1 = 0
         End If

         Call Fetchsymbol(abc2)

      End If

      In_state_old = In_state

   End If



' ***** TODO **** CONTROL THIS MODE WITH A TILT SENSOR ******* TODO ********

'      Abc = 0

      ' do the line-by-line scanning. This is preferred over col-by-col because it preserves
      ' pixel intensity since each column powers at most one pixel at a time

            Col1 = Tmp1.6
            Col2 = Tmp2.6
            Col3 = Tmp3.6
            Col4 = Tmp4.6
            Col5 = Tmp5.6
         ' power up row pulling it low
         Reset Row1
            Waitms Pixelpersistance
         Set Row1                                           ' power down row pulling it up

            Col1 = Tmp1.5
            Col2 = Tmp2.5
            Col3 = Tmp3.5
            Col4 = Tmp4.5
            Col5 = Tmp5.5
         Reset Row2
            Waitms Pixelpersistance
         Set Row2                                           ' power down row pulling it up


            Col1 = Tmp1.4
            Col2 = Tmp2.4
            Col3 = Tmp3.4
            Col4 = Tmp4.4
            Col5 = Tmp5.4
         Reset Row3
            Waitms Pixelpersistance
         Set Row3                                           ' power down row pulling it up


            Col1 = Tmp1.3
            Col2 = Tmp2.3
            Col3 = Tmp3.3
            Col4 = Tmp4.3
            Col5 = Tmp5.3
         Reset Row4
            Waitms Pixelpersistance
         Set Row4                                           ' power down row pulling it up


            Col1 = Tmp1.2
            Col2 = Tmp2.2
            Col3 = Tmp3.2
            Col4 = Tmp4.2
            Col5 = Tmp5.2
         Reset Row5
            Waitms Pixelpersistance
         Set Row5                                           ' power down row pulling it up


            Col1 = Tmp1.1
            Col2 = Tmp2.1
            Col3 = Tmp3.1
            Col4 = Tmp4.1
            Col5 = Tmp5.1
         Reset Row6
            Waitms Pixelpersistance
         Set Row6                                           ' power down row pulling it up


            Col1 = Tmp1.0
            Col2 = Tmp2.0
            Col3 = Tmp3.0
            Col4 = Tmp4.0
            Col5 = Tmp5.0
         Reset Row7
            Waitms Pixelpersistance
         Set Row7                                           ' power down row pulling it up

'         Abc = Abc + 1


'      Call Allrowsoff
 '     Waitms 50

' ****************************** END TEST **********************************

'   Next

'   Call Allrowsoff
'   Waitms 100


Loop


' switch off all row pulling them high
'Sub Allrowsoff
'   ' switch off every row pulling outputs to 1
'   Set Row1
'   Set Row2
'   Set Row3
'   Set Row4
'   Set Row5
'   Set Row6
'   Set Row7
'End Sub

Sub Fetchsymbol(index As Byte)

   Readeeprom Tmp5horiz , index
   Tmp5 = Tmp5 Or Tmp5horiz
   index = index + 1
   Readeeprom Tmp4horiz , index
   Tmp4 = Tmp4 Or Tmp4horiz
   index = index + 1
   Readeeprom Tmp3horiz , index
   Tmp3 = Tmp3 Or Tmp3horiz
   index = index + 1
   Readeeprom Tmp2horiz , index
   Tmp2 = Tmp2 Or Tmp2horiz
   index = index + 1
   Readeeprom Tmp1horiz , index
   Tmp1 = Tmp1 Or Tmp1horiz

End Sub


' SYMBOLS MOVED TO EEPROM!! :-O :-D
Edata:
$eeprom
' 0
 Data &B00111110
 Data &B01000001
 Data &B01000001
 Data &B01000001
 Data &B00111110
' 1
 Data &B00000000
 Data &B00000001
 Data &B01111111
 Data &B00100001
 Data &B00000000
' 2
 Data &B00100001
 Data &B01010001
 Data &B01001001
 Data &B01000101
 Data &B00100011
' 3
 Data &B00110110
 Data &B01001001
 Data &B01001001
 Data &B01000001
 Data &B00100010
' 4
 Data &B00000100
 Data &B01111111
 Data &B00100100
 Data &B00010100
 Data &B00001100
' 5
 Data &B01000110
 Data &B01001001
 Data &B01001001
 Data &B01001001
 Data &B01110010
' 6
 Data &B00000110
 Data &B01001001
 Data &B01001001
 Data &B00101001
 Data &B00011110
' 7
 Data &B01100000
 Data &B01010000
 Data &B01001000
 Data &B01000111
 Data &B01100000
' 8
 Data &B00110110
 Data &B01001001
 Data &B01001001
 Data &B01001001
 Data &B00110110
' 9 ASCII 57_10
 Data &B00111100
 Data &B01001010
 Data &B01001001
 Data &B01001001
 Data &B00110000
' 0 left
 Data &B00100000
 Data &B01010000
 Data &B01010000
 Data &B01010000
 Data &B00100000
' 1 left
 Data &B00100000
 Data &B01100000
 Data &B00100000
 Data &B00100000
 Data &B01110000
' 2 left
 Data &B00100000
 Data &B01010000
 Data &B00010000
 Data &B00100000
 Data &B01110000
' 3 left
 Data &B01100000
 Data &B00010000
 Data &B00100000
 Data &B00010000
 Data &B01100000
' 4 left
 Data &B01000000
 Data &B01000000
 Data &B01010000
 Data &B01110000
 Data &B00010000
' 5 left
 Data &B01110000
 Data &B01000000
 Data &B01100000
 Data &B00010000
 Data &B01100000
' 6 left
 Data &B00100000
 Data &B01000000
 Data &B01100000
 Data &B01010000
 Data &B00100000
' 7 left
 Data &B01110000
 Data &B00010000
 Data &B00010000
 Data &B00010000
 Data &B00010000
' 8 left
 Data &B01110000
 Data &B01010000
 Data &B01110000
 Data &B01010000
 Data &B01110000
' 9 left
 Data &B00100000
 Data &B01010000
 Data &B00110000
 Data &B00010000
 Data &B00100000
' 0 right
 Data &B00000010
 Data &B00000101
 Data &B00000101
 Data &B00000101
 Data &B00000010
' 1 right
 Data &B00000010
 Data &B00000110
 Data &B00000010
 Data &B00000010
 Data &B00000111
' 2 right
 Data &B00000010
 Data &B00000101
 Data &B00000001
 Data &B00000010
 Data &B00000111
' 3 right
 Data &B00000110
 Data &B00000001
 Data &B00000010
 Data &B00000001
 Data &B00000110
' 4 right
 Data &B00000100
 Data &B00000100
 Data &B00000101
 Data &B00000111
 Data &B00000001
' 5 right
 Data &B00000111
 Data &B00000100
 Data &B00000110
 Data &B00000001
 Data &B00000110
' 6 right
 Data &B00000010
 Data &B00000100
 Data &B00000110
 Data &B00000101
 Data &B00000010
' 7 right
 Data &B00000111
 Data &B00000001
 Data &B00000001
 Data &B00000001
 Data &B00000001
' 8 right
 Data &B00000111
 Data &B00000101
 Data &B00000111
 Data &B00000101
 Data &B00000111
' 9 right
 Data &B00000010
 Data &B00000101
 Data &B00000011
 Data &B00000001
 Data &B00000010
 ' h left
 Data &B01000000
 Data &B01000000
 Data &B01100000
 Data &B01010000
 Data &B01010000
' o
' Data &B00001110
' Data &B00010001
' Data &B00010001
' Data &B00010001
' Data &B00001110

' P
 Data &B00110000
 Data &B01001000
 Data &B01001000
 Data &B01001000
 Data &B01111111
' Q
 Data &B00011101
 Data &B00100010
 Data &B01000101
 Data &B00100010
 Data &B00011100
' R
 Data &B00110001
 Data &B01001010
 Data &B01001100
 Data &B01001000
 Data &B01111111
' S
 Data &B00100110
 Data &B01001001
 Data &B01001001
 Data &B01001001
 Data &B00110010
' T
 Data &B01100000
 Data &B01000000
 Data &B01111111
 Data &B01000000
 Data &B01100000
' U
 Data &B01111110
 Data &B00000001
 Data &B00000001
 Data &B00000001
 Data &B01111110
' V
 Data &B01111000
 Data &B00000110
 Data &B00000001
 Data &B00000110
 Data &B01111000
' W
 Data &B01111110
 Data &B00000001
 Data &B00001110
 Data &B00000001
 Data &B01111110
' X
 Data &B01100011
 Data &B00010100
 Data &B00001000
 Data &B00010100
 Data &B01100011
' Y
 Data &B01100000
 Data &B00010000
 Data &B00001111
 Data &B00010000
 Data &B01100000
' Z
 Data &B01100001
 Data &B01010001
 Data &B01001001
 Data &B01000101
 Data &B01000011
' blank
 Data &B00000000
 Data &B00000000
 Data &B00000000
 Data &B00000000
 Data &B00000000

$data
'End