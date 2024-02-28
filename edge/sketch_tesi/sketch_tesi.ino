
#include <ArduinoHttpClient.h>        //libreria per gestire la POST request all'API
#include <WiFiNINA.h>
#include <ArduinoJson.h>              //libreria per gestire il body della post scritto in JSON
#include "SparkFunWeatherShield.h"    //libreria per gestire il Weather Shield della Sparkfun

//librerie per gestire la date e l'ora correnti
#include <WiFiUdp.h>
#include <TimeLib.h>

#include "arduino_secrets.h"

///////please enter your sensitive jsonString in the Secret tab/arduino_secrets.h
char ssid[] = SECRET_SSID;    // your network SSID (name)
char pass[] = SECRET_PASS;    // your network password (use for WPA)
int status = WL_IDLE_STATUS;  // the WiFi radio's status

char serverAddress[] = "students.measurify.org";  // indirizzo dell'API
int port = 443;                                   //  porta del server https
char token[] = SECRET_TOKEN;                      //token per il login all'API

WiFiSSLClient wifiClient;
HttpClient client = HttpClient(wifiClient, serverAddress, port);

const size_t capacity = JSON_OBJECT_SIZE(2) + JSON_ARRAY_SIZE(4);  // Dimensione massima del documento JSON
DynamicJsonDocument jsonDocument(capacity);                        // creo un oggetto JSON

// define IPAddress object that will contain the NTP server IP address
// We will use an NTP server from https://tf.nist.gov/tf-cgi/servers.cgi
IPAddress timeServer(129, 6, 15, 28);
WiFiUDP wifi_UDP;
int localPort = 8888;

// variable to store previous displayed time
time_t prevDisplay = 0;

// Set offset time in seconds to adjust for your timezone, for example:
//  GMT +1 = 3600
//  GMT +2 = 7200
//  GMT -1 = -3600
//  GMT 0 = 0
unsigned int timezoneOffset = 3600; 

// array to hold incoming/outgoing NTP messages
// NTP time message is 48 bytes long
byte messageBuffer[48];

WeatherShield weather;

const int DryValue = 579;   //valore del sensore di umidità del suolo asciutto
const int WetValue = 277;  // valore del sensore di umidità del suolo immerso nell'acqua

int relayPumpPin = 9;      //pin dedicato all'accensione della pompa dell'acqua

float arrayDate[4];        //array in cui salvare i dati raccolti dai sensori


void setup() 
{
  Serial.begin(9600);
  /*while (!Serial) {
    ;  // wait for serial port to connect. Needed for native USB port only
  }*/

  // check for the WiFi module:
  if (WiFi.status() == WL_NO_MODULE) {
    Serial.println("Communication with WiFi module failed!");
    // don't continue
    while (true)
      ;
  }

  String fv = WiFi.firmwareVersion();
  if (fv < WIFI_FIRMWARE_LATEST_VERSION) {
    Serial.println("Please upgrade the firmware");
  }

  // attempt to connect to WiFi network:
  while (status != WL_CONNECTED) {
    Serial.println("Attempting to connect to Wifi..");
    // Connect to WPA/WPA2 network:
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(10000);
  }

  // you're connected now
  Serial.print("You're connected to the wifi network: ");
  Serial.println(WiFi.SSID());

  // start UDP
  wifi_UDP.begin(localPort);

  // pass function getTime() to Time Library to update current time [part of Time Library]
  setSyncProvider(getTime);


  pinMode(relayPumpPin, OUTPUT);
  digitalWrite(relayPumpPin, HIGH);
  pinMode(LED_BUILTIN, OUTPUT);

  weather.startPins();  // set on-board's pin mode

  weather.begin();  // enable I2C & sensors
}



void loop() 
{
  digitalWrite(SHIELD_LED_BLUE, HIGH);

  float soilMoistureAnalog = 0;
  float soilMoistureValue = 0;
  float humidity = 0;
  float temp = 0;
  float light_level = 0;

  //Controllo sensore umidità del suolo
  soilMoistureAnalog = analogRead(A0);
  soilMoistureValue = map(soilMoistureAnalog, WetValue, DryValue, 100, 0);  // mappo i valori del sensore in una scala percentuale da 0 a 100
  Serial.print("Umidità del suolo: ");
  Serial.print (soilMoistureValue);
  Serial.println("%");
  arrayDate[0] = soilMoistureValue;

  //Contollo sensore di umidità
  humidity = weather.readHumidity();

  if (humidity == ERROR_I2C_TIMEOUT) Serial.println("I2C error.");  // humidty sensor failed to respond
  else {
    Serial.print("Umidità = ");
    Serial.print(humidity);
    Serial.println("%");
    arrayDate[1] = humidity;

    //Contollo sensore di temperatura
    temp = weather.readTemperature();
    Serial.print("Temperatura = ");
    Serial.print(temp);
    Serial.println("C");
    arrayDate[2] = temp;
  }

  //Contollo sensore di luminosità
  light_level =( weather.getLightLevel()*1000000) / (3650*0.5);// per convertire da Volt a Lux
  Serial.print("Luminosità = ");
  Serial.print(light_level);
  Serial.println("Lux");  
  arrayDate[3] = light_level;

  Serial.println();
  if  (soilMoistureValue < 40) {            //controllo che l'umidita del suolo non sia troppo al di sotto del range ideale 40-70%
    Serial.println("Pompa acqua attivata");
    digitalWrite(relayPumpPin, LOW);  //attivo pompa acqua
    delay(5000);
  
    Serial.println("Pompa acqua disattivata");
    digitalWrite(relayPumpPin, HIGH);  //disattivo pompa acqua
  }
  
  Serial.println();

  digitalWrite(SHIELD_LED_BLUE, LOW);

  postTimesamples(arrayDate);

  delay(4000); // 10 minuti (600000)
}


//POST request
void postTimesamples(float date[]) 
{
  if (timeStatus() != timeNotSet) {  // check if the time is successfully updated
    if (now() != prevDisplay) {      
      prevDisplay = now();
      String cDate = printCurrentDate();  // save the current date and time
    
      //Scrivo in formato JSON il body della request
      jsonDocument["timestamp"] = cDate ;
      JsonArray jsonArray = jsonDocument.createNestedArray("values");
      for (int i = 0; i < 4; i++) {
        jsonArray.add(date[i]);
      }

      // Serializzo l'oggetto JSON in una stringa
      String jsonString;
      serializeJson(jsonDocument, jsonString);

      client.beginRequest();
      client.post("/v1/measurements/mesuremets-vine1/timeserie");

      //aggiungo gli header necessari alla request 
      client.sendHeader("Content-Type", "application/json");
      client.sendHeader("Content-Length", jsonString.length());
      client.sendHeader("Authorization", String(token));  

      //aggiungo il body alla request
      client.beginBody();
      client.print(jsonString);

      client.endRequest();

      // Attendo la risposta
      int statusCode = client.responseStatusCode();
      String response = client.responseBody();

      Serial.println();
      Serial.print("Status Code: ");
      Serial.println(statusCode);
      Serial.print("Response: ");
      Serial.println(response);
      Serial.println();
    }
  }
}


//function to display current date
String printCurrentDate() 
{
  Serial.print("Current date: ");
  //Scrivo date e ora nel formato:  2024-01-05T11:00:00
  String currentDate = String(year()) + "-" + String(addZero(month())) + "-" + String(addZero(day())) + "T" + String(addZero(hour())) + ":" + String(addZero(minute())) + ":" + String(addZero(second()));
  Serial.print(currentDate);

  Serial.println();

  return currentDate;
}

//helper function for printCurrentDate
String addZero(int digits) {
  // add a leading zero if number < 10 
  if (digits < 10)
    return "0" + String(digits);
  return String(digits);
}


time_t getTime() {
  while (wifi_UDP.parsePacket() > 0)
    ;  // discard packets remaining to be parsed

  Serial.println("Transmit NTP Request message");

  // send packet to request time from NTP server
  sendRequest(timeServer);

  // wait for response
  uint32_t beginWait = millis();

  while (millis() - beginWait < 1500) {

    int size = wifi_UDP.parsePacket();

    if (size >= 48) {
      Serial.println("Receiving NTP Response");
      Serial.println();

      // read date and save to messageBuffer
      wifi_UDP.read(messageBuffer, 48);

      // NTP time received will be the seconds elapsed since 1 January 1900
      unsigned long secsSince1900;

      // convert to an unsigned long integer the reference timestamp found at byte 40 to 43
      secsSince1900 = (unsigned long)messageBuffer[40] << 24;
      secsSince1900 |= (unsigned long)messageBuffer[41] << 16;
      secsSince1900 |= (unsigned long)messageBuffer[42] << 8;
      secsSince1900 |= (unsigned long)messageBuffer[43];

      // returns UTC time
      return secsSince1900 - 2208988800UL + timezoneOffset;
    }
  }

  // error if no response
  Serial.println("Error: No Response.");
  return 0;
}

// helper function for getTime()
// this function sends a request packet 48 bytes long
void sendRequest(IPAddress &address) {
  // set all bytes in messageBuffer to 0
  memset(messageBuffer, 0, 48);

  // create the NTP request message

  messageBuffer[0] = 0b11100011;  // LI, Version, Mode
  messageBuffer[1] = 0;           // Stratum, or type of clock
  messageBuffer[2] = 6;           // Polling Interval
  messageBuffer[3] = 0xEC;        // Peer Clock Precision
  // array index 4 to 11 is left unchanged - 8 bytes of zero for Root Delay & Root Dispersion
  messageBuffer[12] = 49;
  messageBuffer[13] = 0x4E;
  messageBuffer[14] = 49;
  messageBuffer[15] = 52;

  // send messageBuffer to NTP server via UDP at port 123
  wifi_UDP.beginPacket(address, 123);
  wifi_UDP.write(messageBuffer, 48);
  wifi_UDP.endPacket();
}