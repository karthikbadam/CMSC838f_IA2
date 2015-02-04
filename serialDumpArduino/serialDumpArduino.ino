
int POTENTIOMETER_PIN = 0; 
int PHOTORESISTOR_PIN = 1; 
int MICROSENSOR_PIN = 2; 

int blinkDelayMs = 300; 
int ledVal = 0;

int potentVal = 0;
int photoVal = 0;
int soundVal = 0; 

int LED_PIN = 10; 
int SWITCH_PIN = 9; 

int switchState = 0; 

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(SWITCH_PIN, INPUT_PULLUP); 
}

void loop() {
  // put your main code here, to run repeatedly:
  //read analog value
  potentVal = analogRead(POTENTIOMETER_PIN); 
  
  ledVal = map(potentVal, 0, 1023, 0, 255); 
 
  photoVal = analogRead(PHOTORESISTOR_PIN); 
  
  soundVal = analogRead(MICROSENSOR_PIN); 
    
  analogWrite(LED_PIN, HIGH); 
  
  switchState = digitalRead(SWITCH_PIN); 
  
  Serial.println("A,0," + String(potentVal)); 
  
  Serial.println("A,1," + String(photoVal)); 
  
  Serial.println("A,2," + String(soundVal)); 
  
  Serial.println("D,3," + String(switchState)); 
  
  delay(blinkDelayMs);
}
