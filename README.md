# IR-duellers

Toy guns for a western-styel duelling game. The pair of guns have an ir-LED and sensor each and can thus determine who shot first. When a gun "dies" it is not able to shoot anymore and has to be reset from a button to be functional again. 

## Harware

###Electronics

The heart of the gun is an ATtiny85 with a TSOP17xx IR-receiver and an IR-LED. Additionally a status LED and a piezo-buzzer were added for feedback. 

A transistor was also added to amplify the IR-LEDs signal, but in hindsight this was unneccessary. The pizeo-buzzer could however have really done with some amplification, because it can be a bit too quiet sometimes. 

While operational everything runs on two AA batteries, but the design is 5v tolerant for programming purposes.  

The pcb also provides some breakout points for easier programming (VCC, GND, Reset, RX, TX). Unfotunately the internal clockspeed on the ATtiny85 seems to vary so much from chip to chip that it makes programming the chip over serial a hit or miss. Some chips seemed to work perfectly, while others just would not work.

###case

The case was designed in FreeCAD and 3d printed using PLA-plastic. Most parts are attached with screws but the trigger button is just slid in and held in place with friction. Note that the attachment of the top cover is not perfect and I have therefore used tape for fastening it as it's easier. 

Here are the dimensions and models for the off the shelf physical components:

------

## Software



###programming

Originally the program was written in Arduino language. While this worked perfectly fine. A more sophisticated version was written in assembly.

###Flashing the chips

The original plan was to program the chip over serial with the Arduino bootloader. This however did not appear to be reliable so programming the chips over SPI on a breadboard was used instead.  

The chips were programmed with and Arduino Uno (Arduino as ISP). The hex file was generated with Atmel Studio and progamming was done with Avrdude ovet command line. 

´´´
avrdude -arguments and shit
´´´