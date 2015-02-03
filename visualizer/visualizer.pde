 // Created by Karthik Badam on 2 Feb 2015
 // Adapted from Tom Igoe's sample code
 
 import processing.serial.*;
 import grafica.*; 
 
 Serial myPort;        // The serial port
 int STROKE_COLOR = #57385c; 
 int BACKGROUND_COLOR = #ffedbc;
 float minValue = 1023; 
 int PADDING = 30; 
 int PADDING_SMALL = 5; 
 float prevX = PADDING; 
 float prevY = PADDING; 
 float xPos = PADDING;         // horizontal position of the graph
 
 //number of charts
 int TOTAL_CHARTS = 5;
 int chartWidth = 1000; 
 int chartHeight = 50; 
 
 String[] sensorNames = {"Potentiometer", "Photoresistor", "Hall Sensor", "Toggle Switch", "Push Back Switch"}; 
 float[] y1Ranges = new float[TOTAL_CHARTS];
 float[] y2Ranges = new float[TOTAL_CHARTS];
 
 void setup () {
   
   // set the window size:
   size(1280, 800);        
   smooth();

   // List all the available serial ports
   println(Serial.list());
   myPort = new Serial(this, Serial.list()[2], 9600);
 
   myPort.bufferUntil('\n');
   
   /* initializing viewport */
   background(BACKGROUND_COLOR);
   drawRect (PADDING_SMALL, width - PADDING_SMALL, PADDING_SMALL, height - PADDING_SMALL);
   drawXAxis (PADDING, width - PADDING, height - PADDING);
   chartHeight = (height - 2 * PADDING) / TOTAL_CHARTS;
   chartWidth = width - 2*PADDING;
   
   //data all axis
   for (int i = 0; i < TOTAL_CHARTS; i++) {
     float x = PADDING; 
     float y1 = PADDING + i*chartHeight; 
     float y2 = y1 + chartHeight - PADDING;
    
     y1Ranges[i] = y1; 
     y2Ranges[i] = y2;  
     drawYAxis (x, y1, y2, sensorNames[i]);
   }
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
     int index = int(list[1]);
     float inByte = float(list[2]);
    
     inByte = getNormalizedValue(index, inByte);
     //inByte = map(inByte, PADDING, 1023, 0, height/2 - PADDING);
 
     // draw the line:
     stroke(STROKE_COLOR);
     strokeWeight(2);
     line(prevX, prevY, xPos, height/2 - inByte);
     prevX = xPos; 
     prevY = height/2 - inByte; 
     
     // at the edge of the screen, go back to the beginning:
     if (xPos >= width - PADDING) {
       xPos = PADDING;
       prevX = PADDING; 
       background(BACKGROUND_COLOR); 
       drawRect (PADDING_SMALL, width - PADDING_SMALL, PADDING_SMALL, height - PADDING_SMALL);
       drawXAxis (PADDING, width - PADDING, height - PADDING);
       chartHeight = (height - 2 * PADDING) / TOTAL_CHARTS;
       chartWidth = width - 2*PADDING;
       
       //data all axis
       for (int i = 0; i < TOTAL_CHARTS; i++) {
         float x = PADDING; 
         float y1 = PADDING + i*chartHeight; 
         float y2 = y1 + chartHeight; 
         drawYAxis (x, y1, y2, sensorNames[i]);  
       }
     } else {
       
       xPos = xPos + PADDING_SMALL;
     }
   }
 }
 
  void drawRect (float x1, float x2, float y1, float y2) {
    strokeWeight (1);
    stroke(STROKE_COLOR);
    fill(BACKGROUND_COLOR);
    rect(x1, y1, x2 - x1, y2 - y1); 
    PFont font = loadFont("Garamond-32.vlw");
    stroke (STROKE_COLOR);
    fill (STROKE_COLOR);
    textFont(font, 32);
    text ("Sensor Visualization", 15, 30);
  }
   
  void drawXAxis (float x1, float x2, float y) {
    
    strokeWeight (1);
    stroke (STROKE_COLOR);
    fill (STROKE_COLOR);
     
    line (x1, y, x2, y);
    triangle ( x2, y, x2-2*PADDING_SMALL, y-2*PADDING_SMALL, x2-2*PADDING_SMALL, y+2*PADDING_SMALL);
    
    PFont font = loadFont("Garamond-32.vlw");
    textFont(font, 15);
    text ("time", x1 + 2*PADDING_SMALL, y + 2*PADDING_SMALL);
  }


  void drawYAxis (float x, float y1, float y2, String name) {
     
    strokeWeight (1);
    stroke (STROKE_COLOR);
    fill (STROKE_COLOR);
     
    line (x, y1, x, y2);
    
    PFont font = loadFont("Garamond-32.vlw");
    textFont(font, 15);
    
    
    text (0, x - PADDING_SMALL, y1);
    text (1023, x - PADDING_SMALL, y2);
    text (name, x + PADDING_SMALL, y1 + 3*PADDING_SMALL);
    
  }
  
  float getNormalizedValue (int index, float inByte) {
    float y1 = y1Ranges[index];
    float y2 = y2Ranges[index];
    
    return map(inByte, 0, 1023, y1, y2);  
  }
