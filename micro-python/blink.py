from machine import Pin, Timer
led = Pin("LED", Pin.OUT)
ext_led = Pin(0, Pin.OUT)

timer = Timer()

ext_led.toggle()

def blink(timer):
    led.toggle()
    ext_led.toggle()

timer.init(freq=2.5, mode=Timer.PERIODIC, callback=blink)