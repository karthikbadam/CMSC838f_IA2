 // Created by Karthik Badam on 3 Feb 2015
 // Inspired from Ji Zhang's code for creating the iconic Matrix visual effect
 
 import processing.serial.*;
 
 Serial myPort;        // The serial port
   
 // COLOR SCHEME: GREEN, LIME, PISTACHIO, MINT, MINT
 int[] colors = {#BFFF00, #FE6F5E, #FFF600, #F5FFFA, #F5FFFA};
 int defaultColor = #888888;
 
 int[] sensorRanges = {1023, 300, 100, 1, 1};
 
 int currY = -100; 
 
 //number of charts
 int TOTAL_CHARTS = 5;
 
 int[] columnRanges = new int[TOTAL_CHARTS]; 
 
 int TOTAL_COLUMNS = 800; 
 
 String inString = null; 
 String preInString = null; 
 
 int[] randomX; 
 int[] randomY; 
 
 int[][] randomColumnIndices = new int[TOTAL_CHARTS][TOTAL_COLUMNS]; 
 int[] columnsAllocated = new int[TOTAL_CHARTS];
 //ALGORITHM:
   // sensor ranges define number of columns for the sensor
   // sensor values define number of active columns
   // draw random text in sensor color  
 
 int DIGITAL_CHARTS = 2; 
 int ANALOG_CHARTS = 3;
 int[] col = new int[20];

 String[] sensorNames = {"Potentiometer", "Photoresistor", "Microphone", "Tactile Button", "Switch"}; 
 
 PFont font; 
  
boolean sketchFullScreen() {
  return true;
} 
 
 void setup () {
   
   // set the window size:
   size(displayWidth, displayHeight);
   frameRate(30);   
   //colorMode(HSB,360,100,100);
  
   font = createFont("Arial Black", 10);
   textFont(font);
   
   for (int i = 0; i < TOTAL_CHARTS; i++) {
      if (i == 3) {
        columnRanges[i] = floor(random(0, TOTAL_COLUMNS/2));
      } else if (i == 4) {
        columnRanges[i] = floor(random(TOTAL_COLUMNS/2, TOTAL_COLUMNS));
      }
   }
   
   columnRanges[0] = int(TOTAL_COLUMNS); 
   columnRanges[1] = int(TOTAL_COLUMNS);
   columnRanges[2] = int(TOTAL_COLUMNS*0.3);
  
   // List all the available serial ports
   println(Serial.list());
   myPort = new Serial(this, Serial.list()[2], 9600);
   myPort.bufferUntil('\n');
   
   randomX = new int[TOTAL_COLUMNS]; 
   randomY = new int[TOTAL_COLUMNS];
   
   //create random column positions
   for (int i = 0; i < TOTAL_COLUMNS; i++) {
     randomX[i] = floor(random(displayWidth/10)) * 10; 
     randomY[i] = floor(random(-displayHeight, displayHeight)); 
   }
 }
 
 void draw () {
   // everything happens in the serialEvent()
   //myLoop();
 }
 
 void myLoop(String type, int index, float inByte) {
   fill(0, 10); 
   noStroke();
   rect(0, 0, displayWidth, displayHeight); 
   
//   if (inString == null) {
//     inString = "A,0,1000,A,1,0,A,2,0,D,3,1,D,4,1";    
//   }
//   
//   inString = trim(inString);
//   String[] list = split(inString, ',');
// 
   // convert to an int and map to the screen height:
//   int index = int(list[1]);
//   float inByte = float(list[2]);
//    
//   
   if (type.equals("D")) {
     //inByte = getDigitalNormalizedValue(index, inByte);
     
     /*manage the flow of characters for Digital case*/
     //pick three columns surrounding a random selected column
     if (inByte == 0) {
       int x1 = int((index-3)*TOTAL_COLUMNS/2);
       int x2 = int(x1 + TOTAL_COLUMNS/2 - 2);
       col[0] = floor(random(x1, x2)); 
       for (int i =1; i < 20; i++) {
         col[i] = col[i-1] + 10;
       }
       
         
       //now draw characters at these locations
       for (int i = 0; i < 20; i++) {
         char randomCharacter = char(floor(random(255)));
         fill(colors[index]);
         text(randomCharacter, floor(col[i] * displayWidth/TOTAL_COLUMNS), currY); 
       }
     }
   } else { 
     //inByte = getAnalogNormalizedValue(index, inByte);
      
     columnsAllocated[index] = floor(map(inByte, 0, sensorRanges[index], 10, columnRanges[index]));
     println(index+","+columnsAllocated[index]);
     
     if (!inString.equals(preInString) || preInString == null) {
       randomColumnIndices[index] = new int[columnsAllocated[index]];
       for (int i = 0; i < columnsAllocated[index]; i++) {
         randomColumnIndices[index][i] = floor(random(TOTAL_COLUMNS - 1)); 
       }  
     }
     
     for (int i = 0; i < columnsAllocated[index]; i++) {
       char randomCharacter = char(floor(random(255)));
       fill(colors[index]);
       text(randomCharacter, randomX[randomColumnIndices[index][i]], currY + randomY[i]);      
     }
     
   }
   
   currY = currY + 8;
   
   if (currY > displayHeight + 10) {
     currY = -100;
   }
  
 }
 
 void serialEvent (Serial myPort) {
     inString = myPort.readStringUntil('\n');
     if (inString == null) {
       inString = preInString; 
     }
     println("read");
     
     if (inString == null) {
       inString = "A,0,1000,A,1,0,A,2,0,D,3,1,D,4,1";    
     }
     
     inString = trim(inString);
     String[] list = split(inString, ',');
     
     int counter = 0; 
     for (int i = 0; i < TOTAL_CHARTS; i++) {
         String type = list[counter];
         int index = int(list[counter+1]);
         float inByte = float(list[counter+2]); 
         counter = counter + 3; 
         myLoop(type, index, inByte);
     }
     
     preInString = inString; 
     
 }
 
