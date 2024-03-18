import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/business_card.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/intl.dart';

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
  // New timestamp columns
  static final columnCreatedAt = 'createdAt';
  static final columnUpdatedAt = 'updatedAt';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database == null) {
      if (!Platform.isIOS && !Platform.isAndroid && !kIsWeb) {
        sqfliteFfiInit();
        _database = await databaseFactoryFfi.openDatabase(
          join(await getDatabasesPath(), _databaseName),
          options: OpenDatabaseOptions(
            version: _databaseVersion,
            onCreate: _onCreate,
          ),
        );
      } else {
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

  Future _onCreate(Database db, int version) async {
    // Create the personal business card table with createdAt and updatedAt fields
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
        $columnDescription TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''');

    // Create the contacts business card table with createdAt and updatedAt fields
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
        $columnDescription TEXT,
        $columnCreatedAt TEXT NOT NULL,
        $columnUpdatedAt TEXT NOT NULL
      )
    ''');
  }

  // Insert or update personal business card with timestamp handling
  Future<void> insertOrUpdatePersonalCard(BusinessCard card) async {
    Database db = await instance.database;
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var cardMap = card.toMap();
    cardMap[columnCreatedAt] = cardMap[columnUpdatedAt] = timestamp;

    var existingCards = await db.query(tablePersonal);
    if (existingCards.isEmpty) {
      await db.insert(tablePersonal, cardMap);
    } else {
      var existingId = existingCards.first[columnId];
      cardMap[columnUpdatedAt] = timestamp;
      await db.update(
        tablePersonal,
        cardMap,
        where: '$columnId = ?',
        whereArgs: [existingId],
      );
    }
  }

  // Insert received business card with current timestamp
  Future<void> insertContactCard(BusinessCard card) async {
    Database db = await instance.database;
    String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var cardMap = card.toMap();
    cardMap[columnCreatedAt] = cardMap[columnUpdatedAt] = timestamp;

    await db.insert(tableContacts, cardMap, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  // Retrieve the personal business card
  Future<BusinessCard?> getPersonalCard() async {
    Database db = await instance.database;
    List<Map> maps = await db.query(tablePersonal);
    if (maps.isNotEmpty) {
      return BusinessCard.fromMap(Map<String, dynamic>.from(maps.first));
    }
    return null;
  }

  // Retrieve all received business cards
  Future<List<BusinessCard>> getAllContactCards() async {
    Database db = await instance.database;
    List<Map> maps = await db.query(tableContacts);
    return List.generate(maps.length, (i) {
      return BusinessCard.fromMap(Map<String, dynamic>.from(maps[i]));
    });
  }
}
