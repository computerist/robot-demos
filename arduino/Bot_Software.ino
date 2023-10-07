#include <SoftwareSerial.h>

SoftwareSerial bt(10, 11); // RX, TX

int LF = 3;
int LR = 5;
int RF = 9;
int RR = 6;


char buf[20];
int buf_len = 0;

void setup()  
{
  // Open serial communications and wait for port to open:
  Serial.begin(57600);
  
  // set the data rate for the SoftwareSerial port
  bt.begin(9600);
  
  pinMode(LF, OUTPUT);
  pinMode(LR, OUTPUT);
  pinMode(RF, OUTPUT);
  pinMode(RR, OUTPUT);
}

void loop() // run over and over
{ 
  if (bt.available()) {
    char ch = bt.read();
    if(ch != -1) {
      if(buf_len < 19) {
        buf[buf_len ++] = ch;
        if('\n' == ch) {
          buf[buf_len] = '\0';
          decodeLine(String(buf));
          buf_len = 0;
        }
      } else {
        // We've overfilled the buffer. Invalidate the line and start again
        buf_len = 0;
      }
    } 
  }
}

void decodeLine(String line) {
  int index = line.indexOf(',');
  String steeringString = line.substring(0,index);
  String throttleString = line.substring(index + 1, line.length());
  
  long steering = steeringString.toInt() - 255;
  long throttle = throttleString.toInt() - 255;
  
  long ceiling = 255 - abs(steering);
  
  // if the throttle magnitude is greater than the ceiling, clip the throttle
  if ( abs(throttle) > ceiling ) {
    throttle = 0 > throttle ? -1 * ceiling : ceiling;
  }
  
  long left = throttle - steering;
  long right = throttle + steering;

  Serial.println(throttle);
  Serial.println(steering);
  
  
  moveMotor(left, LF, LR);
  moveMotor(right, RF, RR);
} 

/**
  * Takes 'speed', a signed integer value (-255 to 255), and applies the maginitude of 'speed' to 'forwardPin' or 'reversePin' via analogWrite depending on its sign.
  */
void moveMotor(long speed, int forwardPin, int reversePin) {
    if ( 0 <= speed ) {
    analogWrite(reversePin, 0);
    analogWrite(forwardPin, abs(speed));
  } else {
    analogWrite(forwardPin, 0);
    analogWrite(reversePin, abs(speed));
  }
}

