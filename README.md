# Count-up timer with TIL305 and ATtiny2313 (4313)

# History
After building few clocks and thinking of many more, I wanted to do something slightly different. The "new" idea came one evening while cooking, when I realised I never remember at what time the pasta (food) will be ready. "Was it 20:14 or 20:20?"

I am usually too lazy/busy to set a countdown timer every time and since my short-term memory is not willing to cooperate I chose to try a count-up timer: a simple device that shows elapsed time.

For this task I wanted to use TIL305 5x7 dot-matrix LED displays made in 1970's. Two challenges:

    they need an appropriate driver
    they are very current hungry

I had already solved the driver problem by reproducing someone else's idea to adapt an ATtiny2313 microcontroller. You need one ATtiny every TIL305. Cost-wise in 2018 this solution is probably cheaper than using obsolete unobtanium driver chips.
Since I want my timer to be battery powered, at about 38 mA per 2313&305 pair, I cannot use too many displays. Four digits is the minimum useful IMO ("mm:ss" and "hh:mm" for longer runs), but another idea comes to the rescue: use smaller font, 5x3 dots vs 5x7 and show two digits on each TIL305. This approach has another advantage: limit the required wiring (I won't be doing a PCB!).
How about the timebase? ATtiny's will not synchronise, they will receive both the same external timebase signal and rely on their internal clock to run the code. I could have had one master driver generating the pulse for others, but I am not sure on the internal RC calibration and on longer runs the difference vs 1 pps could be unacceptable. So there will be a 32.768 kHz oscillator and divider with CD4060 chip (because it accepts a wide range of supply voltage).

# What you need
* Electronics skills
* TIL305 dot matrix display
* ATtiny4313 (or ATtiny2313 for fewer features)
* an AVR programmer
* CD4060, 32.768 kHz XTAL, appropriate resistors
* 100nF poly and 47uF 16V electrolytic capacitors
* a 3.5 to 4.2V power source: 18650 Li-xx cell is ideal!
* a charge/discharge module for the battery

# The code
The code has been writted with the free edition of BASCOM-AVR. This language allows simpler control of low-level features vs Arduino and, I think, the resulting code is faster.
There are two files, one for the Most Significant Digits (MSD) and another for the Least Significant Digits (LSD). You can easily guess which one goes to which AVR.

# The quirks
You need to set fuse settings in a way that the chips run on their internal 4 MHz clock without :8 divider, no clock output. Don't run this circuit with a voltage above 4.2V otherwise either the precious TIL305 display burns out or the ATtiny hangs because it is outputting too much current through its pins. Besides, the technology inside TIL305 is quite inefficient and it produces heat (= wasted energy).
Both microcontrollers operate off the same sync source: they independently count the elapsed time. One is set to display seconds and then minutes (LSD), the other minutes and then hours (MSD). With proper DC decoupling capacitors I've seen they stay in sync even after 15 hours. Feel free to modify the code so that the clock is propagated as in a chain. It is possible since there are three free I/O pins (but don't use the RESET pin!).
