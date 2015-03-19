#include <SoftPWMServo.h>
#include <SPI.h>

const int sevenSegs[10] = {B10000000,B11100110,B01001000,B01000010,B00100110,B00010010,B00010000,B11000110,B00000000,B00000110};
const int redPin=77,greenPin=76,bluePin=75,fanChan1=74,fanChan2=73;

float hue=0.0, saturation=1.0, value=1.0;
String inString = "";
int temp = 0;

void setup() {
  SPI.begin();
  SPI.setClockDivider(SPI_CLOCK_DIV8);
  SPI.setDataMode(SPI_MODE0);
  SPI.setBitOrder(LSBFIRST);
  SoftPWMServoInit(); 
  SoftPWMServoSetFrameTime(usToTicks(45));
  SoftPWMServoPWMWrite(redPin,0);
  SoftPWMServoPWMWrite(bluePin,0);
  SoftPWMServoPWMWrite(greenPin,0);
  Serial.begin(115200);
}

void loop() {
  while(Serial.available() > 0)
  {  
    int inChar = Serial.read();
    if (isDigit(inChar)) {
      // convert the incoming byte to a char
      // and add it to the string:
      inString += (char)inChar;
    }
    if (inChar == '>') {
      Serial.print("Value:");
      Serial.println(inString.toInt());
      Serial.print("String: ");
      Serial.println(inString);
      // clear the string for new input:
      temp = inString.toInt();
      inString = "";
    }
  }
  
  SetFansSpeedPercent(temp, temp);

  //digitalWrite(fanChan1,HIGH);
  for (int i=0; i<100; i++){
    SPIsevenSeg(i);
    SetColor(hue);
    delay(10);
    hue+=0.06;
  }
  hue=0.0;
}

void SPIsevenSeg(int i){
  SPI.transfer(sevenSegs[i%10]);
  SPI.transfer(sevenSegs[i/10]);
}

void SetColor(float hueVal){
  unsigned long RGBcolor = HSV_to_RGB(hueVal,saturation,value);
  SoftPWMServoPWMWrite(bluePin,(RGBcolor&0xff));
  SoftPWMServoPWMWrite(greenPin,(RGBcolor>>8)&0xff);
  SoftPWMServoPWMWrite(redPin,(RGBcolor>>16)&0xff);
}

void SetFansSpeedPercent(int one, int two){
  if(one==100){
    digitalWrite(fanChan1,HIGH);
  }else{
    SoftPWMServoPWMWrite(fanChan1,map(one,0,255,0,100));
  }
  if(two==100){
    digitalWrite(fanChan2,HIGH);
  }else{
    SoftPWMServoPWMWrite(fanChan2,map(two,0,255,0,100));
  } 
}

long HSV_to_RGB( float h, float s, float v ) {
  /* modified from Alvy Ray Smith's site: http://www.alvyray.com/Papers/hsv2rgb.htm */
  // H is given on [0, 6]. S and V are given on [0, 1].
  // RGB is returned as a 24-bit long #rrggbb
  int i;
  float m, n, f;
 
  // not very elegant way of dealing with out of range: return black
  if ((s<0.0) || (s>1.0) || (v<0.0) || (v>1.0)) {
    return 0L;
  }
 
  if ((h < 0.0) || (h > 6.0)) {
    return long( v * 255 ) + long( v * 255 ) * 256 + long( v * 255 ) * 65536;
  }
  i = floor(h);
  f = h - i;
  if ( !(i&1) ) {
    f = 1 - f; // if i is even
  }
  m = v * (1 - s);
  n = v * (1 - s * f);
  switch (i) {
  case 6:
  case 0:
    return long(v * 255 ) * 65536 + long( n * 255 ) * 256 + long( m * 255);
  case 1:
    return long(n * 255 ) * 65536 + long( v * 255 ) * 256 + long( m * 255);
  case 2:
    return long(m * 255 ) * 65536 + long( v * 255 ) * 256 + long( n * 255);
  case 3:
    return long(m * 255 ) * 65536 + long( n * 255 ) * 256 + long( v * 255);
  case 4:
    return long(n * 255 ) * 65536 + long( m * 255 ) * 256 + long( v * 255);
  case 5:
    return long(v * 255 ) * 65536 + long( m * 255 ) * 256 + long( n * 255);
  }
}
