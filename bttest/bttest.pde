
int ledpin = 13;
void setup() 
{ 
  // prints title with ending line break 
  Serial1.begin(9600); 
  pinMode(ledpin, OUTPUT);
} 



void loop() 
{  

  Serial1.println("Hello World");   
  digitalWrite(ledpin, HIGH);
  delay(1000);
  digitalWrite(ledpin, LOW);
  delay(500);
  while (Serial1.available()) {
    int val = Serial1.read();
    Serial1.println(val);
  }
  
} 
