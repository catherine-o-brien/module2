/**
 * Simple Read
 * 
 * Slightly Modified from the Serial Example provided through the Ardunio IDE
 *
 * Read data from the serial port and change the color of a rectangle
 * when a switch connected to a Wiring or Arduino board is pressed and released.
 * This example works with the Wiring / Arduino program that follows below.
 */


import processing.serial.*;
import processing.pdf.*;

int X_MAX = 1900;
int X_MIN = 1700;
int Y_MAX = 1900;
int Y_MIN = 1700;
int current_image_index;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port

int x_val;
int y_val;
int z_val;
int button_val;

float x = 0.0;
float y = 0.0; 
PImage img;
ArrayList<setImage> setImages = new ArrayList<setImage>();
ArrayList<PImage> images = new ArrayList<PImage>();

class setImage { 
  float x_coor, y_coor; 
  PImage img;
  setImage (float x, float y, PImage i) {  
    x_coor = x; 
    y_coor = y;
    img = i;
  } 
} 

void setup() 
{
  size(800, 800);
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  String portName = Serial.list()[2];
  System.out.println(portName);
  myPort = new Serial(this, portName, 115200);
  System.out.println(myPort.available());
  initializeImages();
  getNextImage();
  
  //the first 3 runs of the joystick sometimes return wonky data
  //so running getCoordinates() 3x here skips the wonky joystick data
  getCoordinates(); getCoordinates(); getCoordinates(); 
}

//These photos must be in the same directory as this file. 
void initializeImages(){
  PImage img1 = loadImage("y_veras.jpg");
  img1.resize(1000, 0);
  images.add(img1);
  PImage img2 = loadImage("bienvenida.png");
  images.add(img2);
  PImage img3 = loadImage("church.png");
  images.add(img3);
  PImage img4 = loadImage("croissant.png");
  images.add(img4);
  PImage img5 = loadImage("dear_blank.png");
  images.add(img5);
  PImage img6 = loadImage("food.png");
  images.add(img6);
  PImage img7 = loadImage("fulanditas.jpg");
  images.add(img7);
  PImage img8 = loadImage("grace_drink.png");
  images.add(img8);
  PImage img9 = loadImage("grace_with_sandwich.png");
  images.add(img9);
  PImage img10 = loadImage("grace.png");
  images.add(img10);
  PImage img11 = loadImage("me.png");
  images.add(img11);
  PImage img12 = loadImage("metaverso.png");
  images.add(img12);
  PImage img13 = loadImage("museum.jpg");
  images.add(img13);
  PImage img14 = loadImage("no_somos.png");
  images.add(img14);
  PImage img15 = loadImage("picasso.png");
  images.add(img15);
  PImage img16 = loadImage("picasso.png");
  images.add(img16);
  PImage img17 = loadImage("ponche.png");
  images.add(img17);
  PImage img18 = loadImage("segovia-2.png");
  images.add(img18);
  PImage img19 = loadImage("segovia.png");
  images.add(img19);
  PImage img20 = loadImage("templo.png");
  images.add(img20);
  PImage img21 = loadImage("me.png");
  images.add(img21);
  PImage img22 = loadImage("water.png");
  images.add(img22);
  PImage img23 = loadImage("window.png");
  images.add(img23);
  
}

//TODO
void getNextImage() {
  //This should randomly choose an image from an array. It should not repeat images. 
  int index = int(random(0, images.size()));
  img = images.get(index);
  img.resize(400, 0);
  x = 0.0;
  y = 0.0; 
}

//Sets the x_val, y_val, z_val, and button_val from
//the current joystick and button inputs on the ESP-32
void getCoordinates() {
  if ( myPort.available() > 0) {
    val = myPort.readStringUntil('\n');
    if (val != null) {
      System.out.println(val);
      String[] coordinates = splitTokens(val);
      if (coordinates.length == 4) {
        x_val = int(coordinates[0]);
        y_val = int(coordinates[1]);
        z_val = int(coordinates[2]);
        button_val = int(coordinates[3]);
      }
    }
  }
}

//TODO
void loadPreviousImages() {
  for (setImage i : setImages) {
    image(i.img, i.x_coor, i.y_coor);
  }
}

void placeImage() {
  setImages.add(new setImage(x, y, img));
  getNextImage();
}

void moveImage() {
  if (x_val > X_MAX) { //pos horizontal translation
    x = x + 5 < width ? x + 5 : width;
  }
  if (x_val < X_MIN) { //neg horizontal translation
    x = x - 5 > (0 - img.width) ? x - 5 : (0 - img.width);
  }
  if (y_val > Y_MAX) { //pos vertical translation
    y = y + 5 < height ? y + 5 : height;
  }
  if (y_val < Y_MIN) { //neg vertical translation
    y = y - 5 > (0 - img.width) ? y - 5 : (0 - img.width);
  }
}

void finish() {
  System.out.println("Exiting program.");
  exit();
}

void draw()
{
  getCoordinates();                    // Get joystick and button info
  background(255);                     // Set background to white
  loadPreviousImages();               // Place all previously set images
  
  if (button_val == 0) {
    placeImage();
    while (button_val == 0) {               //waits for the button to be unpressed to prevent multiple reads of the same click
      getCoordinates();
      if (z_val == 0) {
         finish();
      }
    }
  }
  if (z_val == 0) {
    getNextImage();
    while (z_val == 0) {            //waits for the button to be unpressed to prevent multiple reads of the same click
      getCoordinates();
      if (button_val == 0) {
        finish();
      }
    }
  }
  moveImage();
  image(img, x, y);
}



/*

// Wiring / Arduino Code
// Slightly modified from the freenove joystick example

  Filename    : Joystick
  Description : Read data from joystick.
  Auther      : www.freenove.com
  Modification: 2022/04/01

#define PIN_BUTTON 22
int xyzPins[] = {36, 37, 2};

void setup() {
  Serial.begin(115200);
  pinMode(xyzPins[2], INPUT_PULLUP);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
}

void loop() {
  int xVal = analogRead(xyzPins[0]);
  int yVal = analogRead(xyzPins[1]);
  int zVal = digitalRead(xyzPins[2]);
  int buttonVal = (digitalRead(PIN_BUTTON) == HIGH);
  Serial.printf("%d\t%d\t%d\t%d\n", xVal, yVal, zVal, buttonVal);
  delay(500);
}

*/
