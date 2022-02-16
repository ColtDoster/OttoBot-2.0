// STEERING CONTROLS
int steering = 0;         // Steering Servo PWM Pin
int servoMinAngle = 10;   // Servo Min Angle
int servoMaxAngle = 170;  // Servo Max Angle
int whichDir = 0;         // -100 - 100% (Left to Right)

// Attach Steering Servo
void initSteering(){
  controller.attach(steering, 544, 2400);  // Attach Servo Motor w/ Pulse Range
  angle = 0;  setDir();                    // Initialize Direction to 0 (center)
  sendMsg("Steering OK");                  // Send Command that Steering is Running
}

// Set Servo Angle
void setDir(){
  float finalDir = map(angle, -100, 100, servoMinAngle, servoMaxAngle);  // Calculate Direction
  controller.write(steering, finalDir);                                  // Set Servo to Direction
  sendMsg("Steering set to " + angle);                                   // Send Command that Drive Motors are Running

}

// DRIVE MOTOR CONTROLS
int motorR = 1;      // Right Motor PWM Pin
int motorL = 2;      // Left Motor PWM Pin
int whichSpeed = 0;  // -100 - 100% (Reverse -- Stop -- Forward)

// Motor Pulses to Control Speed
int motorHighPulse = 10000;
int motorLowPulse = 2000;

// Set GPIO Pins for Motor Controller
int IN1 = 18;  int IN2 = 17;
int IN3 = 27;  int IN4 = 22;

// Initialize Motors
void initMotors() {
  controller.attach(motorR, motorLowPulse, motorHighPulse);  // Attach Right Drive Wheel
  controller.attach(motorL, motorLowPulse, motorHighPulse);  // Attach Left Drive Wheel
  
  // Set GPIO Pin Modes
  GPIO.pinMode(IN1, GPIO.OUTPUT);
  GPIO.pinMode(IN2, GPIO.OUTPUT);
  GPIO.pinMode(IN3, GPIO.OUTPUT);
  GPIO.pinMode(IN4, GPIO.OUTPUT);
  
  sendMsg("Drive Motors OK");                  // Send Command that Drive Motors are Running
}

// Set Motor Speed
void setSpeed(){
  // Stop Motors
  if(speed == 0){
    GPIO.digitalWrite(IN1, GPIO.LOW);  GPIO.digitalWrite(IN2, GPIO.LOW);
    GPIO.digitalWrite(IN3, GPIO.LOW);  GPIO.digitalWrite(IN4, GPIO.LOW);
  }
  else{
    // Reverse Motors
    if(speed < 0){
      GPIO.digitalWrite(IN1, GPIO.HIGH);  GPIO.digitalWrite(IN2, GPIO.LOW);
      GPIO.digitalWrite(IN3, GPIO.LOW);  GPIO.digitalWrite(IN4, GPIO.HIGH);
    }
    // Forward Motors
    if(speed > 0){
      GPIO.digitalWrite(IN1, GPIO.LOW);  GPIO.digitalWrite(IN2, GPIO.HIGH);
      GPIO.digitalWrite(IN3, GPIO.HIGH);  GPIO.digitalWrite(IN4, GPIO.LOW);
    }
    //Set Final Speed
    float finalSpeed = map(abs(speed), 0, 100, 0, 180);
    controller.write(motorL, finalSpeed); 
    controller.write(motorR, finalSpeed); 
  }
  sendMsg("Speed set to " + speed);                  // Send Command that Drive Motors are Running
}
