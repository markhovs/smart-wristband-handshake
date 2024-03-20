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
  final String writeServiceUuid = 'write_service_uuid';
  final String writeCharacteristicUuid = 'write_characteristic_uuid';
  final String readServiceUuid = 'read_service_uuid';
  final String readCharacteristicUuid = 'read_characteristic_uuid';

  BluetoothDevice? _targetDevice;
  StreamSubscription? _scanSubscription;

  Future<void> initialize() async {
    await startBLEScan();
  }

  Future<void> startBLEScan() async {
    await _flutterBlue.startScan(timeout: Duration(seconds: 10));

    _scanSubscription = _flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.id.id == targetDeviceId) {
          _targetDevice = result.device;
          break;
        }
      }
    });

    await Future.delayed(Duration(seconds: 10));
    await _flutterBlue.stopScan();

    if (_targetDevice != null) {
      await _targetDevice!.connect();
    } else {
      print('Target device not found');
    }
  }

  Future<bool> sendPersonalProfile(BusinessCard profile) async {
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
    if (_targetDevice == null) return null;

    List<BluetoothService> services = await _targetDevice!.discoverServices();
    BluetoothService? service = services.firstWhereOrNull((s) => s.uuid.toString() == readServiceUuid);
    BluetoothCharacteristic? characteristic =
        service?.characteristics.firstWhereOrNull((c) => c.uuid.toString() == readCharacteristicUuid);

    if (characteristic != null) {
      await characteristic.setNotifyValue(true);
      var value = await characteristic.read();
      var receivedCard = _convertDataToBusinessCard(value);
      print('Contact received');

      await _targetDevice!.disconnect();
      return receivedCard;
    } else {
      print('Read characteristic not found');
      await _targetDevice!.disconnect();
      return null;
    }
  }

  List<int> _convertProfileToData(BusinessCard profile) {
    var json = jsonEncode({
      'firstName': profile.firstName,
      'lastName': profile.lastName,
      // Add other fields as necessary
    });
    return utf8.encode(json);
  }

  BusinessCard? _convertDataToBusinessCard(List<int> value) {
    try {
      var json = jsonDecode(utf8.decode(value));
      return BusinessCard(
        firstName: json['firstName'] ?? 'Unknown',
        lastName: json['lastName'] ?? 'Unknown',
        phoneNumber: json['phoneNumber'] ?? 'Unknown',
        email: json['email'] ?? 'Unknown',
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        updatedAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        // Add other fields as necessary, provide default values or handle null
      );
    } catch (e) {
      print('Error converting data: $e');
      return null; // Return null to indicate an error occurred during conversion
    }
  }

  void dispose() {
    _scanSubscription?.cancel();
    _targetDevice?.disconnect();
  }
}
