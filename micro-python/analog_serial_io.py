from machine import Pin,ADC,UART,Timer
import time

# Output: Built in LED on "LED" (or, Pin 25)
led = Pin("LED")
# Input: Analog input on Pin 26
adc = ADC(Pin(26))

# Connectivity: Set up UART 1 (pins 4 and 5) at 9600 baud, 8n1
uart = UART(1, baudrate=9600, tx=Pin(4), rx=Pin(5))
uart.init(bits=8, parity=None, stop=1)

# Read data from the uart (run from a timer)
def read_serial(timer):
    if uart.any(): 
        data = uart.read()
        lines = [line.strip() for line in data.decode().split('\n')]
        for line in lines:
            if(len(line) > 0):
                print("analog input is " + str(adc.read_u16()))

# Create a periodic timer at 25Hz, calling read_serial
t = Timer()
t.init(freq=25, mode=Timer.PERIODIC, callback=read_serial)
