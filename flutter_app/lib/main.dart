import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';
// Desktop platform specific imports
import 'dart:io';
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
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.amber, // Example secondary color
        ),
      ),
      home: HomeScreen(), // Set HomeScreen as the new home of the app
    );
  }
}
