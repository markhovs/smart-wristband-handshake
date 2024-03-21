#include <ArduinoBLE.h>

// UUIDs for the custom service and characteristic
const char* contactServiceUuid = "12345678-1234-1234-1234-123456789012";
const char* nameCharacteristicUuidPF = "22222222-4321-4321-4321-210987654321";
//const char* nameCharacteristicUuidFP = "33333333-4321-4321-4321-210987654321";

BLEService contactService(contactServiceUuid);
BLECharacteristic nameCharacteristicPF(nameCharacteristicUuidPF, BLEWrite | BLERead, 200);
//BLECharacteristic nameCharacteristicFP(nameCharacteristicUuidFP, BLERead | BLENotify, 20);

byte my_name[200];

void setup() {
  Serial.begin(9600);
  while(!Serial);

  if (!BLE.begin()) {
    //Serial.println("Starting BLE failed!");
    while (1);
  }

  BLE.setDeviceName("Fruit");
  BLE.setLocalName("Fruit");
  BLE.setAdvertisedService(contactService);
  contactService.addCharacteristic(nameCharacteristicPF);
 // contactService.addCharacteristic(nameCharacteristicFP);

  BLE.addService(contactService);
  
 // nameCharacteristicFP.writeValue(""); 
  nameCharacteristicPF.writeValue("");

  BLE.advertise();
  Serial.println("Fruit is running ...");;
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {
      if (nameCharacteristicPF.written()) {
        nameCharacteristicPF.readValue(my_name, 200);
        Serial.print("My name was written. New value: ");
        Serial.println((char*) my_name);
      }

      //nameCharacteristicFP.writeValue(my_name, 20);
    }
    Serial.println("Central disconnected");
  } else {
    //Serial.println("Could not connect to central");
  }
}
