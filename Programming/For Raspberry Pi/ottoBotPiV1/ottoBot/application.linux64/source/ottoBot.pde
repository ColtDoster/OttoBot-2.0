// OttoBot - Bot
// Zane Cochran & Colt Doster
// This software provides network communications and control to the OttoBot - Control software to facilitate the function of a small self-driving vehicle.
// Last Update: 20 SEP 2021

// Configurable Settings
// These settings can be adjusted by the OttoBot - Control Software

  // Mechanical
  int enable = 1;              // (0 - 1)       Disable (0) or Enable (1) the OttoBot from Functioning.
  int speed = 0;               // (-100 - 100)  Set Speed of OttoBot. Full Reverse (-100), Stop (0), Full Forward (100)
  int angle = 0;               // (-100 - 100)  Set Steering Angle of OttoBot. Full Left (-100), Straight (0), Full Right (100)

  boolean startVideo = false;  // Begin Video 
// Master Settings
// These settings cannot be adjusted by the OttoBot - Control Software and should be adjusted with extreme care

void setup(){
  size(320, 160, P2D);         // Set Canvas Size

  initServer();                // Initializes the Server
  initController();            // Initializes the I2C Controller
  initSteering();              // Intitialize Steering Servo
  initMotors();                // Intitialize Drive Motors
  initVideo();                 // Initializes the USB Camera Video Stream
}

void draw(){
  background(0);               // Clear the Background
  if(startVideo){getVideo();}   // Communicate with Video Protocols
  getServer();                 // Communicate with Server Protocols
}
