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
#include <Preferences.h>

// Touchscreen pins
#define XPT2046_IRQ 25   // T_IRQ
#define XPT2046_MOSI 32  // T_DIN
#define XPT2046_MISO 26  // T_OUT
#define XPT2046_CLK 27   // T_CLK
#define XPT2046_CS 33    // T_CS


#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 240
#define FONT_SIZE 2

// Touchscreen calibration values (modify if needed)
#define TOUCH_CS  8  // Touchscreen chip select pin (adjust based on wiring)
#define TFT_CS   10  // TFT chip select pin (adjust if different)
#define TOUCH_MIN_X 200
#define TOUCH_MAX_X 3800
#define TOUCH_MIN_Y 200
#define TOUCH_MAX_Y 3800

// Button positions
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 50

// Define true/false button positions
#define TRUE_BTN_X   70
#define TRUE_BTN_Y   200
#define FALSE_BTN_X  170
#define FALSE_BTN_Y  200

// Pins and settings for buttons, LEDs, and NeoPixel
#define BUTTON1_PIN 5
#define BUTTON2_PIN 18
#define BUTTON3_PIN 19
#define BUTTON4_PIN 22
#define BUTTON5_PIN 23
#define PIN_NEO_PIXEL 4
#define NUMPIXELS 5

int x, y, z;
int centerX = SCREEN_WIDTH / 2;
int centerY = SCREEN_HEIGHT / 2;

struct MathQuestion {
  int num1;
  int num2;
  char operation;
  int correctAnswer;
  int displayedAnswer;
};

TFT_eSPI tft = TFT_eSPI();
SPIClass touchscreenSPI = SPIClass(VSPI);
XPT2046_Touchscreen touchscreen(XPT2046_CS, XPT2046_IRQ);

unsigned long buttons_pins[] = {BUTTON1_PIN, BUTTON2_PIN, BUTTON3_PIN, BUTTON4_PIN, BUTTON5_PIN};
int randomized_buttons[NUMPIXELS];

// Reflex Game variables
unsigned long lightUpTime = 0;
unsigned long reactionTime = 0;
int activeButton = -1;
bool gameActive = false;

// Store reaction times
int reactionTimes[50];
int testCount = 0;

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


String patientId = "";
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
Preferences preferences;


struct LocalData{
  String patientId;
  String testName;
  String data;
};

struct DefaultWiFi{
  String ssid;
  String password;
};

// List of correct words
const char* foodWords[] = {
  "apple", "banana", "carrot", "orange", "tomato", "grapes", "cherry", "peach", "lemon", "mango"
};

const char* numbersWords[] = {
  "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
};
const char* complexWords[] = {
  "table", "curtain", "extension", "window", "television", "computer", "keyboard", "rehabilitation", "health", "officer"
};

#define NUM_WORDS (sizeof(foodWords) / sizeof(foodWords[0]))

struct WordQuestion {
  char displayedWord[15];  // Buffer for word storage
  bool isCorrect;
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

void ConnectToWIFI(){
  WiFi.begin(ssid.c_str(), password.c_str());
  int attempts=0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
      delay(500);
      Serial.print(".");
      attempts ++ ;
  }
}

void saveDataLocally(const LocalData& data) {
    preferences.begin("offline-data", false); // Open preferences in RW mode
    preferences.putBytes("data", &data,sizeof(data));
    preferences.end(); // Close preferences
}


bool loadDefaultWiFi() {
    preferences.begin("offline-data", true); // Open preferences in read-only mode
    DefaultWiFi recoveredData;
    size_t size = preferences.getBytes("wifi", &recoveredData, sizeof(recoveredData));
    preferences.end();
    Serial.print("Retrieved preferences");
    if (size != sizeof(recoveredData)) {
      tft.fillScreen(TFT_WHITE);
      tft.setTextColor(TFT_BLACK, TFT_WHITE);
      tft.setTextSize(2);
      tft.drawCentreString("No defualt Wifi exist", centerX, centerY, FONT_SIZE); 
        // Handle case where no valid data was retrieved
      memset(&recoveredData, 0, sizeof(recoveredData));
    }else{
      ssid = recoveredData.ssid;
      password = recoveredData.password;
      Serial.print("Retrieved Wifi data");
      ConnectToWIFI();
      delay(1000);
      tft.fillScreen(TFT_WHITE);
      tft.setTextColor(TFT_BLACK, TFT_WHITE);
      tft.setTextSize(2);
      Serial.print("Connected to Wifi");
      if (WiFi.status() == WL_CONNECTED) {
        tft.fillScreen(TFT_WHITE);
        tft.setTextColor(TFT_BLACK, TFT_WHITE);
        tft.setTextSize(2);
        tft.drawCentreString("Recovering Data...", centerX, centerY, FONT_SIZE); 
        loadStruct();
        delay(1000);
        tft.fillScreen(TFT_WHITE);
        tft.setTextColor(TFT_BLACK, TFT_WHITE);
        tft.setTextSize(2);
        tft.drawCentreString("Connected to " + ssid, centerX, centerY, FONT_SIZE); 
        return true;
      }
    }
    return false;
}


void loadStruct() {
    preferences.begin("offline-data", true); // Open preferences in read-only mode
    LocalData recoveredData;
    size_t size = preferences.getBytes("data", &recoveredData, sizeof(recoveredData));
    preferences.end();

    if (size != sizeof(recoveredData)) {
      tft.fillScreen(TFT_WHITE);
      tft.setTextColor(TFT_BLACK, TFT_WHITE);
      tft.setTextSize(2);
      tft.drawCentreString("No Data To Recover", centerX, centerY, FONT_SIZE); 
        // Handle case where no valid data was retrieved
      memset(&recoveredData, 0, sizeof(recoveredData));
    }else{
      patientId = recoveredData.patientId;
      testName = recoveredData.testName;
      SaveToFireStore(recoveredData.data);
      clearStruct();
      tft.fillScreen(TFT_WHITE);
      tft.setTextColor(TFT_BLACK, TFT_WHITE);
      tft.setTextSize(2);
      tft.drawCentreString("Data Recovered", centerX, centerY, FONT_SIZE); 
    }

  //  return recoveredData;
}

void clearStruct() {
    preferences.begin("offline-data", false);
    preferences.remove("data");
    preferences.end();
}

// Generate a random question
MathQuestion generateQuestion(int op) {
  MathQuestion q;
  q.num1 = random(1, 10);
  q.num2 = random(1, 10);
  //int op = random(0, 3); // 0:add, 1:sub, 2:mul, 3:div

  switch (op) {
    case 0:
      q.operation = '+';
      q.correctAnswer = q.num1 + q.num2;
      break;
    case 1:
      q.operation = '-';
      q.correctAnswer = q.num1 - q.num2;
      break;
    case 2:
      q.operation = '*';
      q.correctAnswer = q.num1 * q.num2;
      break;
  }

  // Randomly decide if the displayed answer is correct
  if (((int)random(0, 2) == 0)) {
    q.displayedAnswer = q.correctAnswer;
  } else {
    q.displayedAnswer = q.correctAnswer + random(-3, 4);
  }
  return q;
}

// Function to introduce an error in a given word
void introduceError(char* word) {
  int len = strlen(word);
  int errorType = random(0, 3); // 0: swap, 1: insert, 2: delete
  
  switch (errorType) {
    case 0:  // Swap two letters
      if (len > 1) {
        int i = random(0, len - 1);
        char temp = word[i];
        word[i] = word[i + 1];
        word[i + 1] = temp;
      }
      break;
      
    case 1:  // Insert a random letter
      if (len < 14) {
        int i = random(0, len);
        for (int j = len; j > i; j--) {
          word[j] = word[j - 1];
        }
        word[i] = 'a' + random(0, 26);
        word[len + 1] = '\0';
      }
      break;
      
    case 2:  // Delete a letter
      if (len > 1) {
        int i = random(0, len);
        for (int j = i; j < len - 1; j++) {
          word[j] = word[j + 1];
        }
        word[len - 1] = '\0';
      }
      break;
  }
}

// Generate a random word question
WordQuestion generateWordQuestion(int dictionary) {
  WordQuestion q;
  int index = int(random(0, NUM_WORDS));
  switch (dictionary) {
    case 0:  // Swap two letters
      strcpy(q.displayedWord, foodWords[index]);
      break;
    case 1: 
      strcpy(q.displayedWord, numbersWords[index]);
      break;
    case 2: 
      strcpy(q.displayedWord, complexWords[index]);
      break;
  }

  if (int(random(0, 2)) == 0) {
    q.isCorrect = true;
  } else {
    q.isCorrect = false;
    introduceError(q.displayedWord);
  }

  return q;
}

// Draw buttons
void drawButtons() {
  tft.fillRect(TRUE_BTN_X, TRUE_BTN_Y, BUTTON_WIDTH, BUTTON_HEIGHT, TFT_GREEN);
  tft.fillRect(FALSE_BTN_X, FALSE_BTN_Y, BUTTON_WIDTH, BUTTON_HEIGHT, TFT_RED);
  tft.setTextColor(TFT_WHITE);
  tft.setTextSize(2);
  tft.setCursor(TRUE_BTN_X + 30, TRUE_BTN_Y + 15);
  tft.print("TRUE");
  tft.setCursor(FALSE_BTN_X + 30, FALSE_BTN_Y + 15);
  tft.print("FALSE");
}

// Display the math question
void displayMathQuestion(MathQuestion q) {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE);
  tft.setTextSize(3);
  tft.setCursor(70, 80);
  tft.printf("%d %c %d = %d", q.num1, q.operation, q.num2, q.displayedAnswer);
  drawButtons();
}

// Display the word question
void displayWordQuestion(WordQuestion q) {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE);
  tft.setTextSize(3);
  tft.setCursor(70, 80);
  tft.print(q.displayedWord);
  drawButtons();
}

// Check if the touch is within button bounds
bool isButtonPressed(int x, int y, int btn_x, int btn_y, int btn_w, int btn_h) {
  return (x >= btn_x && x <= (btn_x + btn_w) && y >= btn_y && y <= (btn_y + btn_h));
}

// Convert raw touch coordinates to screen coordinates
void convertTouchCoordinates(int &x, int &y) {
  x = map(x, TOUCH_MIN_X, TOUCH_MAX_X, 0, SCREEN_WIDTH);
  y = map(y, TOUCH_MIN_Y, TOUCH_MAX_Y, 0, SCREEN_HEIGHT);
}

bool handleMathTouch(MathQuestion q, int &correctCount, int &incorrectCount) {
  bool result;
  bool Istouched=false;
  while (!(touchscreen.tirqTouched() && touchscreen.touched())){
    Serial.print("Waiting for answer...");
  }
  while (!Istouched) {
    TS_Point p = touchscreen.getPoint();
    int touchX = p.x;
    int touchY = p.y;

    convertTouchCoordinates(touchX, touchY);

    Serial.print("touch coordinates");
    Serial.println(touchX);
    Serial.println(touchY);
    // Determine if user pressed True or False
    if (isButtonPressed(touchX, touchY, TRUE_BTN_X, TRUE_BTN_Y, BUTTON_WIDTH, BUTTON_HEIGHT)) {
      Istouched = true;
      if (q.displayedAnswer == q.correctAnswer) {
        correctCount++;
        tft.fillScreen(TFT_GREEN);
        tft.setCursor(50, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Correct!");
        result = true;
      } else {
        incorrectCount++;
        tft.fillScreen(TFT_RED);
        tft.setCursor(70, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Wrong!");
        result = false;
      }
      delay(1000);
    } else if (isButtonPressed(touchX, touchY, FALSE_BTN_X, FALSE_BTN_Y, BUTTON_WIDTH, BUTTON_HEIGHT)) {
      Istouched = true;
      if (q.displayedAnswer != q.correctAnswer) {
        correctCount++;
        tft.fillScreen(TFT_GREEN);
        tft.setCursor(50, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Correct!");
        result = true;
      } else {
        incorrectCount++;
        tft.fillScreen(TFT_RED);
        tft.setCursor(70, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Wrong!");
        result = false;
      }
      delay(1000);
    }
  }
  return result;
}

bool handleReadingTouch(WordQuestion q, int &correctCount, int &incorrectCount) {
  bool result;
  bool Istouched=false;
  while (!(touchscreen.tirqTouched() && touchscreen.touched())){
    Serial.print("Waiting for answer...");
  }
  while (!Istouched) {
    TS_Point p = touchscreen.getPoint();
    int touchX = p.x;
    int touchY = p.y;

    convertTouchCoordinates(touchX, touchY);

    Serial.print("touch coordinates");
    Serial.println(touchX);
    Serial.println(touchY);
    // Determine if user pressed True or False
    if (isButtonPressed(touchX, touchY, TRUE_BTN_X, TRUE_BTN_Y, BUTTON_WIDTH, BUTTON_HEIGHT)) {
      Istouched = true;
      if (q.isCorrect) {
        correctCount++;
        tft.fillScreen(TFT_GREEN);
        tft.setCursor(50, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Correct!");
        result = true;
      } else {
        incorrectCount++;
        tft.fillScreen(TFT_RED);
        tft.setCursor(70, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Wrong!");
        result = false;
      }
      delay(1000);
    } else if (isButtonPressed(touchX, touchY, FALSE_BTN_X, FALSE_BTN_Y, BUTTON_WIDTH, BUTTON_HEIGHT)) {
      Istouched = true;
      if (!q.isCorrect) {
        correctCount++;
        tft.fillScreen(TFT_GREEN);
        tft.setCursor(50, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Correct!");
        result = true;
      } else {
        incorrectCount++;
        tft.fillScreen(TFT_RED);
        tft.setCursor(70, 120);
        tft.setTextColor(TFT_WHITE);
        tft.setTextSize(5);
        tft.print("Wrong!");
        result = false;
      }
      delay(1000);
    }
  }
  return result;
}

void displayResults(int correctCount, int incorrectCount) {
  tft.fillScreen(TFT_BLACK);
  tft.setTextSize(4);
  tft.setCursor(20, 80);
  tft.setTextColor(TFT_YELLOW);
  tft.printf("Correct: %d", correctCount);
  tft.setCursor(20, 160);
  tft.printf("Incorrect: %d", incorrectCount);
  delay(1000);
}

// Function to light up a random LED ring
void activateRandomRing() {
  // Turn off all LEDs first
  strip.clear();
  
  // Select a random ring
  activeButton = random(0, NUMPIXELS);

  // Light up the selected ring (each ring has 16 LEDs)
  int startIdx = activeButton * 16;
  for (int i = startIdx; i < startIdx + 16; i++) {
    strip.setPixelColor(i, strip.Color(0, 0, 255));  // Set red color
  }

  strip.show();
  lightUpTime = millis();
  gameActive = true;
  
  displayMessage("Press Button:", activeButton + 1);
}

// Function to check if the correct button is pressed
void checkButtonPress() {
  while(gameActive){
    for (int i = 0; i < NUMPIXELS; i++) {
      if (digitalRead(buttons_pins[i]) == HIGH) {
        if (i == activeButton && gameActive) {
          reactionTime = millis() - lightUpTime;
          reactionTimes[testCount++] = reactionTime;
          
          strip.clear();
          strip.show();
          gameActive = false;

          char resultMsg[30];
          sprintf(resultMsg, "Reaction: %d ms", reactionTime);
          displayMessage(resultMsg, -1);

          delay(1000);
          if (testCount < 50) {
            activateRandomRing();
          } else {
            showResults();
          }
        } else {
          displayMessage("Wrong button!", -1);
        }
      }
    }
  }
}

// Function to display results on the touchscreen
void showResults() {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE);
  tft.setTextSize(2);
  tft.setCursor(20, 30);
  tft.println("Test Completed!");
  
  tft.setTextSize(2);
  for (int i = 0; i < testCount; i++) {
    tft.setCursor(20, 50 + (i * 15));
    tft.printf("Attempt %d: %d ms\n", i + 1, reactionTimes[i]);
  }

  delay(5000);
  testCount = 0;
  //activateRandomRing();
}

// Function to display current score on touchscreen
void displayMessage(const char* message, int buttonNumber) {
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE);
  tft.setTextSize(3);
  tft.setCursor(30, 80);
  tft.print(message);
  
  if (buttonNumber != -1) {
    tft.setCursor(30, 120);
    tft.print("Button: ");
    tft.print(buttonNumber);
  }

  // Show current score
  tft.setTextSize(2);
  tft.setCursor(30, 180);
  tft.printf("Score: %d/%d", testCount, 50);
}


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

int getLastTestNumber(String patientId, String testName) {
  if (idToken == "") {
    Serial.println("Error: ID token is empty. Ensure you are authenticated.");
    return 0;
  }

  HTTPClient http;
  String url = String(firebaseHost) + "/patients/" + patientId + "/results/" + testName + "?access_token=" + idToken;

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
        if (fieldName.startsWith("test")) {
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

void addTestField(String patientId, String testName, String newTestName, String value,int newTestNumber) {
  if (idToken == "") {
    Serial.println("Error: ID token is empty. Ensure you are authenticated.");
    return;
  }

  HTTPClient http;
  String url = String(firebaseHost) + "/patients/" + patientId + "/results/" + testName +
               "?updateMask.fieldPaths=" + newTestName + "&updateMask.fieldPaths=tests_numbers&access_token=" + idToken;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  // Create JSON payload for Firestore
  StaticJsonDocument<200> doc;
  doc["fields"][newTestName]["stringValue"] = value;
  doc["fields"]["tests_numbers"]["integerValue"] = newTestNumber;

  String payload;
  serializeJson(doc, payload);

  Serial.println("PATCH URL: " + url); // Debugging
  Serial.println("Payload: " + payload); // Debugging

  int httpCode = http.PATCH(payload);
  if (httpCode == HTTP_CODE_OK) {
    tft.fillScreen(TFT_WHITE);
     tft.setTextColor(TFT_BLACK, TFT_WHITE);
     tft.setTextSize(2);
    tft.drawCentreString("Results Saved", centerX, centerY, FONT_SIZE); 
    Serial.println("New test field added successfully");
    Serial.println(http.getString());
  } else {
       tft.fillScreen(TFT_WHITE);
     tft.setTextColor(TFT_BLACK, TFT_WHITE);
     tft.setTextSize(2);
    tft.drawCentreString("Failed to Save Results", centerX, centerY, FONT_SIZE); 
    Serial.print("Failed to add new test field. HTTP Code: ");
    Serial.println(httpCode);
    Serial.println(http.getString());
  }

  http.end();
}




void SaveDefaultWiFILocally(const DefaultWiFi& data) {
    preferences.begin("offline-data", false); // Open preferences in RW mode
    preferences.putBytes("wifi", &data,sizeof(data));
    preferences.end(); // Close preferences
}

void SaveToLocalStorage(const LocalData& data){
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.setTextSize(2);
    tft.drawCentreString("WiFI Disconnected!", centerX, centerY, FONT_SIZE);
    saveDataLocally(data);
    delay(5000);
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.setTextSize(2);
    tft.drawCentreString("Saved Results locally", centerX, centerY, FONT_SIZE);
    delay(5000);
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.setTextSize(2);
    while (!(touchscreen.tirqTouched() && touchscreen.touched())) {
      tft.drawCentreString("Touch To Reset", centerX, centerY+10, FONT_SIZE);
    }
    setup();
}

void SaveToFireStore(String data){
      Serial.println("\nConnected to Wi-Fi!");
      Serial.print("IP Address: ");
      Serial.println(WiFi.localIP());
    // String data = "success tries " + String(NumberOfWins) + " from 3"; 

    // Authenticate and get ID Token
      idToken = getIdToken();
      if (idToken == "") {
        Serial.println("Authentication failed");
        return;
       }
      int lastTestNumber = getLastTestNumber(patientId, testName);
      int newTestNumber = lastTestNumber + 1;
      String newTestName = "test" + String(newTestNumber);
      // Add the new test field
      addTestField(patientId, testName, newTestName, data,newTestNumber);
      tft.fillScreen(TFT_WHITE);
        tft.setTextColor(TFT_BLACK, TFT_WHITE);
        tft.setTextSize(2);
      tft.drawCentreString(data, centerX, centerY, FONT_SIZE); 
      delay(5000);
      tft.fillScreen(TFT_WHITE);
        tft.setTextColor(TFT_BLACK, TFT_WHITE);
        tft.setTextSize(2);
        tft.drawCentreString("ready for a new test", centerX, centerY, FONT_SIZE); 
      
}

int PlayTheGameAndCalcResults(){
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
              if (userSequence[currentStep] != currentStep) {
                  gameFailed = true;
                  break;
              }
              currentStep++;
              delay(150); // Debounce delay
              for (int j = 0; j < 16; j++) {
                strip.setPixelColor(16*randomized_buttons[i]+j, 0x000000);
              }
              strip.show();
              delay(150);
              for (int j = 0; j < 16; j++) {
                  strip.setPixelColor(16*randomized_buttons[i]+j, colors[randomized_buttons[i]]); 
              }
              strip.show();     
          }
      }
  }
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
  }
  delay(3000);
  setAllPixelsColor(0x000000);
  return currentStep;
}


void startVisualTestHandler(){
  Serial.println("Start Test Request Received");
  int counter=0;
  int results[3] ;
  while(counter!=3){
    // Clear the screen before writing to it
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.setTextSize(2);
    // Start the SPI for the touchscreen and init the touchscreen
    while (!(touchscreen.tirqTouched() && touchscreen.touched())) {
      tft.drawCentreString("touch the screen", centerX, centerY-20, FONT_SIZE);
      tft.drawCentreString("to start!", centerX, centerY+10, FONT_SIZE);
    }
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    delay(1000);
    tft.drawCentreString("Watch carefully!", centerX, centerY, FONT_SIZE);
    // Initialize NeoPixel
    randomizeButtons();
    strip.begin();
    for (int i = 0; i < 5; i++) {
      setAllPixelsColor(colors[randomized_buttons[i]]);
      strip.show();
      delay(2000);
      setAllPixelsColor(0x000000);
      strip.show();
      delay(1000);
    }
    // Turn all NeoPixels green
    for (int i = 0; i < 16*NUMPIXELS; i++) {
      strip.setPixelColor(i, colors[i/16]); // Light up NeoPixel
      // Turn on corresponding LED
    }
    strip.show();
      
    // Initialize buttons and LEDs
    for (int i = 0; i < NUMPIXELS; i++) {
        pinMode(buttons_pins[i], INPUT_PULLUP);
    }
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.drawCentreString("start play!", centerX, centerY, FONT_SIZE);
    int correctclicks = 0;
    correctclicks =PlayTheGameAndCalcResults();
    results[counter]=correctclicks;
    counter=counter+1;
  }
  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
  tft.setTextSize(2);
  tft.drawCentreString("Saving results...", centerX, centerY, FONT_SIZE); 
  ConnectToWIFI();
  String data = String(results[0])+ "+" +String(results[1])+ "+" + String(results[2]); 
  if (WiFi.status() == WL_CONNECTED) {
    SaveToFireStore(data);
  }
  else{
    LocalData localdata = {patientId,testName,data};
    SaveToLocalStorage(localdata);
  }
}

void startTestHandler() {
    Serial.println("Start Test Request Received");
    int counter=0;
    int results[3] ;
    while(counter!=3){
      // Clear the screen before writing to it
      tft.fillScreen(TFT_WHITE);
      tft.setTextColor(TFT_BLACK, TFT_WHITE);
      tft.setTextSize(2);
      while (!(touchscreen.tirqTouched() && touchscreen.touched())) {
        tft.drawCentreString("touch the screen", centerX, centerY-20, FONT_SIZE);
        tft.drawCentreString("to start!", centerX, centerY+10, FONT_SIZE);
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
      setVolume(100);
      // Initialize NeoPixel
      strip.begin();
        for (int i = 0; i < 16*NUMPIXELS; i++) {
          strip.setPixelColor(i, colors[i/16]); // Light up NeoPixel
      }
      strip.show();
      // Initialize buttons and LEDs
      for (int i = 0; i < NUMPIXELS; i++) {
          pinMode(buttons_pins[i], INPUT_PULLUP);
      }

      // Randomize button-to-sequence mapping
      randomizeButtons();

      // Generate and play the initial sequence
      int sequence[NUMPIXELS];
      generateSequence(sequence, NUMPIXELS);
      playSequence(sequence, NUMPIXELS);

      int correctclicks = 0;
      correctclicks =PlayTheGameAndCalcResults();
      
      results[counter]=correctclicks;
      counter=counter+1;
    } 
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.setTextSize(2);
    tft.drawCentreString("Saving results...", centerX, centerY, FONT_SIZE); 
    ConnectToWIFI();
    String data = String(results[0])+ "+" +String(results[1])+ "+" + String(results[2]); 
    if (WiFi.status() == WL_CONNECTED) {
      SaveToFireStore(data);
    }
    else{
      LocalData localdata = {patientId,testName,data};
      SaveToLocalStorage(localdata);
    }
}

void startMathTest(){
  Serial.println("Start Math Test Request Received");
  // Call the existing setup() to restart the test sequence
  // Start the SPI for the touchscreen and init the touchscreen

  int counter=0;
  int NumberOfWins=0;
  int correctCount = 0;
  int incorrectCount = 0;
  bool currentResult;
  int results[3];

  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
  tft.setTextSize(2);
  while (!(touchscreen.tirqTouched() && touchscreen.touched())) {
    tft.drawCentreString("touch the screen", centerX, centerY-20, FONT_SIZE);
    tft.drawCentreString("to start!", centerX, centerY+10, FONT_SIZE);
  }
    tft.fillScreen(TFT_BLACK);
    tft.setTextColor(TFT_WHITE);
    tft.setTextSize(3);
    tft.setCursor(20, centerY);
    tft.print("Is this equation correct?");
    delay(2000);
  while(counter!=3){
    int currOpCount=0;
    results[counter] = 0;
    while(currOpCount != 5){
      // Clear the screen before writing to it
      // tft.fillScreen(TFT_WHITE);
      // tft.setTextColor(TFT_BLACK, TFT_WHITE);
      
      //tft.drawCentreString("Is this equation correct?", centerX, centerY-70, FONT_SIZE);
      
      MathQuestion question = generateQuestion(counter);
      displayMathQuestion(question);
      currentResult = handleMathTouch(question, correctCount, incorrectCount);
      if (currentResult){
        results[counter]++;
      }
      if (!currentResult) {
          Serial.println("Game Over!");
          setAllPixelsColor(0xFF0000); // Turn all NeoPixels red
          // tft.drawCentreString("Game Over!", centerX, centerY, FONT_SIZE);
      } else {
          Serial.println("You Win!");
          setAllPixelsColor(0x00FF00); // Turn all NeoPixels green
          // tft.drawCentreString("You Win!", centerX, centerY, FONT_SIZE);
          NumberOfWins=NumberOfWins+1;
      }
      displayResults(correctCount, incorrectCount);
      delay(3000);
      setAllPixelsColor(0x000000);
      currOpCount++;
    }
    // tft.fillScreen(TFT_WHITE);
    // tft.setTextColor(TFT_BLACK, TFT_WHITE);
    // tft.setTextSize(3);
    counter++;
  }
  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
  tft.setTextSize(2);
  tft.drawCentreString("Saving results...", centerX, centerY, FONT_SIZE); 
  ConnectToWIFI();
  String data = String(results[0])+ "+" +String(results[1])+ "+" + String(results[2]); 
  if (WiFi.status() == WL_CONNECTED) {
    SaveToFireStore(data);
  }
  else{
    LocalData localdata = {patientId,testName,data};
    SaveToLocalStorage(localdata);
  }
}

void startReflexTest(){
  Serial.println("Start Reflex Test Request Received");
  // Call the existing setup() to restart the test sequence
  // Start the SPI for the touchscreen and init the touchscreen
  // Initialize LED rings and buttons

  int counter=0;
  int NumberOfWins=0;
  int correctCount = 0;
  int incorrectCount = 0;
  bool currentResult;
  int results[3];
  
  strip.begin();
  strip.clear();
  strip.show();
  for (int i = 0; i < NUMPIXELS; i++) {  
    pinMode(buttons_pins[i], INPUT_PULLDOWN);
  }
  activateRandomRing();
  checkButtonPress();

  // while(counter!=3){
  //   // Clear the screen before writing to it
  //   tft.fillScreen(TFT_WHITE);
  //   tft.setTextColor(TFT_BLACK, TFT_WHITE);
  //   tft.setTextSize(2);
  //   while (!(touchscreen.tirqTouched() && touchscreen.touched())) {
  //     tft.drawCentreString("touch the screen", centerX, centerY-20, FONT_SIZE);
  //     tft.drawCentreString("to start!", centerX, centerY+10, FONT_SIZE);
  //   }
  //   tft.fillScreen(TFT_WHITE);
  //   tft.setTextColor(TFT_BLACK, TFT_WHITE);
  //   delay(1000);
  //   tft.drawCentreString("Answer the following question:", centerX, centerY-70, FONT_SIZE);
  //   MathQuestion question = generateQuestion();
  //   displayMathQuestion(question);

  //   currentResult = handleTouch(question, correctCount, incorrectCount);
  //   results[counter] = int(currentResult);
    
  //   delay(1000);
  //   displayResults(correctCount, incorrectCount);

  //   // tft.fillScreen(TFT_WHITE);
  //   // tft.setTextColor(TFT_BLACK, TFT_WHITE);
  //   // tft.setTextSize(3);
  //   if (!currentResult) {
  //       Serial.println("Game Over!");
  //       setAllPixelsColor(0xFF0000); // Turn all NeoPixels red
  //       // tft.drawCentreString("Game Over!", centerX, centerY, FONT_SIZE);
  //   } else {
  //       Serial.println("You Win!");
  //       setAllPixelsColor(0x00FF00); // Turn all NeoPixels green
  //       // tft.drawCentreString("You Win!", centerX, centerY, FONT_SIZE);
  //       NumberOfWins=NumberOfWins+1;
  //   }
  //   delay(3000);
  //   setAllPixelsColor(0x000000);

  //   counter++;
  // }
  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
  tft.setTextSize(2);
  tft.drawCentreString("Saving results...", centerX, centerY, FONT_SIZE); 
  ConnectToWIFI();
  String data = String(results[0])+ "+" +String(results[1])+ "+" + String(results[2]); 
  if (WiFi.status() == WL_CONNECTED) {
    SaveToFireStore(data);
  }
  else{
    LocalData localdata = {patientId,testName,data};
    SaveToLocalStorage(localdata);
  }
}

void startReadingTest(){
  Serial.println("Start Math Test Request Received");
  // Call the existing setup() to restart the test sequence
  // Start the SPI for the touchscreen and init the touchscreen

  int counter=0;
  int NumberOfWins=0;
  int correctCount = 0;
  int incorrectCount = 0;
  bool currentResult;
  int results[3];

  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
  tft.setTextSize(2);

  while (!(touchscreen.tirqTouched() && touchscreen.touched())) {
    tft.drawCentreString("touch the screen", centerX, centerY-20, FONT_SIZE);
    tft.drawCentreString("to start!", centerX, centerY+10, FONT_SIZE);
  }
  tft.fillScreen(TFT_BLACK);
  tft.setTextColor(TFT_WHITE);
  tft.setTextSize(3);
  tft.setCursor(20, centerY);
  tft.print("Is this a Word?");
  delay(2000);
  while(counter!=3){
    int currOpCount = 0;
    results[counter] = 0;
    while(currOpCount != 5){
      // Clear the screen before writing to it
      // tft.fillScreen(TFT_WHITE);
      // tft.setTextColor(TFT_BLACK, TFT_WHITE);
      // tft.setTextSize(2);

      WordQuestion question = generateWordQuestion(counter);
      displayWordQuestion(question);

      // unsigned long startTime = millis();
      // while (millis() - startTime < 10000) {  // Allow 10 seconds to answer
      //   handleTouch(question);
      // }

      currentResult = handleReadingTouch(question, correctCount, incorrectCount);
      if (currentResult){
        results[counter]++;
      }
      
      //delay(1000);

      // tft.fillScreen(TFT_WHITE);
      // tft.setTextColor(TFT_BLACK, TFT_WHITE);
      // tft.setTextSize(3);
      if (!currentResult) {
          Serial.println("Game Over!");
          setAllPixelsColor(0xFF0000); // Turn all NeoPixels red
          // tft.drawCentreString("Game Over!", centerX, centerY, FONT_SIZE);
      } else {
          Serial.println("You Win!");
          setAllPixelsColor(0x00FF00); // Turn all NeoPixels green
          // tft.drawCentreString("You Win!", centerX, centerY, FONT_SIZE);
          NumberOfWins=NumberOfWins+1;
      }
      displayResults(correctCount, incorrectCount);
      delay(2000);
      setAllPixelsColor(0x000000);
      currOpCount++;
    }
    counter++;
  }
  tft.fillScreen(TFT_WHITE);
  tft.setTextColor(TFT_BLACK, TFT_WHITE);
  tft.setTextSize(2);
  tft.drawCentreString("Saving results...", centerX, centerY, FONT_SIZE); 
  ConnectToWIFI();
  String data = String(results[0])+ "+" +String(results[1])+ "+" + String(results[2]); 
  if (WiFi.status() == WL_CONNECTED) {
    SaveToFireStore(data);
  }
  else{
    LocalData localdata = {patientId,testName,data};
    SaveToLocalStorage(localdata);
  }
}
 
void setup() {
  Serial.begin(9600);
  touchscreenSPI.begin(XPT2046_CLK, XPT2046_MISO, XPT2046_MOSI, XPT2046_CS);
  touchscreen.begin(touchscreenSPI);
  // Set the Touchscreen rotation in landscape mode
  // Note: in some displays, the touchscreen might be upside down, so you might need to set the rotation to 3: touchscreen.setRotation(3);
  touchscreen.setRotation(1);
  // Start the tft display
  tft.init();
  // Set the TFT display rotation in landscape mode
  tft.setRotation(1);
  randomSeed(millis());
  delay(1000);
  Serial.print("Loading deafults");
//try to connect to default wifi
  if (!loadDefaultWiFi()){
  // Start ESP32 in AP mode for initial setup
    WiFi.softAP(ap_ssid, ap_password);
    Serial.println("Access Point Created: ESP_AP");
    Serial.print("AP IP Address: ");
    Serial.println(WiFi.softAPIP());
    tft.fillScreen(TFT_WHITE);
    tft.setTextColor(TFT_BLACK, TFT_WHITE);
    tft.setTextSize(2);
    tft.drawCentreString("connect to ESP_AP", centerX, centerY-30, FONT_SIZE);
    tft.drawCentreString("then send your WIFI", centerX, centerY, FONT_SIZE); 
  
   delay(1000);
  // Define route for setting Wi-Fi credentials
  server.on("/setWifi", HTTP_POST, []() {
      if (server.hasArg("ssid") && server.hasArg("password")) {
          ssid = server.arg("ssid");
          password = server.arg("password");
          server.send(200, "text/plain", "Wi-Fi credentials received. Rebooting...");

          // Disconnect AP and connect to Wi-Fi
          WiFi.softAPdisconnect(true);
          tft.setTextColor(TFT_BLACK, TFT_WHITE);
          tft.setTextSize(2);
          tft.drawCentreString("trying to connect to", centerX, centerY, FONT_SIZE); 
          tft.drawCentreString("your WIFI...", centerX, 150, FONT_SIZE); 
          ConnectToWIFI();
          if (WiFi.status() == WL_CONNECTED) {
              Serial.println("\nConnected to Wi-Fi!" + ssid);
              Serial.print("IP Address: ");
              Serial.println(WiFi.localIP());
              DefaultWiFi defaultWiFi = {ssid,password};
              SaveDefaultWiFILocally(defaultWiFi);
              tft.fillScreen(TFT_WHITE);
              tft.setTextColor(TFT_BLACK, TFT_WHITE);
              tft.setTextSize(2);
              tft.drawCentreString("Recovering Data...", centerX, centerY, FONT_SIZE); 
              loadStruct();

              // Start mDNS
              if (!MDNS.begin("esp32")) {
                  Serial.println("Error starting mDNS");
              } else {
                  Serial.println("mDNS responder started. Access ESP32 at http://esp32.local");
                  tft.fillScreen(TFT_WHITE);
                  tft.setTextColor(TFT_BLACK, TFT_WHITE);
                  tft.setTextSize(2);
                  tft.drawCentreString("Connected to " + ssid, centerX, centerY, FONT_SIZE); 
              }
          } else {
              Serial.println("\nFailed to connect to Wi-Fi.");
                WiFi.softAP(ap_ssid, ap_password);
                tft.fillScreen(TFT_WHITE);
                tft.setTextColor(TFT_BLACK, TFT_WHITE);
                tft.setTextSize(2);
                tft.drawCentreString("connecting to WiFi Failed", centerX, 30, FONT_SIZE); 
                tft.drawCentreString("connect to ESP_AP", centerX, 70, FONT_SIZE);
                tft.drawCentreString("and try again", centerX, centerY, FONT_SIZE); 
          }
      } else {
          server.send(400, "text/plain", "Missing parameters.");
      }
  });
  }

  // Define a route to handle the "start" command
  server.on("/start",HTTP_POST, []() {
      if (server.hasArg("patientId") && server.hasArg("testName")) {
          patientId = server.arg("patientId");
          testName = server.arg("testName");
          server.send(200, "text/plain", "Wi-Fi credentials received. Rebooting...");
      }else{
        server.send(400, "text/plain", "Missing parameters.");
      } 
      WiFi.disconnect(true);
      setAllPixelsColor(0x000000);
      if(testName=="Auditory"){
        startTestHandler();
      }
      else if(testName=="Visual"){
        startVisualTestHandler();
      }
      else if(testName=="Basic_math"){
        startMathTest();
      }
      else if (testName=="Reading_text"){
        startReadingTest();
      }
      else if (testName=="Reflex"){
        startReflexTest();
      }
      server.send(200, "text/plain", "Command executed!");
  });

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
    server.handleClient();
}
