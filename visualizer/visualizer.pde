 // Created by Karthik Badam on 2 Feb 2015
 // Adapted from Tom Igoe's sample code
 
 import processing.serial.*;
 
 Serial myPort;        
 
 //BACKGROUND AND STROKE COLOR -- TUFTE STYLE
 int STROKE_COLOR = #57385c; 
 int BACKGROUND_COLOR = #ffedbc;
 
 //Standard definitions for padding 
 int PADDING = 40; 
 int PADDING_SMALL = 5; 
 
 //Starting x-coordinate
 float xPos = PADDING;        
 
 //Number of charts
 int TOTAL_CHARTS = 5;
 int chartWidth = 1000; 
 int chartHeight = 50; 

 //Names of the Sensors -- predefining the channel for each sensor
 String[] sensorNames = {"Potentiometer", "Photoresistor", "Microphone", "Tactile Button", "Switch"}; 
 
 //Maximum values taken by the sensors -- Varies with sensor type
 int[] sensorRanges = {1023, 200, 50, 1, 1};
 
 //Previous x, y for each sensor visualization
 float[] prevX = new float[TOTAL_CHARTS]; 
 float[] prevY = new float[TOTAL_CHARTS]; 
 
 //Previous raw value -- Dont want to use map again
 float[] prevRaw = new float[TOTAL_CHARTS]; 
 
 //The y1, y2 ranges of each sensor chart in the layout
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
   
   // Initializing the x, y ranges for each chart
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
 
 // For every line written by Arduino of the form triplets -- "type, channel, value..."
 void serialEvent (Serial myPort) {
   
   String inString = myPort.readStringUntil('\n');
    
   if (inString != null) {
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
         
         //calling myLoop to draw each sensor value
         myLoop(type, index, inByte);
     }
   }
 }
 
 //Takes the sensor type, name, and value as input and plots!
 void myLoop(String type, int index, float inByte) {
     
   float rawValue = inByte;
   
   // Getting normalized value according to the dimensions of each chart
   if (type.equals("D"))
     inByte = getDigitalNormalizedValue(index, inByte);
   else 
     inByte = getAnalogNormalizedValue(index, inByte);
   
   // Drawing the line
   stroke(STROKE_COLOR);
   strokeWeight(2);
   line(prevX[index], prevY[index], xPos, inByte);
   prevX[index] = xPos; 
   prevY[index] = inByte; 
   
   // A conditional statement to show the sensor value if there are drastic changes happening
   if (sensorRanges[index] != 1 && abs(rawValue - prevRaw[index]) > sensorRanges[index]/3) {
     PFont font = loadFont("Garamond-32.vlw");
     textFont(font, 11);
     text(int(rawValue), xPos, inByte - 5);
   }
   
   prevRaw[index] = rawValue;
   
   // At the edge of the screen, go back to the beginning:
   if (xPos >= width - PADDING) {
     
     xPos = PADDING;
     background(BACKGROUND_COLOR); 
     drawRect (PADDING_SMALL, width - PADDING_SMALL, PADDING_SMALL, height - PADDING_SMALL);
     drawXAxis (PADDING, width - PADDING, height - PADDING);
     chartHeight = (height - 2 * PADDING) / TOTAL_CHARTS;
     chartWidth = width - 2*PADDING;
     
     // Initializing the x, y ranges for each chart
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
 
 //Draw viewport
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
   
  //Draw X-Axis
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

  //Draw Y-Axis for each chart
  void drawYAxis (float x, float y1, float y2, int i, String name) {
     
    strokeWeight (1);
    stroke (STROKE_COLOR);
    fill (STROKE_COLOR);
     
    line (x, y1, x, y2);
    
    PFont font = loadFont("Garamond-32.vlw");
    textFont(font, 15);
    
    if (i < 3)
      text (sensorRanges[i], x - 4 * PADDING_SMALL, y1 + PADDING_SMALL);
    else 
      text (sensorRanges[i], x - 2 * PADDING_SMALL, y1 + PADDING_SMALL);
      
    text (0, x - 2*PADDING_SMALL, y2);
    text (name, x + PADDING, y1 - PADDING_SMALL);
    
  }
  
  float getAnalogNormalizedValue (int index, float inByte) {
    float y1 = y1Ranges[index];
    float y2 = y2Ranges[index];
    
    return map(float(sensorRanges[index])-inByte, 0, sensorRanges[index], y1, y2);  
  }
  
  float getDigitalNormalizedValue (int index, float inByte) {
    float y1 = y1Ranges[index];
    float y2 = y2Ranges[index];
    
    if (inByte == 0)
      return y1;
    
    return y2;  
  }
