int mapX(int low, int high){int x = (int)map(mouseX, 0, width, low, high); println("Map X: " + x); return x;}
int mapY(int low, int high){int y = (int)map(mouseY, 0, height, low, high); println("Map Y: " + y); return y;}
void showMouse(){println("Mouse Position: " + mouseX + ", " + mouseY);}
int selectAmt = 5;

void keyPressed(){
  if(key == CODED){
    if (keyCode == UP){speed = 100;}                                               // Full Speed Ahead
    if (keyCode == DOWN){speed = 0;}                                               // Stop
    if (keyCode == LEFT){angle = max(angle - 20, -80);}                            // Increase Left Turn
    if (keyCode == RIGHT){angle = min(angle + 20, 80);}                            // Increase Right Turn
  }
  
  switch(key){    
    case 'a': selectX = max(selectX - selectAmt, 0); break;                        // Decrease Video Selection X Coord
    case 'd': selectX = min(selectX + selectAmt, video.width - selectW); break;    // Increase Video Selection X Coord
    case 'w': selectY = max(selectY - selectAmt, 0); break;                        // Decrease Video Selection Y Coord
    case 's': selectY = min(selectY + selectAmt, video.height - selectH); break;   // Increase Video Selection Y Coord
    
    case 'q': selectW = max(selectW - selectAmt, 1); break;                        // Decrease Video Selection Width
    case 'e': selectW = min(selectW + selectAmt, video.width); break;              // Increase Video Selection Width
    case 'z': selectH = max(selectH - selectAmt, 1); break;                        // Decrease Video Selection Height
    case 'c': selectH = min(selectH + selectAmt, video.height); break;             // Increase Video Selection Height
    
    case 'm': toggleVideo = !toggleVideo; break;                                   // Toggle Unprocessed/Processed Video
    case 'n': toggleAuto = !toggleAuto; break;                                     // Toggle Autonomous Control

    case ' ': angle = 0; speed = 0; break;                                         // Reset Speed/Angle to 0

    case '1': speed = -100; break;
    case '2': speed = -50; break;
    case '3': speed = 0; break;
    case '4': speed = 50; break;
    case '5': speed = 100; break;
    case '6': angle = -80; break;
    case '7': angle = -50; break;
    case '8': angle = 0; break;
    case '9': angle = 50; break;
    case '0': angle = 80; break;
    
  }
  
  println("Video Selection Settings || x: " + selectX + ", y: " + selectY + "\t w: " + selectW + ", h: " + selectH);

}
