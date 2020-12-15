# IR-duellers

Toy guns for a western-styel duelling game. The pair of guns have an ir-LED and sensor each and can thus determine who shot first. When a gun "dies" it is not able to shoot anymore and has to be reset from a button to be functional again. 

A few images of the finished product: https://imgur.com/a/vaQRZun

## Electronics

The heart of the gun is an ATtiny85 with a TSOP312xx (TSOP31236 in this implementation) IR-receiver and an IR-LED. Additionally a status LED and a piezo-buzzer were added for feedback. 

A transistor was also added to amplify the IR-LEDs signal, but in hindsight this was unneccessary. The pizeo-buzzer could however have really done with some amplification, because it can be a bit too quiet sometimes. 

While operational everything runs on two AA batteries, but the design is 5v tolerant for programming purposes.  

The pcb also provides some breakout points for easier programming (VCC, GND, Reset, RX, TX). Unfotunately the internal clockspeed on the ATtiny85 seems to vary so much from chip to chip that it makes programming the chip over serial a hit or miss. Some chips seemed to work perfectly, while others just would not work. Therefore the chips were programmed with SPI. 

## Case

The case was designed in FreeCAD and 3d printed using PLA-plastic. Most parts are attached with screws but the trigger button is just slid in and held in place with friction. Note that the attachment of the top cover is not perfect and I have therefore used tape for fastening it as it's easier. 

The reset switch is a generic closing switch with a 7mm shaft. The trigger is a PS507MA, which is also a closing switch with a 16mm shaft.

------

## Software

Originally the program was written in the Arduino language. While this worked, an improved version was written in assembler. I have also included the version written in the Arduino language here, but be aware that it tends to be somewhat unreliable. Both versions here are programmed to work with 36kHz IR signal. 

Note that this project requires the ATTinyCore by SpenceKonde to be installed from the Arduino boards manager.

## Flashing the chips

The original plan was to program the chip over serial with the Arduino bootloader. This however did not appear to be reliable so programming the chips over SPI on a breadboard was used instead. An Arduino Uno (Arduino as ISP) was used as the programmer.

For the version written in assembler the hex file was generated with Atmel Studio and progamming was done with Avrdude. Avrdude comes with Arduino IDE and can be accessed over command line.

```bash

avrdude -CC:"\Path\to\Arduino\hardware\tools\avr/etc/avrdude.conf" -v -pattiny85 -carduino -PCOM3 -b19200 -U lfuse:w:0xE2:m -U hfuse:w:0xDF:m -U efuse:w:0xFF:m -Uflash:w:lightguns_asm_v1.hex:i

```

I have here the Arduino running Arduino as ISP on COM3. Also note the fuse settings. These set the internal oscillator at 8MHz and make sure that the chip can be programmed again using SPI.