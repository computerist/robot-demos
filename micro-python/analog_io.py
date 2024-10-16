from machine import Pin, PWM, ADC, Timer

# Outputs - the external LED on Pin 15, the built in LED
# We'll set the PWM frequency to 1000Hz
pwm = PWM(Pin(15))
pwm.freq(1000)

led = Pin("LED", Pin.OUT)
# Inputs = the analog input (potentiometer?) on pin 26
adc = ADC(Pin(26))

# Set the brightness of the LED
def set_brightness(timer):
	duty = adc.read_u16()
	print(duty)
	pwm.duty_u16(duty)

# Create a periodic timer at 25Hz, calling set_brightness
t = Timer()
t.init(freq=2.5, mode=Timer.PERIODIC, callback=set_brightness)