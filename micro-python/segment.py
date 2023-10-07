from machine import Pin, Timer, ADC 
# led = Pin(1, Pin.OUT)

pin_numbers = (0,1,2,3,4,5,6,7)
pins = [Pin(pn, Pin.OUT) for pn in pin_numbers]
adc = ADC(Pin(26))

for pin in pins:
    pin.value(0)

ctr = 0

def show_cells(cells):
    global pins
    for pin in pins:
        pin.value(0)
    for cell in cells:
        pin = pins[cell]
        pin.value(1)

def show_digit(dig):
    digits = [
        [1,2,3,5,6,7],#0
        [3,7],#1
        [1,2,4,5,7],#2
        [2,3,4,5,7],#3
        [3,4,6,7],#4
        [2,3,4,5,6],#5
        [1,2,3,4,5,6],#6
        [3,5,7],#7
        [1,2,3,4,5,6,7],#8
        [2,3,4,5,6,7],#9
        ]
    cells = digits[dig % 10]
    show_cells(cells)

def read_analog(timer):
    duty = adc.read_u16()
    scale = int((duty / 65025) * 10)
    show_digit(scale)

t = Timer()
t.init(freq=2.5, mode=Timer.PERIODIC, callback=read_analog)