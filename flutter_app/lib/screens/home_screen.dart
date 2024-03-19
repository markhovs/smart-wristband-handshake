import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'contacts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;

  final List<Widget> _pages = [
    const ProfileScreen(),
    const ContactsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _pageTitles = ['Profile', 'Contacts', 'Settings'];

  void _selectPage(int index) {
    Navigator.of(context).pop(); // Close the drawer
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedPageIndex]),
      ),
      body: IndexedStack(
        index: _selectedPageIndex,
        children: _pages,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text('Navigation Menu'),
            ),
            ListTile(
              title: const Text('Profile'),
              leading: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
              onTap: () => _selectPage(0),
            ),
            ListTile(
              title: const Text('Contacts'),
              leading: Icon(Icons.contacts, color: Theme.of(context).iconTheme.color),
              onTap: () => _selectPage(1),
            ),
            ListTile(
              title: const Text('Settings'),
              leading: Icon(Icons.settings, color: Theme.of(context).iconTheme.color),
              onTap: () => _selectPage(2),
            ),
          ],
        ),
      ),
    );
  }
}
