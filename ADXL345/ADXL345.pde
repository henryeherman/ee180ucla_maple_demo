#include <Wire.h>

/* ADXL Defines */
#define ADXL_ADDR	(0xA6 >> 1)
//ADXL Register Map
#define	DEVID			0x00	//Device ID Register
#define THRESH_TAP		0x1D	//Tap Threshold
#define	OFSX			0x1E	//X-axis offset
#define	OFSY			0x1F	//Y-axis offset
#define	OFSZ			0x20	//Z-axis offset
#define	DUR				0x21	//Tap Duration
#define	Latent			0x22	//Tap latency
#define	Window			0x23	//Tap window
#define	THRESH_ACT		0x24	//Activity Threshold
#define	THRESH_INACT	0x25	//Inactivity Threshold
#define	TIME_INACT		0x26	//Inactivity Time
#define	ACT_INACT_CTL	0x27	//Axis enable control for activity and inactivity detection
#define	THRESH_FF		0x28	//free-fall threshold
#define	TIME_FF			0x29	//Free-Fall Time
#define	TAP_AXES		0x2A	//Axis control for tap/double tap
#define ACT_TAP_STATUS	0x2B	//Source of tap/double tap
#define	BW_RATE			0x2C	//Data rate and power mode control
#define POWER_CTL		0x2D	//Power Control Register
#define	INT_ENABLE		0x2E	//Interrupt Enable Control
#define	INT_MAP			0x2F	//Interrupt Mapping Control
#define	INT_SOURCE		0x30	//Source of interrupts
#define	DATA_FORMAT		0x31	//Data format control
#define DATAX0			0x32	//X-Axis Data 0
#define DATAX1			0x33	//X-Axis Data 1
#define DATAY0			0x34	//Y-Axis Data 0
#define DATAY1			0x35	//Y-Axis Data 1
#define DATAZ0			0x36	//Z-Axis Data 0
#define DATAZ1			0x37	//Z-Axis Data 1
#define	FIFO_CTL		0x38	//FIFO control
#define	FIFO_STATUS		0x39	//FIFO status
//Power Control Register Bits
#define WU_0		(1<<0)	//Wake Up Mode - Bit 0
#define	WU_1		(1<<1)	//Wake Up mode - Bit 1
#define SLEEP		(1<<2)	//Sleep Mode
#define	MEASURE		(1<<3)	//Measurement Mode
#define AUTO_SLP	(1<<4)	//Auto Sleep Mode bit
#define LINK		(1<<5)	//Link bit
#define	OVERRUN		(1<<0)
#define	WATERMARK	(1<<1)
#define FREE_FALL	(1<<2)
#define	INACTIVITY	(1<<3)
#define	ACTIVITY	(1<<4)
#define DOUBLE_TAP	(1<<5)
#define	SINGLE_TAP	(1<<6)
#define	DATA_READY	(1<<7)

//Data Format Bits
#define RANGE_0		(1<<0)
#define	RANGE_1		(1<<1)
#define JUSTIFY		(1<<2)
#define	FULL_RES	(1<<3)

#define	INT_INVERT	(1<<5)
#define	SPI		(1<<6)
#define	SELF_TEST	(1<<7)


int sda = 9;
int scl = 5;

void setup() 
{ 
  // prints title with ending line break 
  Wire.begin(sda, scl);
  SerialUSB.begin(); 
  setupADXL();
} 

int setupADXL() {
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(POWER_CTL);
  Wire.send(MEASURE);
  Wire.endTransmission();
  delay(5);
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(DATA_FORMAT);
  Wire.send(RANGE_0);
  Wire.endTransmission();  
}


int readX() {
  int data = 0;
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(DATAX0);
  Wire.requestFrom(ADXL_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive();
  }
  Wire.endTransmission();
  
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(DATAX1);
  Wire.requestFrom(ADXL_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive() << 8;
  }
  Wire.endTransmission();

  return data;  
  
}

int readY() {
  int data = 0;
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(DATAY0);
  Wire.requestFrom(ADXL_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive();
  }
  Wire.endTransmission();
  
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(DATAY1);
  Wire.requestFrom(ADXL_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive() << 8;
  }
  Wire.endTransmission();

  return data;  
  
}

int readZ() {
  int data = 0;
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(DATAZ0);
  Wire.requestFrom(ADXL_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive();
  }
  Wire.endTransmission();
  
  Wire.beginTransmission(ADXL_ADDR);
  Wire.send(DATAZ1);
  Wire.requestFrom(ADXL_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive() << 8;
  }
  Wire.endTransmission();

  return data;  
  
}

void loop() 
{  
  int xval = 0;
  int yval = 0;
  int zval = 0;
  
  delay(200);
  xval = readX();
  yval = readY();
  zval = readZ();

  printNeg(xval);
  SerialUSB.print(";");
  printNeg(yval);
  SerialUSB.print(";");  
  printNeg(zval);  
  SerialUSB.println();
} 

void printNeg (int val) {
    if (val > 32768) {  
    SerialUSB.print('-');
    SerialUSB.print(65536-val);
  } else {
    SerialUSB.print(val);
  }
}
  

