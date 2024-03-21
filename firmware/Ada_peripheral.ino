#include <ArduinoBLE.h>

// UUIDs for the custom service and characteristic
const char* contactServiceUuid = "34ad309e-9c79-4360-b147-5c700738cadc";
const char* nameCharacteristicUuidPA = "1ca6319c-c869-40e0-9e73-92132c014886";
//const char* nameCharacteristicUuidAP = "6ccb7839-613b-420c-af19-400a7fef7452";

BLEService contactService(contactServiceUuid);
BLECharacteristic nameCharacteristicPA(nameCharacteristicUuidPA, BLERead | BLEWrite, 200);
//BLECharacteristic nameCharacteristicAP(nameCharacteristicUuidAP, BLERead | BLENotify, 20);

byte my_name[200];

void setup() {
  Serial.begin(9600);
  while(!Serial);

  if (!BLE.begin()) {
    //Serial.println("Starting BLE failed!");
    while (1);
  }

  BLE.setDeviceName("Ada");
  BLE.setAdvertisedService(contactService);

  contactService.addCharacteristic(nameCharacteristicPA);
  //contactService.addCharacteristic(nameCharacteristicAP);
  BLE.addService(contactService);

  nameCharacteristicPA.writeValue("");
 // nameCharacteristicAP.writeValue("");

  BLE.advertise();
  Serial.println("Ada is running ...");
}

void loop() {
  BLEDevice central;
  central = BLE.central();

  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {
      if (nameCharacteristicPA.written()) {
        nameCharacteristicPA.readValue(my_name, 200);
        Serial.print("nameCharacteristic was written. New name: ");
        Serial.println((char*) my_name);
      }

      //nameCharacteristicAP.writeValue(my_name, 20);
    }
    Serial.println("Central disconnected");
  } else {
    //Serial.println("Could not connect to central");
  }
}
