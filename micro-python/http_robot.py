# A bluetooth / HTTP controlled, skid-steer robot. In MicroPython.
# Mark Goodwin. 2013 - 2024
from machine import Pin, PWM, Timer
import time

import http_server

import json

led = Pin("LED", Pin.OUT, value=0)

# Outputs: Motor outputs; PWM on pins 2,3,4,5
LF = PWM(Pin(2)) # GPIO pin 2, physical pin 4
LR = PWM(Pin(3)) # GPIO pin 3, physical pin 5
RF = PWM(Pin(4)) # GPIO pin 4, physical pin 6
RR = PWM(Pin(5)) # GPIO pin 5, physical pin 7

pin_map ={
    "LF" : LF,
    "LR" : LR,
    "RF" : RF,
    "RR" : RR,
    }

button = Pin(14, Pin.IN, Pin.PULL_DOWN)

# Set the frequencies for all PWM pins
[pin.freq(1000) for pin in (LF,LR,RF,RR)]

last_received = 0

# Move the motor attached to the specified PWM Pins
def move_motor(speed, forward_pin, reverse_pin):
    speed = int((speed / 255) * 65025)
    if 0 <= speed:
        forward_pin.duty_u16(abs(speed))
        reverse_pin.duty_u16(0)
    else:
        forward_pin.duty_u16(0)
        reverse_pin.duty_u16(abs(speed))

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
    left = throttle + steering
    right = throttle - steering
    # Move the motors!
    move_motor(left, LF, LR)
    move_motor(right, RF, RR)

# Stop the motors if there's no current data
def stop_idle(timer):
    global last_received
    if time.ticks_diff(time.ticks_ms(), last_received) > 500:
        #last_received = time.ticks_ms()
        motors_off()
                
# Create a periodic timer at 4Hz, calling stop_idle
stopTimer = Timer()
stopTimer.init(freq=2, mode=Timer.PERIODIC, callback=stop_idle)

def move(request, response):
    if len(request.body) > 0:
        move_obj = json.loads(request.body)
        xs, ys = move_obj['xs'], move_obj['ys']
        move_from_coords(xs, ys)
    response.write('')

def test(request, response):
    motors_off()
    global last_received
    last_received = time.ticks_ms()
    if len(request.body) > 0:
        move_obj = json.loads(request.body)
        pin_name, speed = move_obj['pin'], move_obj['speed']
        try:
            pin = pin_map[pin_name]
            pin.duty_u16(abs(speed))
        except:
            pass
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

http_server.add_route('/stop', stop)
http_server.add_route('/move', move)
http_server.add_route('/test', test)
http_server.add_route('/', make_document_handler('robot.html'))
http_server.add_route('/robot.js', make_document_handler('robot.js', mimetype="text/javascript"))
http_server.add_route('/robot.css', make_document_handler('robot.css', mimetype="text/css"))
http_server.run_server()