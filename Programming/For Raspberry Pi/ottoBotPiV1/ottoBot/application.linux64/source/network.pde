// Network
// Functions and Variables to Control the Onboard Networking Functions

// Server Communication Libraries
import processing.net.*;            // Networking Library
Server s;                           // Server Object (for sending information)
Client c;                           // Client Object (for receiving information)
String input;                       // Receive Incoming Data as a String
int data[];                         // Parse Incoming Data into this Array

// Initialize Server
void initServer(){
  s = new Server(this, 8080);       // Start Server on Port 8080
  sendMsg("Server OK");             // Confirm Server is Okay
}

// Send a Message to the Client
void sendMsg(String msg){
  //s.write(msg);                   // TODO
  //println("Message Sent: " + msg);  // Print the Message to Terminal
}

// Get Incoming Messages to the Server
void getServer(){
  c = s.available();                                    // Connect to Client
  if(c != null){                                        // If Data is Available
    input = c.readString();                             // Read Incoming Data String
    input = input.substring(0, input.indexOf("\n"));    // Terminate Data at Newline
    String[] ip = split(input, ' ');                   // Parse Data into String Array
    data = int(split(input, ' '));                      // Parse Data into Integer Array
        
    println("Raw String: " + ip, data[1], data[2], data[3]);
    
        
    // Update Settings Per Incoming Instructions
    //if(!IPAddress.equals(ip[0])){IPAddress = ip[0]; println("Set IP Address to " + IPAddress); startVideo = true; initVideo();} // Update IP Address
    if(!IPAddress.equals(ip[0])){IPAddress = ip[0]; println("Set IP Address to " + IPAddress); startVideo = true;} // Update IP Address
    if(data[1] != enable){enable = data[1]; println("Set Enable State to " + enable);}            // Update Enable
    if(data[2] != speed){speed = data[2]; setSpeed(); println("Set Speed to " + speed);}  // Update Speed
    if(data[3] != angle){angle = data[3]; setDir(); println("Set Angle to " + angle);}    // Update Angle    
  }
}
