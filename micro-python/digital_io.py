from machine import Pin, Timer
import time

# Outputs: The built-in LED ("LED" or, Pin 25), and
# the external LED on Pin 15
led = Pin("LED", Pin.OUT)
ext_led = Pin(15, Pin.OUT)
# Inputs: The button on Pin 14
button = Pin(14, Pin.IN, Pin.PULL_DOWN)

# Turn the external LED on, so the two start in different states
ext_led.toggle()

# a blink function, to be called once every timer tick;
# toggles the built-in LED and, if the button is pressed,
# the external LED too
def blink(timer):
    led.toggle()
    if button.value():
        ext_led.toggle()

# Create a periodic timer at 2.5Hz, calling blink
t = Timer()
t.init(freq=2.5, mode=Timer.PERIODIC, callback=blink)
