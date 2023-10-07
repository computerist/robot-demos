from machine import Pin, Timer

# Outputs: The built-in LED ("LED" or, Pin 25), and
# the external LED on Pin 15
led = Pin("LED", Pin.OUT)
ext_led = Pin(15, Pin.OUT)

# Turn the external LED on, so the two start in different states
ext_led.toggle()

# a blink function, to be called once every timer tick;
# toggles both LEDs
def blink(timer):
    led.toggle()
    ext_led.toggle()

# Create a periodic timer at 2.5Hz, calling blink
t = Timer()
t.init(freq=2.5, mode=Timer.PERIODIC, callback=blink)