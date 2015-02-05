 // Created by Karthik Badam on 3 Feb 2015 -- Modern Matrix effect!
 // Inspired from Ji Zhang's algorithm for creating the iconic Matrix visual effect
 //ALGORITHM:
   // sensor ranges define number of columns for the sensor
   // sensor values define number of active columns
   // draw random text at each active column using a predefined color for each sensor  
 
 import processing.serial.*;
 
 Serial myPort;        // The serial port
   
 // COLOR SCHEME: GREEN, YELLOW, RED, MINT, MINT -- TRYING TO STICK TO THE ORIGINAL MATRIX EFFECT
 int[] colors = {#BFFF00, #FE6F5E, #FFF600, #F5FFFA, #F5FFFA};
 String[] sensorNames = {"Potentiometer", "Photoresistor", "Microphone", "Tactile Button", "Switch"}; 
 
 // Maximum values possible for each sensor
 int[] sensorRanges = {1023, 300, 100, 1, 1};
 
 // Characters start from currY
 int currY = -100; 
 
 // Number of charts
 int TOTAL_CHARTS = 5;
 
 // Range of column values to seed in the Matrix effect for each sensor
 int[] columnRanges = new int[TOTAL_CHARTS]; 
 int TOTAL_COLUMNS = 800; 
 int[][] randomColumnIndices = new int[TOTAL_CHARTS][TOTAL_COLUMNS]; 
 int[] columnsAllocated = new int[TOTAL_CHARTS];
 
 // Current and previous lines read from Arduino
 String inString = null; 
 String preInString = null; 
 
 // Random x, y co-ordinates for Matrix effect
 int[] randomX; 
 int[] randomY; 
 
 // For Digital sensors, the number of columns to be highlighted
 int DICRETE_COLUMN_SIZE = 20; 
 int[] col = new int[DICRETE_COLUMN_SIZE];

 PFont font; 
 
 //Full screen mode 
 boolean sketchFullScreen() {
   return true;
 } 
 
 void setup () {
   
   // set the window size:
   size(displayWidth, displayHeight);
   
   // Frame rate is rather low for the Matrix effect but can't help because Arduino writes slowly
   frameRate(30);   
   
   // Creating font
   font = createFont("Arial Black", 10);
   textFont(font);
   
   // Defining the number of columns for each sensor -- hard coded!!
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
   
   // Creating random x, y positions
   for (int i = 0; i < TOTAL_COLUMNS; i++) {
     randomX[i] = floor(random(displayWidth/10)) * 10; 
     randomY[i] = floor(random(-displayHeight, displayHeight)); 
   }
   
 }
 
 void draw () {
   // everything happens in the serialEvent()
 }
 
 void myLoop(String type, int index, float inByte) {
   
   // Drawing a transparent layer to create the fading effect
   fill(0, 10); 
   noStroke();
   rect(0, 0, displayWidth, displayHeight); 
    
   if (type.equals("D")) {
     
     /* Managing the flow of characters for Digital case*/
     // pick 20 columns surrounding a random selected column
     if (inByte == 0) {
       int x1 = int((index-3)*TOTAL_COLUMNS/2);
       int x2 = int(x1 + TOTAL_COLUMNS/2 - 20);
       col[0] = floor(random(x1, x2)); 
       for (int i =1; i < DICRETE_COLUMN_SIZE; i++) {
         col[i] = col[i-1] + 3;
       }
       
       // drawing characters at these locations
       for (int i = 0; i < 20; i++) {
         char randomCharacter = char(floor(random(255)));
         fill(colors[index]);
         text(randomCharacter, floor(col[i] * displayWidth/TOTAL_COLUMNS), currY); 
       }
     }
   } else { 
     
     // Assigning number of active columns based on the sensor value
     columnsAllocated[index] = floor(map(inByte, 0, sensorRanges[index], 10, columnRanges[index]));
     
     // Pikcing the column numbers randomly
     if (!inString.equals(preInString) || preInString == null) {
       randomColumnIndices[index] = new int[columnsAllocated[index]];
       for (int i = 0; i < columnsAllocated[index]; i++) {
         randomColumnIndices[index][i] = floor(random(TOTAL_COLUMNS - 1)); 
       }  
     }
     
     // Drawing characters
     for (int i = 0; i < columnsAllocated[index]; i++) {
       char randomCharacter = char(floor(random(255)));
       fill(colors[index]);
       text(randomCharacter, randomX[randomColumnIndices[index][i]], currY + randomY[i]);      
     }
     
   }
   
   // Falling effect
   currY = currY + 8;
   
   // Reinitiate starting y value
   if (currY > displayHeight + 10) {
     currY = -100;
   }
  
 }
 
 // For every line written by Arduino of the form triplets -- "type, channel, value..."
 void serialEvent (Serial myPort) {
     inString = myPort.readStringUntil('\n');
     if (inString == null) {
       inString = preInString; 
     }
     
     
     if (inString == null) {
       inString = "A,0,1000,A,1,0,A,2,0,D,3,1,D,4,1";    
       // Default string to keep the effect rolling even when no value is read  
     }
     
     inString = trim(inString);
     String[] list = split(inString, ',');
     
     // Each line read from the Arduino is like "type1, channel1, value1, type2, channel2, value2,..."
     // type defines whether its Analog or Digital -- "A" or "D"
     // channel defines the sensor kind
     // value is the value read
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
 
