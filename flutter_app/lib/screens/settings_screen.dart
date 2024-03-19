import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings.dart'; // Ensure this path is correct

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingsModel = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Approve Contacts'),
            value: settingsModel.approveContacts,
            onChanged: (bool value) {
              settingsModel.toggleApproveContacts();
            },
          ),
          ListTile(
            title: const Text('Sharing Preferences'),
            onTap: () {
              // Here you would navigate to a different screen for sharing preferences.
              // Navigator.of(context).push(MaterialPageRoute(builder: (_) => SharingPreferencesScreen()));
            },
          ),
          // Additional settings options can be added here.
        ],
      ),
    );
  }
}
