//************** DON'T TOUCH CODE BELOW THIS LINE ******************//
import processing.net.*;  // Import Network Library
Client c;                 // Create Network Client

// Initialize Network
void initNetwork(){println("Connecting to Network..."); c = new Client(this, ottoBotIP, 8080); sendConfig();} // Connect to the OttoBot on Port 8080

int[] lastConfig = new int[3];          // Store Last Configuration

// Check to See if Any Configurations Have Changed
void checkConfig(){
  boolean isChange = false;
  
  if(enable != lastConfig[0])      {lastConfig[0] = enable;     isChange = true;}
  if(speed != lastConfig[1])       {lastConfig[1] = speed;      isChange = true;}
  if(angle != lastConfig[2])       {lastConfig[2] = angle;      isChange = true;}

  if(isChange){sendConfig();}
}


// Send Configuration Settings to the OttoBot
void sendConfig(){
  String msg = ottoControlIP + " " + enable + " " + speed + " " + angle + "\n";
  c.write(msg);
  
  println("Config Sent");
  println(msg);
}
