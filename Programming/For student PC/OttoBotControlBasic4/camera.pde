//************** DON'T TOUCH CODE BELOW THIS LINE ******************//
import processing.video.*;
import java.awt.image.*; 
import javax.imageio.*;
import java.net.*;
import java.io.*;

int port = 9100;                     // Port for UDP Video Stream
DatagramSocket ds;                   // Data Structure for Video
byte[] buffer = new byte[65536];     // Max Byte Buffer Size
PImage video;                        // Video Frame

Capture cam;                         // Local Web Camera
Movie movie;                         // Pre-Recorded Movie

// Initialize Video Image
void initVideo(){
  video = createImage(320, 160, RGB);  // Initialize Video Image

  // Remote Mode - Start Video Stream
  if(mode == 0){
    println("Connecting to Remote Camera...");
    try {ds = new DatagramSocket(port);} 
    catch (SocketException e) {e.printStackTrace();} 
  }
  // Local Cam Mode - Start Local Camera
  else if(mode == 1){
    println("Connecting to Local Camera...");
    video = createImage(640, 320, RGB);
    String[] cameras = Capture.list();
    printArray(cameras);
    cam = new Capture(this, cameras[whichCamera]);
    cam.start();
  }
  
  // Pre-Recorded Movie Mode - Start Movie
  else {
    println("Loading Pre-Recorded Footage...");
    movie = new Movie(this, movieName);
    movie.loop();
    movie.play(); 
  }
  
}

// Update Video
void updateVideo(){
  
  // Remote Mode - Fetch Video Stream
  if(mode == 0){
    DatagramPacket p = new DatagramPacket(buffer, buffer.length); 
    try {ds.receive(p);} 
    catch (IOException e) {e.printStackTrace();} 
    byte[] data = p.getData();
    
    ByteArrayInputStream bais = new ByteArrayInputStream( data );                 // Read incoming data into a ByteArrayInputStream
    video.loadPixels();                                                           // We need to unpack JPG and put it in the PImage video
    try {
      BufferedImage img = ImageIO.read(bais);                                     // Make a BufferedImage out of the incoming bytes
      img.getRGB(0, 0, video.width, video.height, video.pixels, 0, video.width);  // Put the pixels into the video PImage
    } 
    catch (Exception e) {e.printStackTrace();}
    
    video.updatePixels();                                                         // Update the PImage pixels
  }
  
  // Local Cam Mode - Get Image
  else if (mode == 1){
    if (cam.available() == true) {
      cam.read();
      video.copy(cam, 0, 0, cam.width, cam.height, 0, 0, video.width, video.height);
    }
  }
  
  // Pre-Recorded Movie Mode - Get Frame
  else{
    if (movie.available() == true) {
      movie.read(); 
      video.copy(movie, 0, 0, movie.width, movie.height, 0, 0, video.width, video.height);
    }
  }
}
