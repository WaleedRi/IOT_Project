#include <HardwareSerial.h>
#include <Adafruit_NeoPixel.h>

#include <SPI.h>
#include <TFT_eSPI.h>
#include <XPT2046_Touchscreen.h>

TFT_eSPI tft = TFT_eSPI();

// Touchscreen pins
#define XPT2046_IRQ 25   // T_IRQ
#define XPT2046_MOSI 32  // T_DIN
#define XPT2046_MISO 26  // T_OUT
#define XPT2046_CLK 27   // T_CLK
#define XPT2046_CS 33    // T_CS


#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 240
#define FONT_SIZE 2

int x, y, z;


SPIClass touchscreenSPI = SPIClass(VSPI);
XPT2046_Touchscreen touchscreen(XPT2046_CS, XPT2046_IRQ);


// Pins and settings for buttons, LEDs, and NeoPixel
#define BUTTON1_PIN 5
#define BUTTON2_PIN 18
#define BUTTON3_PIN 19
#define BUTTON4_PIN 22
#define BUTTON5_PIN 23
//#define LED1_PIN 5
//#define LED2_PIN 18
//#define LED3_PIN 19
//#define LED4_PIN 18
//#define LED5_PIN 22
#define PIN_NEO_PIXEL 4
#define NUMPIXELS 5

unsigned long buttons_pins[] = {BUTTON1_PIN, BUTTON2_PIN, BUTTON3_PIN, BUTTON4_PIN, BUTTON5_PIN};
//unsigned long leds_pins[] = {LED1_PIN, LED2_PIN, LED3_PIN, LED4_PIN, LED5_PIN};
int randomized_buttons[NUMPIXELS];

// Define colors for NeoPixel corresponding to buttons
uint32_t colors[] = {
    0xFFFF00,  // Yellow
 //   0x000000, // Black
    0x0000FF, // Blue
 //   0x8B4513, // Brown
    0x00FF00, // Green
 //   0xFFA500, // Orange
 //   0xFFC0CB, // Pink
    0xFF0000,
    0x800080 // Purple
     // Red
 //    0xFFFFFF // White
    
};

// MP3 player communication pins and commands
HardwareSerial MP3(2);
static byte start_byte = 0x7E;  // Start byte
static byte end_byte = 0xEF;    // End byte
static byte set_volume_CMD = 0x31;
static byte play_filename_CMD = 0x42;
static int8_t select_SD_CMD[] = { 0x7e, 0x03, 0X35, 0x01, 0xef };
static int8_t reset_CMD[] = { 0x7e, 0x03, 0X35, 0x05, 0xef };

// NeoPixel settings
Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUMPIXELS*16, PIN_NEO_PIXEL, NEO_GRB + NEO_KHZ800);

// Helper Functions
void shuffleArray(int arr[], int n) {
    srand(time(NULL));
    for (int i = n - 1; i > 0; i--) {
        int j = rand() % (i + 1);
        int temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }
}

void randomizeButtons() {
    for (int i = 0; i < NUMPIXELS; i++) {
        randomized_buttons[i] = i;
    }
    shuffleArray(randomized_buttons, NUMPIXELS);
}

// MP3 Helper Functions
void playcolorsound(int8_t directory, int8_t file) {
    Serial.print("Playing directory ");
    Serial.print(directory);
    Serial.print(" file number ");
    Serial.println(file);
    MP3.write(start_byte);
    byte msg_len = 0x04;
    MP3.write(msg_len);
    MP3.write(play_filename_CMD);
    byte dir_ind = directory;
    MP3.write(dir_ind);
    byte file_ind = file;
    MP3.write(file_ind);
    MP3.write(end_byte);
    delay(20);  // required for stability
}

void selectSDCard() {
    for (int i = 0; i < 5; i++) {
        MP3.write(select_SD_CMD[i]);
    }
}

bool resetMP3() {
    MP3.flush();
    for (int i = 0; i < 5; i++) {
        MP3.write(reset_CMD[i]);
    }
    delay(50);
    return MP3.available();
}

void setVolume(byte volume) {
    MP3.write(start_byte);
    MP3.write(0x03);
    MP3.write(set_volume_CMD);
    MP3.write(volume);
    MP3.write(end_byte);
    delay(20);
}

// Game Logic Functions
void generateSequence(int sequence[], int length) {
    for (int i = 0; i < length; i++) {
        //sequence[i] = random(0, 5); // Generate sequence indices  
       sequence[i] = i;
    }
    shuffleArray(sequence, NUMPIXELS);
}

void playSequence(const int sequence[], int length) {

    for (int i = 0; i < length; i++) {
        delay(1500);
        playcolorsound(1, sequence[i]); // Play corresponding MP3 file
    //    strip.setPixelColor(i, colors[sequence[i]]); // Light up NeoPixel
    //    strip.show();
    //    digitalWrite(leds_pins[randomized_buttons[i]], HIGH); // Turn on corresponding LED
    }
   // strip.show(); // Keep all NeoPixels on
}

void setAllPixelsColor(uint32_t color) {
    for (int i = 0; i < 16*NUMPIXELS; i++) {
        strip.setPixelColor(i, color);
    }
    strip.show();
}

// Setup Function
void setup() {
    Serial.begin(9600);

     // Start the SPI for the touchscreen and init the touchscreen
  touchscreenSPI.begin(XPT2046_CLK, XPT2046_MISO, XPT2046_MOSI, XPT2046_CS);
  touchscreen.begin(touchscreenSPI);
  // Set the Touchscreen rotation in landscape mode
  // Note: in some displays, the touchscreen might be upside down, so you might need to set the rotation to 3: touchscreen.setRotation(3);
  touchscreen.setRotation(1);

  // Start the tft display
  tft.init();
  // Set the TFT display rotation in landscape mode
  tft.setRotation(1);
  
  // Clear the screen before writing to it
  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
        int centerX = SCREEN_WIDTH / 2;
  int centerY = SCREEN_HEIGHT / 2;
  tft.setTextSize(2);
   while (!(touchscreen.tirqTouched() && touchscreen.touched())) {
    tft.drawCentreString("touch the screen to start!", centerX, centerY, FONT_SIZE);
    
   }
    tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
   delay(1000);
  tft.drawCentreString("listen carefully!", centerX, centerY, FONT_SIZE);
    // Initialize MP3 player
    MP3.begin(9600, SERIAL_8N1, 17, 16);
    if (resetMP3()) {
        Serial.println("MP3 reset successful");
    } else {
        Serial.println("MP3 reset failed");
    }
    selectSDCard();
    setVolume(25);

    // Initialize NeoPixel
    strip.begin();
       for (int i = 0; i < 16*NUMPIXELS; i++) {
        strip.setPixelColor(i, colors[i/16]); // Light up NeoPixel
      //  digitalWrite(leds_pins[randomized_buttons[i]], HIGH);
     //   strip.show();
  // Turn on corresponding LED
    }
     strip.show();
    

    // Initialize buttons and LEDs
    for (int i = 0; i < NUMPIXELS; i++) {
        pinMode(buttons_pins[i], INPUT_PULLUP);
     //   pinMode(leds_pins[i], OUTPUT);
     //   digitalWrite(leds_pins[i], LOW);
    }

    // Randomize button-to-sequence mapping
    randomizeButtons();

    // Generate and play the initial sequence
    int sequence[NUMPIXELS];
    generateSequence(sequence, NUMPIXELS);
    playSequence(sequence, NUMPIXELS);
     tft.drawCentreString("start play!", centerX, centerY, FONT_SIZE);
}

// Loop Function
void loop() {
    int userSequence[NUMPIXELS];
    int currentStep = 0;
    bool gameFailed = false;

    while (currentStep < NUMPIXELS && !gameFailed) {
        for (int i = 0; i < NUMPIXELS; i++) {
            if (digitalRead(buttons_pins[randomized_buttons[i]]) == LOW) {
                userSequence[currentStep] = i;
              //  digitalWrite(leds_pins[randomized_buttons[i]], HIGH); // Turn on corresponding LED

                if (userSequence[currentStep] != currentStep) {
                    gameFailed = true;
                    break;
                }
                currentStep++;
                delay(500); // Debounce delay
              //  digitalWrite(leds_pins[randomized_buttons[i]], LOW); // Turn off LED
               for (int j = 0; j < 16; j++) {
                  //  strip.setPixelColor(i, colors[i/16]);
                    strip.setPixelColor(16*randomized_buttons[i]+j, 0x000000);
                 
               }
                 strip.show();
                 delay(1000);
                for (int j = 0; j < 16; j++) {
                    strip.setPixelColor(16*randomized_buttons[i]+j, colors[randomized_buttons[i]]); 
                 }
                 strip.show();
                    
            }
        }
    }
      int centerX = SCREEN_WIDTH / 2;
  int centerY = SCREEN_HEIGHT / 2;

  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
  tft.setTextSize(3);
    if (gameFailed) {
        Serial.println("Game Over!");
        setAllPixelsColor(0xFF0000); // Turn all NeoPixels red
         tft.drawCentreString("Game Over!", centerX, centerY, FONT_SIZE);
        for (int i = 0; i < NUMPIXELS; i++) {
          //  digitalWrite(leds_pins[i], HIGH); // Turn on all LEDs
        }
    } else {
        Serial.println("You Win!");
        setAllPixelsColor(0x00FF00); // Turn all NeoPixels green
         tft.drawCentreString("You Win!", centerX, centerY, FONT_SIZE);
        for (int i = 0; i < NUMPIXELS; i++) {
         //   digitalWrite(leds_pins[i], HIGH); // Turn on all LEDs
        }
    }

    delay(3000);

    // Turn off all LEDs before restarting
    for (int i = 0; i < NUMPIXELS; i++) {
    //    digitalWrite(leds_pins[i], LOW);
    }

    setup(); // Restart the game
}
