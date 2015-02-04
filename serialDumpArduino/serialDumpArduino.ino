
int POTENTIOMETER_PIN = 0; 
int PHOTORESISTOR_PIN = 1; 
int MICROSENSOR_PIN = 2; 

int blinkDelayMs = 100; 
int ledVal = 0;

int potentVal = 0;
int photoVal = 0;
int soundVal = 0; 

int LED_PIN = 10; 
int SWITCH_PIN1 = 9; 
int SWITCH_PIN2 = 8; 

int switchState1 = 0; 
int switchState2 = 0; 

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(LED_PIN, OUTPUT);
  pinMode(SWITCH_PIN1, INPUT_PULLUP); 
  pinMode(SWITCH_PIN2, INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  //read analog value
  potentVal = analogRead(POTENTIOMETER_PIN); 
  
  ledVal = map(potentVal, 0, 1023, 0, 255); 
 
  photoVal = analogRead(PHOTORESISTOR_PIN); 
  
  soundVal = analogRead(MICROSENSOR_PIN); 
    
  //analogWrite(LED_PIN, HIGH); 
  
  switchState1 = digitalRead(SWITCH_PIN1); 
  
  switchState2 = digitalRead(SWITCH_PIN2); 
  
  //Serial.println("A,0," + String(potentVal)); 
  
  //Serial.println("A,1," + String(photoVal)); 
  
  //Serial.println("A,2," + String(soundVal)); 
  
  //Serial.println("D,3," + String(switchState1)); 
  
  //Serial.println("D,4," + 0); 
  
  Serial.println("A,0," + String(potentVal) + ",A,1," + String(photoVal) + ",A,2," + String(soundVal) + ",D,3," + String(switchState1) + ",D,4," + 1); 
  
  delay(blinkDelayMs);
}
