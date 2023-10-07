from machine import Pin
import time

from machine import Pin, Timer
led = Pin("LED", Pin.OUT)
ext_led = Pin(15, Pin.OUT)
button = Pin(14, Pin.IN, Pin.PULL_DOWN)

timer = Timer()

ext_led.toggle()

def blink(timer):
    led.toggle()
    if button.value():
        ext_led.toggle()

timer.init(freq=2.5, mode=Timer.PERIODIC, callback=blink)
