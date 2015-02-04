 // Created by Karthik Badam on 2 Feb 2015
 // Adapted from Tom Igoe's sample code
 
 import processing.serial.*;
 
 Serial myPort;        // The serial port
 int STROKE_COLOR = #57385c; 
 int BACKGROUND_COLOR = #ffedbc;
 float minValue = 1023; 
 int PADDING = 40; 
 int PADDING_SMALL = 5; 
 float xPos = PADDING;         // horizontal position of the graph
 
 //number of charts
 int TOTAL_CHARTS = 5;
 int chartWidth = 1000; 
 int chartHeight = 50; 
 
 String[] sensorNames = {"Potentiometer", "Photoresistor", "Hall Sensor", "Tactile Button", "Switch"}; 
 int[] sensorRanges = {1023, 1023, 1023, 1, 1};
 
 float[] prevX = new float[TOTAL_CHARTS]; 
 float[] prevY = new float[TOTAL_CHARTS]; 
 float[] prevRaw = new float[TOTAL_CHARTS]; 
 
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
     float y1 = 1.5*PADDING + i*chartHeight; 
     float y2 = y1 + chartHeight - PADDING;
     
     prevX[i] = x;
     prevY[i] = y2;
    
     y1Ranges[i] = y1; 
     y2Ranges[i] = y2;  
     drawYAxis (x, y1, y2, i, sensorNames[i]);
     
     prevRaw[i] = 0; 
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
     float rawValue = inByte;
     if (list[0].equals("D"))
       inByte = getDigitalNormalizedValue(index, inByte);
     else 
       inByte = getAnalogNormalizedValue(index, inByte);
     
     //inByte = map(inByte, PADDING, 1023, 0, height/2 - PADDING);
 
     // draw the line:
     stroke(STROKE_COLOR);
     strokeWeight(2);
     line(prevX[index], prevY[index], xPos, inByte);
     prevX[index] = xPos; 
     prevY[index] = inByte; 
     
     if (abs(rawValue - prevRaw[index]) > 200) {
       PFont font = loadFont("Garamond-32.vlw");
       textFont(font, 11);
       text(int(rawValue), xPos, inByte - 5);
     }
     
     prevRaw[index] = rawValue;
     
     
     // at the edge of the screen, go back to the beginning:
     if (xPos >= width - PADDING) {
       xPos = PADDING;
        background(BACKGROUND_COLOR); 
       drawRect (PADDING_SMALL, width - PADDING_SMALL, PADDING_SMALL, height - PADDING_SMALL);
       drawXAxis (PADDING, width - PADDING, height - PADDING);
       chartHeight = (height - 2 * PADDING) / TOTAL_CHARTS;
       chartWidth = width - 2*PADDING;
       
       //data all axis
       for (int i = 0; i < TOTAL_CHARTS; i++) {
         prevX[i] = PADDING; 
              
         float x = PADDING; 
         float y1 = 1.5*PADDING + i*chartHeight; 
         float y2 = y1 + chartHeight - PADDING;
     
         drawYAxis (x, y1, y2, i, sensorNames[i]);  
       }
     } else {
       
       xPos = xPos + 2;
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


  void drawYAxis (float x, float y1, float y2, int i, String name) {
     
    strokeWeight (1);
    stroke (STROKE_COLOR);
    fill (STROKE_COLOR);
     
    line (x, y1, x, y2);
    
    PFont font = loadFont("Garamond-32.vlw");
    textFont(font, 15);
    
    if (i < 3 )
      text (sensorRanges[i], x - 6 * PADDING_SMALL, y1 + PADDING_SMALL);
    else 
      text (sensorRanges[i], x - 2 * PADDING_SMALL, y1 + PADDING_SMALL);
      
    text (0, x - 2*PADDING_SMALL, y2);
    text (name, x + PADDING, y1 - PADDING_SMALL);
    
  }
  
  float getAnalogNormalizedValue (int index, float inByte) {
    float y1 = y1Ranges[index];
    float y2 = y2Ranges[index];
    
    return map(1023-inByte, 0, 1023, y1, y2);  
  }
  
  float getDigitalNormalizedValue (int index, float inByte) {
    float y1 = y1Ranges[index];
    float y2 = y2Ranges[index];
    
    if (inByte == 0)
      return y1;
    
    return y2;  
  }
