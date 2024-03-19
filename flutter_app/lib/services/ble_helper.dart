import 'dart:async';
import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import '../models/business_card.dart';

class BLEService {
  final StreamController<BusinessCard> _contactStreamController = StreamController<BusinessCard>.broadcast();
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  StreamSubscription? _scanSubscription; // Define _scanSubscription here

  Stream<BusinessCard> get contactStream => _contactStreamController.stream;

  BLEService();

  void simulateContactReception() {
    final BusinessCard contact = _generateRandomBusinessCard();
    _contactStreamController.add(contact);
  }

  BusinessCard _generateRandomBusinessCard() {
    final names = ['Alice', 'Bob', 'Charlie'];
    final lastNames = ['Smith', 'Johnson', 'Williams'];
    final phones = ['123-456-7890', '987-654-3210', '654-321-9870'];
    final emails = ['alice@example.com', 'bob@example.com', 'charlie@example.com'];
    Random random = Random();
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    return BusinessCard(
      firstName: names[random.nextInt(names.length)],
      lastName: lastNames[random.nextInt(lastNames.length)],
      phoneNumber: phones[random.nextInt(phones.length)],
      email: emails[random.nextInt(emails.length)],
      linkedIn: '',
      company: '',
      position: '',
      description: 'This is a mock contact',
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Future<List<String>> startBLEScan() async {
    List<String> deviceNames = [];
    await _flutterBlue.startScan(timeout: Duration(seconds: 4));

    _scanSubscription = _flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        // Collecting device names, not the devices themselves
        deviceNames.add(result.device.name.isEmpty ? 'Unknown Device' : result.device.name);
      }
    });

    await Future.delayed(Duration(seconds: 4)); // Wait for scan to finish
    _flutterBlue.stopScan();
    return deviceNames; // Returning names, not BluetoothDevice objects
  }

  void stopBLEScan() {
    _scanSubscription?.cancel();
    _flutterBlue.stopScan();
  }

  void dispose() {
    _contactStreamController.close();
    stopBLEScan();
    _scanSubscription?.cancel();
  }
}
