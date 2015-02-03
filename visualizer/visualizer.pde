 // Created by Karthik Badam on 2 Feb 2015
 // Adapted from Tom Igoe's sample code
 
 import processing.serial.*;
 
 Serial myPort;        // The serial port
 int xPos = 1;         // horizontal position of the graph
 
 void setup () {
   // set the window size:
   size(400, 300);        
 
   // List all the available serial ports
   println(Serial.list());
   myPort = new Serial(this, Serial.list()[2], 9600);
 
   myPort.bufferUntil('\n');
   background(0);
 }
 
 void draw () {
   // everything happens in the serialEvent()
 }
 
 void serialEvent (Serial myPort) {
   String inString = myPort.readStringUntil('\n');
 
   if (inString != null) {
     inString = trim(inString);
     String[] list = split(inString, ',');
 
     // convert to an int and map to the screen height:
     float inByte = float(list[2]); 
     inByte = map(inByte, 0, 1023, 0, height);
 
     // draw the line:
     stroke(255, 10, 10);
     line(xPos, height, xPos, height - inByte);
 
     // at the edge of the screen, go back to the beginning:
     if (xPos >= width) {
       xPos = 0;
       background(255); 
       
     } else {
       
       xPos++;
     }
   }
 }
 
