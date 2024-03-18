import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import '../models/business_card.dart';

class MockBLEService {
  final StreamController<BusinessCard> _contactStreamController = StreamController<BusinessCard>.broadcast();

  Stream<BusinessCard> get contactStream => _contactStreamController.stream;

  MockBLEService();

  void simulateContactReception() {
    final BusinessCard contact = _generateRandomBusinessCard();
    _contactStreamController.add(contact);
  }

  BusinessCard _generateRandomBusinessCard() {
    // Generating mock data for the sake of simulation
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

  void dispose() {
    _contactStreamController.close();
  }
}
