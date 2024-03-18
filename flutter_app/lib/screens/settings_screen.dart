import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          // Add your settings options here
          SwitchListTile(
            title: Text('Connect Device'),
            value: true, // This should be managed by a stateful logic e.g., with Provider or setState
            onChanged: (bool value) {
              // Update the state with the new value
            },
          ),
          ListTile(
            title: Text('Sharing Preferences'),
            onTap: () {
              // Navigate to account settings
            },
          ),
          // Add more settings options as ListTile or other widgets
        ],
      ),
    );
  }
}
