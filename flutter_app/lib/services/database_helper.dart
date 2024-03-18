import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/business_card.dart';
// Import `sqflite_common_ffi` only if the platform is not iOS or Android
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final _databaseName = "SmartWristbandDatabase.db";
  static final _databaseVersion = 1;
  static final tablePersonal = 'personal_business_card';
  static final tableContacts = 'contacts_business_card';
  static Database? _database;

  // Columns for both tables
  static final columnId = 'id';
  static final columnFirstName = 'firstName';
  static final columnLastName = 'lastName';
  static final columnPhoneNumber = 'phoneNumber';
  static final columnEmail = 'email';
  static final columnLinkedIn = 'linkedIn';
  static final columnCompany = 'company';
  static final columnPosition = 'position';
  static final columnDescription = 'description';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database == null) {
      // Check if you're running on a platform that isn't iOS or Android.
      if (!Platform.isIOS && !Platform.isAndroid && !kIsWeb) {
        // Initialize sqflite_common_ffi for non-mobile platforms.
        sqfliteFfiInit();
        _database = await databaseFactoryFfi.openDatabase(
          join(await getDatabasesPath(), _databaseName),
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: _onCreate,
          ),
        );
      } else {
        // For mobile platforms, proceed with the standard initialization.
        String path = join(await getDatabasesPath(), _databaseName);
        _database = await openDatabase(
          path,
          version: _databaseVersion,
          onCreate: _onCreate,
        );
      }
    }
    return _database!;
  }

  // CRUD operations as before...
  Future _onCreate(Database db, int version) async {
    // Create the personal business card table
    await db.execute('''
      CREATE TABLE $tablePersonal (
        $columnId INTEGER PRIMARY KEY,
        $columnFirstName TEXT NOT NULL,
        $columnLastName TEXT NOT NULL,
        $columnPhoneNumber TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnLinkedIn TEXT,
        $columnCompany TEXT,
        $columnPosition TEXT,
        $columnDescription TEXT
      )
    ''');

    // Create the contacts business card table
    await db.execute('''
      CREATE TABLE $tableContacts (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFirstName TEXT NOT NULL,
        $columnLastName TEXT NOT NULL,
        $columnPhoneNumber TEXT NOT NULL,
        $columnEmail TEXT NOT NULL,
        $columnLinkedIn TEXT,
        $columnCompany TEXT,
        $columnPosition TEXT,
        $columnDescription TEXT
      )
    ''');
  }

  // Insert a personal business card (update if exists to maintain only a single personal card)
  Future<void> insertOrUpdatePersonalCard(BusinessCard card) async {
    Database db = await instance.database;
    var existingCards = await db.query(tablePersonal);
    if (existingCards.isEmpty) {
      // Insert new if none exists
      await db.insert(tablePersonal, card.toMap());
    } else {
      // Update the existing card (assuming only one record is there)
      // Ensure we use the existing `id` and do not set it to `null`
      var existingId = existingCards.first[columnId];
      await db.update(
        tablePersonal,
        card.toMap(),
        where: '$columnId = ?',
        whereArgs: [existingId], // Pass the correct `id`
      );
    }
  }

  // Get the personal business card
  Future<BusinessCard?> getPersonalCard() async {
    Database db = await instance.database;
    List<Map> maps = await db.query(tablePersonal);
    if (maps.isNotEmpty) {
      return BusinessCard.fromMap(Map<String, dynamic>.from(maps.first));
    }
    return null;
  }

  // Insert a received business card
  Future<void> insertContactCard(BusinessCard card) async {
    Database db = await instance.database;
    await db.insert(tableContacts, card.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // Get all received business cards
  Future<List<BusinessCard>> getAllContactCards() async {
    Database db = await instance.database;
    List<Map> maps = await db.query(tableContacts);
    return List.generate(maps.length, (i) {
      return BusinessCard.fromMap(Map<String, dynamic>.from(maps[i]));
    });
  }

  // Update and delete methods can be implemented similarly, as needed.
}
