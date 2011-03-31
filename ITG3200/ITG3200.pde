#include <Wire.h>

//ITG-3200 Register Map
//Interrupt Enable/Interrupt Map/Interrupt Source Register Bits
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


#define ITG_ADDR	(0xD0 >> 1) //0xD0 if tied low, 0xD2 if tied high

#define WHO_AM_I	0x00
#define SMPLRT_DIV	0x15
#define	DLPF_FS		0x16
#define INT_CFG		0x17
#define INT_STATUS	0x1A
#define	TEMP_OUT_H	0x1B
#define	TEMP_OUT_L	0x1C
#define GYRO_XOUT_H	0x1D
#define	GYRO_XOUT_L	0x1E
#define GYRO_YOUT_H	0x1F
#define GYRO_YOUT_L	0x20
#define GYRO_ZOUT_H	0x21
#define GYRO_ZOUT_L	0x22
#define	PWR_MGM		0x3E

//Sample Rate Divider
//Fsample = Fint / (divider + 1) where Fint is either 1kHz or 8kHz
//Fint is set to 1kHz
//Set divider to 9 for 100 Hz sample rate

//DLPF, Full Scale Register Bits
//FS_SEL must be set to 3 for proper operation
//Set DLPF_CFG to 3 for 1kHz Fint and 42 Hz Low Pass Filter
#define DLPF_CFG_0	(1<<0)
#define DLPF_CFG_1	(1<<1)
#define DLPF_CFG_2	(1<<2)
#define DLPF_FS_SEL_0	(1<<3)
#define DLPF_FS_SEL_1	(1<<4)

//Power Management Register Bits
//Recommended to set CLK_SEL to 1,2 or 3 at startup for more stable clock
#define PWR_MGM_CLK_SEL_0	(1<<0)
#define PWR_MGM_CLK_SEL_1	(1<<1)
#define PWR_MGM_CLK_SEL_2	(1<<2)
#define PWR_MGM_STBY_Z	(1<<3)
#define PWR_MGM_STBY_Y	(1<<4)
#define PWR_MGM_STBY_X	(1<<5)
#define PWR_MGM_SLEEP	(1<<6)
#define PWR_MGM_H_RESET	(1<<7)

//Interrupt Configuration Bist
#define INT_CFG_ACTL	(1<<7)
#define INT_CFG_OPEN	(1<<6)
#define INT_CFG_LATCH_INT_EN	(1<<5)
#define INT_CFG_INT_ANYRD	(1<<4)
#define INT_CFG_ITG_RDY_EN	(1<<2)
#define INT_CFG_RAW_RDY_EN	(1<<0)

int sda = 9;
int scl = 5;

void setup() 
{ 
  // prints title with ending line break 
  Wire.begin(sda, scl);
  SerialUSB.begin(); 
  Serial1.begin(9600);
  setupITG();
} 

int setupITG() {
  
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(DLPF_FS);
  Wire.send(DLPF_FS_SEL_0|DLPF_FS_SEL_1|DLPF_CFG_0);
  Wire.endTransmission();
  delay(5);
  
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(SMPLRT_DIV);
  Wire.send(9);
  Wire.endTransmission();  
  
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(INT_CFG);
  Wire.send(INT_CFG_RAW_RDY_EN | INT_CFG_ITG_RDY_EN);
  Wire.endTransmission();  


  Wire.beginTransmission(ITG_ADDR);
  Wire.send(PWR_MGM);
  Wire.send(PWR_MGM_CLK_SEL_0);
  Wire.endTransmission();    
}


int readX() {
  int data = 0;
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(GYRO_XOUT_L);
  Wire.requestFrom(ITG_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive();
  }
  Wire.endTransmission();
  
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(GYRO_XOUT_H);
  Wire.requestFrom(ITG_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive() << 8;
  }
  Wire.endTransmission();

  return data;  
  
}

int readY() {
  int data = 0;
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(GYRO_YOUT_L);
  Wire.requestFrom(ITG_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive();
  }
  Wire.endTransmission();
  
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(GYRO_YOUT_H);
  Wire.requestFrom(ITG_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive() << 8;
  }
  Wire.endTransmission();

  return data;  
  
}

int readZ() {
  int data = 0;
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(GYRO_ZOUT_L);
  Wire.requestFrom(ITG_ADDR, 1);
  if (Wire.available()) {
    data = Wire.receive();
  }
  Wire.endTransmission();
  
  Wire.beginTransmission(ITG_ADDR);
  Wire.send(GYRO_ZOUT_H);
  Wire.requestFrom(ITG_ADDR, 1);
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
  Serial1.print(";");
  printNeg(yval);
  SerialUSB.print(";");  
  Serial1.print(";");
  printNeg(zval);  
  SerialUSB.println();
  Serial1.println();
} 

void printNeg (int val) {
    if (val > 32768) {  
    SerialUSB.print('-');
    Serial1.print('-');
    SerialUSB.print(65536-val);
    Serial1.print(65536-val);
  } else {
    SerialUSB.print(val);
    Serial1.print(val);
  }
}
  

