from machine import Pin,UART,PWM
import time

def move_motor(speed, forward_pin, reverse_pin):
    speed = int((speed / 255) * 65025)
    print(speed)
    if 0 <= speed:
        forward_pin.duty_u16(abs(speed))
        reverse_pin.duty_u16(0)
    else:
        forward_pin.duty_u16(0)
        reverse_pin.duty_u16(abs(speed))

LF = PWM(Pin(1))
LR = PWM(Pin(0))
RF = PWM(Pin(2))
RR = PWM(Pin(3))

uart = UART(1, baudrate=9600, tx=Pin(4), rx=Pin(5))
uart.init(bits=8, parity=None, stop=1)

move_motor(0, LF, LR)
move_motor(0, RF, RR)

while True:
    if uart.any(): 
        data = uart.read()
        lines = [line.strip() for line in data.decode().split('\n')]
        for line in lines:
            if(len(line) > 0):
                xs, ys = line.split(',')
                steering, throttle = int(xs) - 255, int(ys) - 255
                print(steering, throttle)
                ceiling = 255 - abs(steering)
                print("ceiling is "+str(ceiling))
                # if the throttle magnitude is greater than the ceiling, clip the throttle
                if abs(throttle) > ceiling:
                    if 0 > throttle:
                        throttle = -1 * ceiling
                    else:
                        throttle = ceiling
                        
                left = throttle - steering
                right = throttle + steering
                move_motor(left, LF, LR)
                move_motor(right, RF, RR)