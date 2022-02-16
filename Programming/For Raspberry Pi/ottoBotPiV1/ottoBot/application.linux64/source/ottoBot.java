import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import gohai.glvideo.*; 
import javax.imageio.*; 
import java.awt.image.*; 
import java.net.*; 
import java.io.*; 
import processing.io.*; 
import processing.io.I2C; 
import processing.net.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ottoBot extends PApplet {

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

public void setup(){
           // Set Canvas Size

  initServer();                // Initializes the Server
  initController();            // Initializes the I2C Controller
  initSteering();              // Intitialize Steering Servo
  initMotors();                // Intitialize Drive Motors
  initVideo();                 // Initializes the USB Camera Video Stream
}

public void draw(){
  background(0);               // Clear the Background
  if(startVideo){getVideo();}   // Communicate with Video Protocols
  getServer();                 // Communicate with Server Protocols
}
// Camera
// Functions and Variables to Control the Onboard USB Camera Module


GLCapture cam;


 



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
public void initVideo(){
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
public void getVideo(){
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
public void broadcast(PImage img) {

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
      // Import I/O Library
    // Import I2C Library

PCA9685 controller;          // Create Controller Object for I2C control

// Initialize I2C Controller
public void initController(){
  controller = new PCA9685("i2c-1", 0x40);  // Connect to I2C Controller
  sendMsg("I2C Controller OK");             // Send Command that Drive Motors are Running
}

// PCA9685 is a 16-channel servo/PWM driver
// datasheet: https://cdn-shop.adafruit.com/datasheets/PCA9685.pdf
// code contributed by @OlivierLD

public class PCA9685 extends I2C {
  public final static int PCA9685_ADDRESS = 0x40;

  // registers used
  public final static int MODE1 = 0x00;
  public final static int PRESCALE = 0xFE;
  public final static int LED0_ON_L = 0x06;
  public final static int LED0_ON_H = 0x07;
  public final static int LED0_OFF_L = 0x08;
  public final static int LED0_OFF_H = 0x09;

  private int address;
  private int freq = 200;              // 200 Hz default frequency (after power-up)
  private boolean hasFreqSet = false;  // whether a different frequency has been set
  private int minPulses[] = new int[16];
  private int maxPulses[] = new int[16];


  public PCA9685(String dev) {
    this(dev, PCA9685_ADDRESS);
  }
  public PCA9685(String dev, int address) {
    super(dev);
    this.address = address;
    // reset device
    command(MODE1, (byte) 0x00);
  }


  public void attach(int channel) {
    // same as on Arduino
    attach(channel, 1, 2400);
  }

  public void attach(int channel, int minPulse, int maxPulse) {
    if (channel < 0 || 15 < channel) {
      throw new IllegalArgumentException("Channel must be between 0 and 15");
    }
    minPulses[channel] = minPulse;
    maxPulses[channel] = maxPulse;

    // set the PWM frequency to be the same as on Arduino
    if (!hasFreqSet) {
      frequency(50);
    }
  }

  public void write(int channel, float angle) {
    if (channel < 0 || 15 < channel) {
      throw new IllegalArgumentException("Channel must be between 0 and 15");
    }
    if (angle < 0 || 180 < angle) {
      throw new IllegalArgumentException("Angle must be between 0 and 180");
    }
    int us = (int)(minPulses[channel] + (angle/180.0f) * (maxPulses[channel]-minPulses[channel]));

    double pulseLength = 1000000; // 1s = 1,000,000 us per pulse
    pulseLength /= freq;          // 40..1000 Hz
    pulseLength /= 4096;          // 12 bits of resolution
    int pulse = us;
    pulse /= pulseLength;
    // println(pulseLength + " us per bit, pulse:" + pulse);
    pwm(channel, 0, pulse);
  }

  public boolean attached(int channel) {
    if (channel < 0 || 15 < channel) {
      return false;
    }
    return (maxPulses[channel] != 0) ? true : false;
  }

  public void detach(int channel) {
    pwm(channel, 0, 0);
    minPulses[channel] = 0;
    maxPulses[channel] = 0;
  }


  /**
   * @param freq 40..1000 Hz
   */
  public void frequency(int freq) {
    this.freq = freq;
    float preScaleVal = 25000000.0f; // 25MHz
    preScaleVal /= 4096.0f;           // 4096: 12-bit
    preScaleVal /= freq;
    preScaleVal -= 1.0f;
    // println("Setting PWM frequency to " + freq + " Hz");
    // println("Estimated pre-scale: " + preScaleVal);
    double preScale = Math.floor(preScaleVal + 0.5f);
    // println("Final pre-scale: " + preScale);
    byte oldmode = (byte) readU8(MODE1);
    byte newmode = (byte) ((oldmode & 0x7F) | 0x10); // sleep
    command(MODE1, newmode);                         // go to sleep
    command(PRESCALE, (byte) (Math.floor(preScale)));
    command(MODE1, oldmode);
    delay(5);
    command(MODE1, (byte) (oldmode | 0x80));
    hasFreqSet = true;
  }

  /**
   * @param channel 0..15
   * @param on      cycle offset to turn output on (0..4095)
   * @param off     cycle offset to turn output off again (0..4095)
   */
  public void pwm(int channel, int on, int off) {
    if (channel < 0 || 15 < channel) {
      throw new IllegalArgumentException("Channel must be between 0 and 15");
    }
    if (on < 0 || 4095 < on) {
      throw new IllegalArgumentException("On must be between 0 and 4095");
    }
    if (off < 0 || 4095 < off) {
      throw new IllegalArgumentException("Off must be between 0 and 4095");
    }
    if (off < on) {
      throw new IllegalArgumentException("Off must be greater than On");
    }
    command(LED0_ON_L + 4 * channel, (byte) (on & 0xFF));
    command(LED0_ON_H + 4 * channel, (byte) (on >> 8));
    command(LED0_OFF_L + 4 * channel, (byte) (off & 0xFF));
    command(LED0_OFF_H + 4 * channel, (byte) (off >> 8));
  }


  private void command(int register, byte value) {
    beginTransmission(address);
    write(register);
    write(value);
    endTransmission();
  }

  private byte readU8(int register) {
    beginTransmission(address);
    write(register);
    byte[] ba = read(1);
    endTransmission();
    return (byte)(ba[0] & 0xFF);
  }
}
// STEERING CONTROLS
int steering = 0;         // Steering Servo PWM Pin
int servoMinAngle = 10;   // Servo Min Angle
int servoMaxAngle = 170;  // Servo Max Angle
int whichDir = 0;         // -100 - 100% (Left to Right)

// Attach Steering Servo
public void initSteering(){
  controller.attach(steering, 544, 2400);  // Attach Servo Motor w/ Pulse Range
  angle = 0;  setDir();                    // Initialize Direction to 0 (center)
  sendMsg("Steering OK");                  // Send Command that Steering is Running
}

// Set Servo Angle
public void setDir(){
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
public void initMotors() {
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
public void setSpeed(){
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
// Network
// Functions and Variables to Control the Onboard Networking Functions

// Server Communication Libraries
            // Networking Library
Server s;                           // Server Object (for sending information)
Client c;                           // Client Object (for receiving information)
String input;                       // Receive Incoming Data as a String
int data[];                         // Parse Incoming Data into this Array

// Initialize Server
public void initServer(){
  s = new Server(this, 8080);       // Start Server on Port 8080
  sendMsg("Server OK");             // Confirm Server is Okay
}

// Send a Message to the Client
public void sendMsg(String msg){
  //s.write(msg);                   // TODO
  //println("Message Sent: " + msg);  // Print the Message to Terminal
}

// Get Incoming Messages to the Server
public void getServer(){
  c = s.available();                                    // Connect to Client
  if(c != null){                                        // If Data is Available
    input = c.readString();                             // Read Incoming Data String
    input = input.substring(0, input.indexOf("\n"));    // Terminate Data at Newline
    String[] ip = split(input, ' ');                   // Parse Data into String Array
    data = PApplet.parseInt(split(input, ' '));                      // Parse Data into Integer Array
        
    println("Raw String: " + ip, data[1], data[2], data[3]);
    
        
    // Update Settings Per Incoming Instructions
    //if(!IPAddress.equals(ip[0])){IPAddress = ip[0]; println("Set IP Address to " + IPAddress); startVideo = true; initVideo();} // Update IP Address
    if(!IPAddress.equals(ip[0])){IPAddress = ip[0]; println("Set IP Address to " + IPAddress); startVideo = true;} // Update IP Address
    if(data[1] != enable){enable = data[1]; println("Set Enable State to " + enable);}            // Update Enable
    if(data[2] != speed){speed = data[2]; setSpeed(); println("Set Speed to " + speed);}  // Update Speed
    if(data[3] != angle){angle = data[3]; setDir(); println("Set Angle to " + angle);}    // Update Angle    
  }
}
  public void settings() {  size(320, 160, P2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ottoBot" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
