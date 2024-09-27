# A bluetooth / HTTP controlled, skid-steer robot. In MicroPython.
# Mark Goodwin. 2013 - 2024
from machine import Pin, UART, PWM, Timer
import time

import HttpServer

import json

led = Pin("LED", Pin.OUT, value=0)

# Bluetooth: Set up UART 1, GPIO pins 4 and 5 (physical pins 6 and 7)
uart = UART(1, baudrate=9600, tx=Pin(4), rx=Pin(5)) # 9600 baud
uart.init(bits=8, parity=None, stop=1) # 8n1

# Move the motor attached to the specified PWM Pins
def move_motor(speed, forward_pin, reverse_pin):
    speed = int((speed / 255) * 65025)
    if 0 <= speed:
        forward_pin.duty_u16(abs(speed))
        reverse_pin.duty_u16(0)
    else:
        forward_pin.duty_u16(0)
        reverse_pin.duty_u16(abs(speed))

# Outputs: Motor outputs; PWM on pins 0,1,2,3
LF = PWM(Pin(0)) # GPIO pin 0, physical pin 1
LR = PWM(Pin(1)) # GPIO pin 1, physical pin 2
RF = PWM(Pin(2)) # GPIO pin 2, physical pin 4
RR = PWM(Pin(3)) # GPIO pin 3, physical pin 5

button = Pin(14, Pin.IN, Pin.PULL_DOWN)

# Set the frequencies for all PWM pins
[pin.freq(1000) for pin in (LF,LR,RF,RR)]

last_received = 0

def motors_off():
    move_motor(0, LF, LR)
    move_motor(0, RF, RR)

# Ensure the motors are *off* to start with (this is
# really helpful to ensure misbehaving controllers are
# easily corrected
motors_off()

def move_from_coords(xs, ys):
    global last_received
    last_received = time.ticks_ms()
    # Turn these into 'steering' and 'throttle' integer values, centred
    # at 0
    steering, throttle = xs - 255, ys - 255
    # Clip the steering ceiling if the control is hard forward
    ceiling = 255 - abs(steering)
    # if the throttle magnitude is greater than the ceiling, clip the throttle
    if abs(throttle) > ceiling:
        if 0 > throttle:
            throttle = -1 * ceiling
        else:
            throttle = ceiling
    # Calculate the left and right components for motor movement
    left = throttle - steering
    right = throttle + steering
    # Move the motors!
    move_motor(left, LF, LR)
    move_motor(right, RF, RR)

# Read data from the uart (run from a timer)
def read_serial(timer):
    if uart.any(): 
        data = uart.read()
        lines = [line.strip() for line in data.decode().split('\n')]
        for line in lines:
            if(len(line) > 0):
                # for _reasons_, the phone app sends X,Y coordinates, 1 per line
                # as UTF-8 strings. X and Y are values, nominally between 0 and 512
                xs, ys = line.split(',')
                move_from_coords(int(xs), int(ys))

# Create a periodic timer at 25Hz, calling read_serial
serialTimer = Timer()
serialTimer.init(freq=25, mode=Timer.PERIODIC, callback=read_serial)

# Stop the motors if there's no current data
def stop_idle(timer):
    global last_received
    if time.ticks_diff(time.ticks_ms(), last_received) > 500:
        #last_received = time.ticks_ms()
        motors_off()
    else:
        print("wait")
                
# Create a periodic timer at 4Hz, calling stop_idle
stopTimer = Timer()
stopTimer.init(freq=2, mode=Timer.PERIODIC, callback=stop_idle)

#TODO: add a timer to turn the motors off on idle

html = open('template.html','r').read()
    
def move(request, response):
    if len(request.body) > 0:
        move_obj = json.loads(request.body)
        xs, ys = move_obj['xs'], move_obj['ys']
        print('xs = %d, ys = %d' % (xs, ys))
        move_from_coords(xs, ys)
    response.write('')
    
def stop(request, response):
    motors_off()
    response.write('')

def make_document_handler(path, mimetype='text/html'):
    document = open(path,'r').read()
    def serve_document(request, response):
        response.set_header("Content-type", mimetype)
        response.write(document)
    return serve_document
        

HttpServer.add_route('/stop', stop)
HttpServer.add_route('/move', move)
HttpServer.add_route('/', make_document_handler('robot.html'))
HttpServer.add_route('/robot.js', make_document_handler('robot.js', mimetype="text/javascript"))
HttpServer.add_route('/robot.css', make_document_handler('robot.css', mimetype="text/css"))
HttpServer.run_server()