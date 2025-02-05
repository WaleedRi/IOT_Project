
## Rehabilitation Game by: Waleed Rinawi, Thaer Abu Tayeh, and Yaser Hegazi
Our project is an IOT device that is used to run various different tests on patients undergoing rehabilitation. These tests cover many different aspects of the
patient's senses and cognitive ability. For example, we have tests that include the use of auditory and visual interactions with the patients. The project also
includes an application by the name of Rehapp Friend which is used by the doctors of these patients in order to use the device. The application also provides the
doctors with many different graphs and statistics to help them monitor their patients' progress easily and efficiently.  

## Repo Folders Description

## Project Details

### Physical Device

### Android Application
The core idea of Rehapp Friend is to leverage IoT technology and a mobile application to enhance the rehabilitation process by providing comprehensive and real-time data to healthcare professionals, thereby improving patient outcomes and treatment efficiency.

## Main Pages

### 1. Authentication Pages
- **Login Screen**: Email/password authentication
- **Registration Screen**: Doctor registration with ID verification
- **Password Reset**: Recovery functionality

### 2. Patient Management
- **Patient List**: Overview of all patients
- **Patient Profile**: Detailed patient information
- **Add/Edit Patient**: Patient information management

### 3. Test Suite Pages
- **Test Selection Dashboard**: Overview of available tests
- **Test Execution Screens**: Individual test interfaces
- **Results View**: Immediate post-test results
- **Progress Tracking**: Historical performance charts

### 4. Administrative Pages
- **WiFi Setup**: ESP32 device configuration
- **Data Export**: CSV generation interface
- **Settings**: App configuration

## Test Descriptions

### 1. Auditory Memory Test
- **Purpose**: Evaluate auditory memory capacity
- **Method**: Play sequence of sounds for memorization
- **Scoring**: Based on correct sequence recall
- **Attempts**: 3 tries per session

### 2. Visual Memory Test
- **Purpose**: Assess visual pattern recognition
- **Method**: Show sequence of patterns/colors
- **Scoring**: Accuracy in pattern reproduction
- **Difficulty Levels**: Progressive complexity

### 3. Reading Test
- **Purpose**: Evaluate reading comprehension
- **Method**: Timed text reading with comprehension questions
- **Metrics**: Speed and accuracy tracking
- **Customization**: Multiple difficulty levels

### 4. Basic Math Test
- **Purpose**: Cognitive arithmetic abilities
- **Method**: Timed arithmetic problems
- **Operations**: Addition, subtraction, multiplication
- **Difficulty**: Adjustable complexity

### 5. Reflex Test (ESP32 Integration)
- **Purpose**: Measure reaction time
- **Method**: LED stimulus response measurement
- **Hardware**: ESP32 with LED indicators
- **Metrics**: Response time in milliseconds

## Technical Features

### Data Export
- Individual test results
- Progress trends
- Comprehensive patient reports
- CSV format export

### ESP32 Integration
- Wireless connection setup
- Real-time data collection
- Test execution control
- Response time measurement

### Libraries Used By The App
Flutter
Firebase Core
Firebase Auth
Cloud Firestore
Connectivity Plus
Flutter Local Notifications
Workmanager



## Arduino Libraries Used by ESP

- NTPClient by Fabrice Weinberg - version 3.2.1
- Adafruit Neopixel by Adafruit - version 1.12.3
- ArduinoJson by Benoit Blanchon - version 7.3.0
- TFT_eSPI by Bodmer - version 2.5.34
- Time by Michael Margolis - verion 1.6.1
- XPT2046_Touchscreen by Paul Stoffregen - version 1.4

## Cables Connection Sketch
[ESP_cables_connection](Documentation/ESP_cables_connection.jpg "Cables Connection")

## Pin Connections

| TouchScreen Pin    | ESP Pin               |
|---------------|----------------------------|
| T_IRQ          | 	GPIO 25  |
| T_OUT          | 	GPIO 26  |
| T_DIN          | 	GPIO 32  |
| T_CS           | 	GPIO 33  |
| T_CLK          | 	GPIO 27  |
| SDO(MISO       | 	GPIO 12  |
| LED            | 	GPIO 21  |
| SCK            | 	GPIO 14  |
| SDI(MOSI)      | 	GPIO 13  |
| D/C            | 	GPIO 2   |
| RESET          | 	EN/RESET |
| CS             | 	GPIO 15  |
| GND            | 	GND      |
| VCC            | 	3.3V     |

| Buttons Pin   | ESP Pin                    |
|---------------|----------------------------|
| Button 1          | 	GPIO 5   |
| Button 2          | 	GPIO 18  |
| Button 3          | 	GPIO 19  |
| Button 4          | 	GPIO 22  |
| Button 5          | 	GPIO 23  |

| RGB Rings Pin    | ESP Pin                   |
|------------------|---------------------------|
| DIN              | 	GPIO 4   |
| VCC              |  5V       |
| GND              |  GND      |

| MP3 Player Board Pin    | ESP Pin       |
|-------------------------|---------------|
| VCC          | 	5V       |
| GND          | 	GND      |
| RX           |  RX2      |
| TX           |  TX2      |



