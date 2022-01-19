// OpenCV Processing Library
// Documentation: http://atduskgreg.github.io/opencv-processing/reference/

import gab.opencv.*;
OpenCV opencv;
PImage result;

// Set Presets (for Primary ROI)
int selectX = 0;    int selectY = 0;    // X/Y Coords of Primary ROI        
int selectW = 300;  int selectH = 100;  // Width/Height of Primary ROI  
int blur = 1;       int thresh = 1;     // Settings for OpenCV 

// Initializes Image Processing
void initImageProcessing(){
  opencv = new OpenCV(this, video);  // Create OpenCV Object
  result = createImage(320, 160, RGB);
}

// Shows the Primary Region of Interest
void showROI(){
  noFill(); stroke(0, 255, 0);
  rect(selectX, selectY, selectW, selectH);
}

// Performs the Image Processing
void processImage(){
  opencv.loadImage(video);                            // Load the Video
  opencv.setROI(selectX, selectY, selectW, selectH);  // Set ROI
  opencv.blur(blur);                                  // Blur the Image
  opencv.threshold(thresh);                           // Threshold the Image
  result = opencv.getOutput();                        // Process the Image
  image(result, 0, 0);                                // Show the Processed Image
  
  // Insert Additional Image Processing Code Below
  
  
  // Insert Additional OttoBot Control Code Below
  
   
}

// Given a ROI, draws a box, and returns % of pixels that are black
float pixelCount(int id, int x, int y, int w, int h, int hue){
  colorMode(HSB, 255); noFill(); stroke(hue, 255, 255);
  text(id, x, y);  rect(x, y, w, h);
  colorMode(RGB, 255);
  float blackPix = 0;  float whitePix = 0;
  PImage t = createImage(w, h, RGB);
  t.copy(result, x, y, w, h, 0, 0, w, h);  t.loadPixels();
  for (int i = 0; i < w * h; i++){int b = (int)brightness(t.pixels[i]); if(b < 128){blackPix++;} else{whitePix++;}}
  float bwRatio = blackPix / (w * h);  
  return bwRatio;
}
