
int INPUT_PIN = 0; 
int blinkDelayMs = 300; 
int ledVal = 0;
int analogVal = 0;
int LED_PIN = 10; 

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  //read analog value
  analogVal = analogRead(INPUT_PIN); 
  
  ledVal = map(analogVal, 0, 1023, 0, 255); 
  
  //analogWrite(LED_PIN, 255); 
  
  Serial.println("Photoresistor,A,"+String(analogVal)); 
  
   delay(blinkDelayMs);
}
