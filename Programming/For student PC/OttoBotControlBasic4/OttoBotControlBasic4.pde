// OttoBot Control
// Zane Cochran & Colt Doster
// This software provides network communications and control to the OttoBot software to facilitate the function of a small-self driving vehicle.
// Last Update: 10 OCT 2021

// MUST HAVE OPENCV Library and Video Library Installed in order to run this sketch

//************** CONFIGURABLE SETTINGS ******************//
// Networking
String ottoBotIP = "monaco";    // IP Address of OttoBot
String ottoControlIP = "10.40.4.48";// IP Address of Control Computer (this computer)

// Mechanical
int enable = 1;              // (0 - 1)       Disable (0) or Enable (1) the OttoBot from Functioning.
int speed = 0;               // (-100 - 100)  Set Speed of OttoBot. Full Reverse (-100), Stop (0), Full Forward (100)
int angle = 0;               // (-100 - 100)  Set Steering Angle of OttoBot. Full Left (-100), Straight (0), Full Right (100)

// Video
int mode = 0;                          // 0 - Remote OttoBot (Most Common) || 1 - Using Local Webcam || 2 - Use Pre-Recorded Data
int whichCamera = 0;                   // Configure Which Camera Port on Local PC to Connect
String movieName = "SampleTrail.mov";  // Name of Pre-Recorded Test Footage (Located in /data folder in sketch)
boolean toggleVideo = true;            // Toggle Between Raw Video and Processed Video
boolean toggleAuto = false;            // Toggle Between Manual and Autonomous Driving

//************** DON'T TOUCH CODE BELOW THIS LINE ******************//

void setup() {
  size(320, 160, P2D);
  if(mode == 0){initNetwork();}    // Initialize Network for Remote Mode
  initVideo();                     // Initialize Video
  initImageProcessing();           // Initialize Image Processing
}

void draw() {
  background(0);  
  updateVideo();                           // Get Updated Frame of Video

  if(toggleVideo){image(video, 0, 0);}    // Show Unprocessed Video
  else{processImage();}                   // Show OpenCV Processed Video
  
  showROI();                              // Show Region of Interest
  
  if(mode == 0){checkConfig();}            // Check for Updated Configuration and Send to Server
}
