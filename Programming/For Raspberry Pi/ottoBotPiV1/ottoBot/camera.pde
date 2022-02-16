// Camera
// Functions and Variables to Control the Onboard USB Camera Module

import gohai.glvideo.*;
GLCapture cam;

import javax.imageio.*;
import java.awt.image.*; 
import java.net.*;
import java.io.*;

// These Variables Need to Be Set by User Remotely
String IPAddress = "";
int whichCamera = 2;
int whichConfig = 5;

int clientPort = 9100;             // This is the port we are sending to
DatagramSocket ds;                 // This is our object that sends UDP out

PImage tinyVid;                    // This is a small image to store a downsized video
int tinyVidW = 320;                // Width of the small image
int tinyVidH = 160;                // Height of the small image

// Initializes Video Stream
void initVideo(){
  // Setting up the DatagramSocket, requires try/catch
  try {ds = new DatagramSocket();} 
  catch (SocketException e) {e.printStackTrace();}
  
  // Initialize Camera
  String[] devices = GLCapture.list();  println(devices);
  String[] configs = GLCapture.configs(devices[whichCamera]);
  
  printArray(configs);
  cam = new GLCapture(this, devices[whichCamera], configs[whichConfig]);
  //cam = new GLCapture(this, devices[whichCamera], 320, 240);
  cam.start();
  
  // Initialize Small Video
  tinyVid = createImage(tinyVidW, tinyVidH, RGB);
}

// Get Video Frame from Processing/Sending
void getVideo(){
  if (cam.available()) {
    cam.read();
    tinyVid.copy(cam, 0, 0, cam.width, cam.height, 0, 0, tinyVidW, tinyVidH);
    //broadcast(cam);
    broadcast(tinyVid);
  }
  
  //image(cam,0,0);
  image(tinyVid,0,0);
}

// Function to broadcast a PImage over UDP
// Special thanks to: http://ubaa.net/shared/processing/udp/
// (This example doesn't use the library, but you can!)
void broadcast(PImage img) {

  // We need a buffered image to do the JPG encoding
  BufferedImage bimg = new BufferedImage( img.width,img.height, BufferedImage.TYPE_INT_RGB );

  // Transfer pixels from localFrame to the BufferedImage
  img.loadPixels();
  bimg.setRGB( 0, 0, img.width, img.height, img.pixels, 0, img.width);

  // Need these output streams to get image as bytes for UDP communication
  ByteArrayOutputStream baStream  = new ByteArrayOutputStream();
  BufferedOutputStream bos    = new BufferedOutputStream(baStream);

  // Turn the BufferedImage into a JPG and put it in the BufferedOutputStream
  // Requires try/catch
  try {
    ImageIO.write(bimg, "jpg", bos);
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  // Get the byte array, which we will send out via UDP!
  byte[] packet = baStream.toByteArray();

  // Send JPEG data as a datagram
  //println("Sending datagram with " + packet.length + " bytes");
  try {
    ds.send(new DatagramPacket(packet,packet.length, InetAddress.getByName(IPAddress),clientPort));
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}
