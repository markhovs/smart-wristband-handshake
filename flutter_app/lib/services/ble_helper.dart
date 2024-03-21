import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import '../models/business_card.dart';

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class BLEService {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  final String targetDeviceId = 'hardcoded_device_id';
  final String sourceDeviceId = 'hardcoded_device_id';
  final String writeServiceUuid = 'write_service_uuid';
  final String writeCharacteristicUuid = 'write_characteristic_uuid';
  final String readServiceUuid = 'read_service_uuid';
  final String readCharacteristicUuid = 'read_characteristic_uuid';

  BluetoothDevice? _targetDevice;
  BluetoothDevice? _sourceDevice;
  StreamSubscription? _scanSubscription;

  Future<void> startBLEScan(bool write) async {
    await _flutterBlue.startScan(timeout: Duration(seconds: 2));

    _scanSubscription = _flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.id.id == targetDeviceId) {
          _targetDevice = result.device;
          break;
        }
        if (result.device.id.id == sourceDeviceId) {
          _sourceDevice = result.device;
          break;
        }
      }
    });

    await Future.delayed(Duration(seconds: 2));
    await _flutterBlue.stopScan();

    if (_targetDevice != null && write) {
      await _targetDevice!.connect();
    } else if (_sourceDevice != null && !write) {
      await _sourceDevice!.connect();
    } else {
      print('Target device not found');
    }
  }

  Future<bool> sendPersonalProfile(BusinessCard profile) async {
    await startBLEScan(true);

    if (_targetDevice == null) return false;

    List<BluetoothService> services = await _targetDevice!.discoverServices();
    BluetoothService? service = services.firstWhereOrNull((s) => s.uuid.toString() == writeServiceUuid);
    BluetoothCharacteristic? characteristic =
        service?.characteristics.firstWhereOrNull((c) => c.uuid.toString() == writeCharacteristicUuid);

    if (characteristic != null) {
      var data = _convertProfileToData(profile);
      await characteristic.write(data);
      print('Profile sent');
      await _targetDevice!.disconnect();
      return true;
    } else {
      print('Write characteristic not found');
      await _targetDevice!.disconnect();
      return false;
    }
  }

  Future<BusinessCard?> receiveContactData() async {
    await startBLEScan(false);

    if (_sourceDevice == null) return null;

    List<BluetoothService> services = await _sourceDevice!.discoverServices();
    BluetoothService? service = services.firstWhereOrNull((s) => s.uuid.toString() == readServiceUuid);
    BluetoothCharacteristic? characteristic =
        service?.characteristics.firstWhereOrNull((c) => c.uuid.toString() == readCharacteristicUuid);

    if (characteristic != null) {
      await characteristic.setNotifyValue(true);
      var value = await characteristic.read();
      var receivedCard = _convertDataToBusinessCard(value);
      print('Contact received');

      await _sourceDevice!.disconnect();
      return receivedCard;
    } else {
      print('Read characteristic not found');
      await _sourceDevice!.disconnect();
      return null;
    }
  }

  List<int> _convertProfileToData(BusinessCard profile) {
    // Concatenate all fields with semicolons
    String concatenatedProfile = '${profile.firstName};'
        '${profile.lastName};'
        '${profile.phoneNumber};'
        '${profile.email};'
        '${profile.linkedIn};'
        '${profile.company};'
        '${profile.position};';

    // Convert the concatenated string to a list of ASCII values (byte array)
    List<int> profileBytes = ascii.encode(concatenatedProfile);
    return profileBytes;
  }

  BusinessCard? _convertDataToBusinessCard(List<int> value) {
    try {
      // Decode the byte array into a concatenated ASCII string
      String concatenatedProfile = ascii.decode(value);

      // Split the concatenated profile at each semicolon
      List<String> profileComponents = concatenatedProfile.split(';');

      // Verify that we have all expected components (except timestamps)
      if (profileComponents.length < 7) {
        print('Incomplete data received.');
        return null;
      }

      // Create and return a new BusinessCard with current timestamps
      return BusinessCard(
        firstName: profileComponents[0],
        lastName: profileComponents[1],
        phoneNumber: profileComponents[2],
        email: profileComponents[3],
        linkedIn: profileComponents[4],
        company: profileComponents[5],
        position: profileComponents[6],
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        updatedAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
    } catch (e) {
      print('Error converting data: $e');
      return null;
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _targetDevice?.disconnect();
  }
}
