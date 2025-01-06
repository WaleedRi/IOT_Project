#include <WiFi.h>
//#include <ESPAsyncWebServer.h>
#include <ESPmDNS.h>

#include <WebServer.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>


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
#define PIN_NEO_PIXEL 4
#define NUMPIXELS 5

unsigned long buttons_pins[] = {BUTTON1_PIN, BUTTON2_PIN, BUTTON3_PIN, BUTTON4_PIN, BUTTON5_PIN};
int randomized_buttons[NUMPIXELS];

// Define colors for NeoPixel corresponding to buttons
uint32_t colors[] = {
    0xFFFF00,  // Yellow
    0x0000FF, // Blue
    0x00FF00, // Green
    0xFF0000,
    0x800080 // Purple
     // Red
    
}; 
// AP credentials for initial setup
const char *ap_ssid = "ESP_AP";
const char *ap_password = "12345678";


// Wi-Fi credentials
String ssid = "";
String password = "";


String patientName = "";
String testName = "";


// Firebase credentials
const char* firebaseHost = "https://firestore.googleapis.com/v1/projects/rehapp-friend-mz7n9x/databases/(default)/documents";
const char* apiKey = "AIzaSyBTDKStXY2imG-zGx91OU1Vn1ATgkRn1tg";

// User credentials for authentication
const char* email = "rehappfriend.iot@gmail.com";
const char* passwordAuth = "RehappFriendIOT12";

String idToken = ""; // Bearer token for authenticated requests
//AsyncWebServer server(80);

WebServer server(80);


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
    delay(1500);
   // strip.show(); // Keep all NeoPixels on
}

void setAllPixelsColor(uint32_t color) {
    for (int i = 0; i < 16*NUMPIXELS; i++) {
        strip.setPixelColor(i, color);
    }
    strip.show();
}


String getIdToken() {
  HTTPClient http;
  String url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + String(apiKey);

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  // Create JSON payload for authentication
  StaticJsonDocument<200> doc;
  doc["email"] = email;
  doc["password"] = passwordAuth;
  doc["returnSecureToken"] = true;
  String payload;
  serializeJson(doc, payload);

  int httpCode = http.POST(payload);
  if (httpCode == HTTP_CODE_OK) {
    String response = http.getString();
    deserializeJson(doc, response);
    http.end();
    return doc["idToken"].as<String>();
  } else {
    Serial.print("Failed to authenticate. HTTP Code: ");
    Serial.println(httpCode);
    Serial.println(http.getString());
    http.end();
    return "";
  }
}

int getLastTestNumber(String patientName, String testName) {
  if (idToken == "") {
    Serial.println("Error: ID token is empty. Ensure you are authenticated.");
    return 0;
  }

  HTTPClient http;
  String url = String(firebaseHost) + "/patients/" + patientName + "/results/" + testName + "?access_token=" + idToken;

  http.begin(url);
  int httpCode = http.GET();
  int lastTestNumber = 0;

  if (httpCode == HTTP_CODE_OK) {
    String response = http.getString();
    StaticJsonDocument<1024> doc;
    DeserializationError error = deserializeJson(doc, response);

    if (!error) {
      JsonObject fields = doc["fields"];
      for (JsonPair kv : fields) {
        String fieldName = kv.key().c_str();
        if (fieldName.startsWith("Test")) {
          int testNumber = fieldName.substring(4).toInt();
          if (testNumber > lastTestNumber) {
            lastTestNumber = testNumber;
          }
        }
      }
    } else {
      Serial.println("Error parsing JSON: ");
      Serial.println(error.c_str());
    }
  } else {
    Serial.print("Failed to retrieve document. HTTP Code: ");
    Serial.println(httpCode);
    Serial.println(http.getString());
  }

  http.end();
  return lastTestNumber;
}

void addTestField(String patientName, String testName, String newTestName, String value) {
  if (idToken == "") {
    Serial.println("Error: ID token is empty. Ensure you are authenticated.");
    return;
  }

  HTTPClient http;
  String url = String(firebaseHost) + "/patients/" + patientName + "/results/" + testName + "?updateMask.fieldPaths=" + newTestName + "&access_token=" + idToken;

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  // Create JSON payload for Firestore
  StaticJsonDocument<200> doc;
  doc["fields"][newTestName]["stringValue"] = value;
  String payload;
  serializeJson(doc, payload);

  Serial.println("PATCH URL: " + url); // Debugging
  Serial.println("Payload: " + payload); // Debugging

  int httpCode = http.PATCH(payload);
  if (httpCode == HTTP_CODE_OK) {
    Serial.println("New test field added successfully");
    Serial.println(http.getString());
  } else {
    Serial.print("Failed to add new test field. HTTP Code: ");
    Serial.println(httpCode);
    Serial.println(http.getString());
  }

  http.end();
}

void startTestHandler() {
    Serial.println("Start Test Request Received");
    // Call the existing setup() to restart the test sequence
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
  int counter=3;
  int NumberOfWins=0;
  while(counter!=0){
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
          tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
      tft.drawCentreString("start play!", centerX, centerY, FONT_SIZE);


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
    //    int centerX = SCREEN_WIDTH / 2;
    //int centerY = SCREEN_HEIGHT / 2;

    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.setTextSize(3);
      if (gameFailed) {
          Serial.println("Game Over!");
          setAllPixelsColor(0xFF0000); // Turn all NeoPixels red
          tft.drawCentreString("Game Over!", centerX, centerY, FONT_SIZE);
      } else {
          Serial.println("You Win!");
          setAllPixelsColor(0x00FF00); // Turn all NeoPixels green
          tft.drawCentreString("You Win!", centerX, centerY, FONT_SIZE);
          NumberOfWins=NumberOfWins+1;
      }

      delay(3000);
      setAllPixelsColor(0x000000);


      counter=counter-1;

  }
 // WiFi.softAPdisconnect(true);
  WiFi.begin(ssid.c_str(), password.c_str());
   while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("\nConnected to Wi-Fi");
  String data = "success tries " + String(NumberOfWins) + " from 3"; 
// Authenticate and get ID Token
  idToken = getIdToken();
  if (idToken == "") {
    Serial.println("Authentication failed");
    return;
  }

 

  // Get the last test number
  int lastTestNumber = getLastTestNumber(patientName, testName);
  int newTestNumber = lastTestNumber + 1;
  String newTestName = "Test" + String(newTestNumber);

  // Add the new test field
  addTestField(patientName, testName, newTestName, data);
}


 
void setup() {
    Serial.begin(9600);
    delay(1000);

    // Start ESP32 in AP mode for initial setup
    WiFi.softAP(ap_ssid, ap_password);
    Serial.println("Access Point Created: ESP_AP");
    Serial.print("AP IP Address: ");
    Serial.println(WiFi.softAPIP());

    // Define route for setting Wi-Fi credentials
    server.on("/setWifi", HTTP_POST, []() {
        if (server.hasArg("ssid") && server.hasArg("password")) {
            ssid = server.arg("ssid");
            password = server.arg("password");
            server.send(200, "text/plain", "Wi-Fi credentials received. Rebooting...");

            // Disconnect AP and connect to Wi-Fi
            WiFi.softAPdisconnect(true);
            WiFi.begin(ssid.c_str(), password.c_str());

            while (WiFi.status() != WL_CONNECTED) {
             delay(1000);
             Serial.print(".");
            }
            if (WiFi.status() == WL_CONNECTED) {
                Serial.println("\nConnected to Wi-Fi!");
                Serial.print("IP Address: ");
                Serial.println(WiFi.localIP());

                // Start mDNS
                if (!MDNS.begin("esp32")) {
                    Serial.println("Error starting mDNS");
                } else {
                    Serial.println("mDNS responder started. Access ESP32 at http://esp32.local");
                }
            } else {
                Serial.println("\nFailed to connect to Wi-Fi.");
            }
        } else {
            server.send(400, "text/plain", "Missing parameters.");
        }
    });

    // Define a route to handle the "start" command
    server.on("/start",HTTP_POST, []() {
        if (server.hasArg("patientName") && server.hasArg("testName")) {
            patientName = server.arg("patientName");
            testName = server.arg("testName");
            server.send(200, "text/plain", "Wi-Fi credentials received. Rebooting...");
        }else{
          server.send(400, "text/plain", "Missing parameters.");
        } 
        WiFi.disconnect(true);
        startTestHandler();
        server.send(200, "text/plain", "Command executed!");
    });

    server.begin();
    Serial.println("HTTP server started");
}

void loop() {
    server.handleClient();
    // Existing loop code...
    /*
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
*/
   // setup(); // Restart the game
}

