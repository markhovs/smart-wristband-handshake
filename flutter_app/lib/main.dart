import 'dart:io';
import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';
import 'screens/contacts_screen.dart';
import 'services/database_helper.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if you are on a desktop environment and initialize sqflite_common_ffi
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    // Initialize the database (if any specific initialization is needed)
    await DatabaseHelper.instance.database;
  } catch (e) {
    // Handle any errors during database initialization
    print('Error initializing database: $e');
    // You might choose to display an error message or take other actions here
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Wristband App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ProfileScreen(),
      routes: {
        '/profile': (context) => ProfileScreen(),
        '/contacts': (context) => ContactsScreen(),
      },
    );
  }
}
