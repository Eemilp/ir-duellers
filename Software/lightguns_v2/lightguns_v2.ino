volatile bool alive = true;//boolean to determine guns state

const uint8_t IRfrequency = 36000;
const unsigned long signalLenght = 50; //milliseconds

unsigned long lastShot;

unsigned long hitBegan;

const unsigned long hitLenght = 20;

const unsigned long delayBetweenShots = 150;

//pin numbering
const int trigPin = 3;
const int sensorPin = 2;
const int IRpin = 0;
const int piezoPin = 1;
const int statusLedPin = 4;

void setup() {

  pinMode(trigPin, INPUT);
  pinMode(sensorPin, INPUT);
  pinMode(IRpin, OUTPUT);
  pinMode(piezoPin, OUTPUT);
  pinMode(statusLedPin, OUTPUT);

  ADCSRA &= (~(1 << ADEN)); //turning ADC off, because it's not used

  for (int i = 1000; i > 300; i = i - 100) {
      tone(piezoPin, i, 50); //generating the gun sound
      delay(50);
  }
  
  digitalWrite(statusLedPin, HIGH);//letting know that the gun is ready

  while (alive == true) {
    
    if (digitalRead(trigPin) == HIGH && millis() - lastShot > delayBetweenShots) {//sending IR signal, lastShot for moderating fire rate
      
      for(unsigned long i = 0; i <= 36000; i++){ //sending the IR signal, this might need calibration!
        digitalWrite(IRpin, HIGH);
        delayMicroseconds(5);
        digitalWrite(IRpin, LOW);
        delayMicroseconds(4);
      }

      for (int i = 10000; i > 300; i = i - 150) {
        tone(piezoPin, i, 2); //generating the gun sound
        delay(2);
      }
      lastShot = millis();
    }

    //checking if ir signal has been recieved. Sensor returns LOW on signal.
    //In some conditions when the signal is not received well this can cause problems!
    if (digitalRead(sensorPin) == LOW) {
      
      hitBegan = millis();
      
      while(digitalRead(sensorPin) == LOW){
        //empty loop while recieving signal
      }

      if(millis() - hitBegan > hitLenght){//checking if recieved signal was long enough
      alive = false;
      }
    }
  }

  digitalWrite(IRpin, LOW);
  digitalWrite(statusLedPin, LOW); //letting know that player lost.
  //death sound effect
  for (int k = 0; k < 30; k++) {
    int toneLenght = 0;
    toneLenght = random(5, 50);
    tone(piezoPin, random(100, 1500), toneLenght);
    delay(toneLenght);
  }
  delay(200);
  for (int k = 0; k < 3; k++) {
    for (int i = 1000; i > 300; i = i - 100) {
      tone(piezoPin, i, 50); //generating the gun sound
      delay(50);
    }
  }

}

void loop() {
  //do nothing when we are dead
}
