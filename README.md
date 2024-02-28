# Design and development of an embedded system for plant health monitoring

## Overview
The purpose of this project is to illustrate the design and development of an embedded system in order to acquire data related to the health and environmental conditions of a plant. Furtherly, this system  deals with the maintaining of an optimal soil moisture level for the plant. The system can acquire and process soil moisture, air humidity, temperature and brightness values, and also control irrigation by a submersible water pump. Via Wi-Fi communication, the collected data are sent to [Measurify](https://measurify.org/), an API framework with a database used to memorize these values and to successively interface with a smartphone application developed with [Flutter](https://flutter.dev/). The application allows the user to visualize the current state of the values and a chart showing the previous measurements.


## Hardware
The following hardware components have been used:
* [Arduino UNO WiFi rev2](https://store.arduino.cc/products/arduino-uno-wifi-rev2)
* [Sparkfun Weather Shield](https://www.sparkfun.com/products/13956)
* [Capacitive soil moisture sensor v1.2](https://www.robotics.org.za/CAP-SW-12)
* 5v Relay Module
* Arduino water pump

## Software
### Arduino 
These Arduino's libraries have been used:
* [<WiFiNINA.h>](https://www.arduino.cc/reference/en/libraries/wifinina/)
* [<SparkFunWeatherShield.h>](https://create.arduino.cc/editor/rogermiranda1000/810942a0-9637-46ac-ae9f-feedf00e11b4/preview)
* [<ArduinoHttpClient.h>](https://www.arduino.cc/reference/en/libraries/httpclient/)
* [<ArduinoJson.h>](https://www.arduino.cc/reference/en/libraries/arduinojson/)
* [<WiFiUdp.h>](https://www.arduino.cc/reference/en/libraries/wifi/wifiudp)
* [<TimeLib.h>](https://playground.arduino.cc/Code/Time/)

### Flutter
During the development of the smartphone application these Flutter libraries have been used:
* [http/http.dart](https://pub.dev/packages/http)
* [syncfusion_flutter_charts/charts.dart](https://pub.dev/packages/syncfusion_flutter_charts)

## Quick start
As a first step, you need to make the connections between the hardware components, as shown in the figure.

![Hardware connections](images/Figure1.png?raw=true "Figure 1") 

After that, you need to connect Arduino to a PC using an USB cable, download the [Arduino IDE](https://www.arduino.cc/en/software) and select the Arduino UNO Wifi rev2 board and port.
Then you need to install the libraries mentioned above by the `Library Manager` of the Arduino IDE. The SparkFunWeatherShield library, however, must be installed from the [web](https://create.arduino.cc/editor/rogermiranda1000/810942a0-9637-46ac-ae9f-feedf00e11b4/preview) and included in the project following these steps: `Sketch -> Include Library -> Add .ZIP Library…`.
Now you can open *sketch_tesi.ino* and set SSID and password of the Wifi network you want to connect in the file *arduino_secrets.h*. To verifing that the program properly works you need to upload it on the Arduino board and read the prints of the `Serial Monitor`.

In order to use the smartphone application you have to install [Flutter](https://docs.flutter.dev/get-started/install) and [VSCode](https://code.visualstudio.com/). Then you can open the repository *tesi_app* in VSCode and run *main.dart* following these [instructions](https://docs.flutter.dev/tools/vs-code#run-app-with-breakpoints). Now you should be able to see the two pages of the app showing the measurements saved on Measurify. 

![app](images/Figure2.png?raw=true "Figure 2") 

