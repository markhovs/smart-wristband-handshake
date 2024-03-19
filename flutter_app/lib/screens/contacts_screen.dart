import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'contact_details_screen.dart';
import '../models/business_card.dart';
import '../models/settings.dart';
import '../services/database_helper.dart';
import '../services/ble_helper.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<BusinessCard> _contacts = [];
  late StreamSubscription<BusinessCard> _contactSubscription;
  final BLEService _bleService = BLEService();
  bool _isLoading = false; // For indicating loading status

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _startListeningToBLE();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    List<BusinessCard> contactsList = await DatabaseHelper.instance.getAllContactCards();
    setState(() {
      _contacts = contactsList;
      _isLoading = false;
    });
  }

  void _startListeningToBLE() {
    _contactSubscription = _bleService.contactStream.listen((newContact) {
      final settingsModel = Provider.of<SettingsModel>(context, listen: false);
      String receptionTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      if (settingsModel.approveContacts) {
        _showConfirmationDialog(newContact, receptionTimestamp).then((confirmed) {
          if (confirmed) {
            _addContact(newContact, receptionTimestamp);
          }
        });
      } else {
        _addContact(newContact, receptionTimestamp);
      }
    });
  }

  Future<bool> _showConfirmationDialog(BusinessCard contact, String timestamp) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Contact'),
              content: Text(
                  'Would you like to add ${contact.firstName} ${contact.lastName} received at $timestamp to your list?'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _addContact(BusinessCard contact, String timestamp) async {
    BusinessCard updatedContact = contact.copyWith(createdAt: timestamp, updatedAt: timestamp);

    await DatabaseHelper.instance.insertContactCard(updatedContact);
    setState(() {
      _contacts.add(updatedContact);
    });
  }

  @override
  void dispose() {
    _contactSubscription.cancel();
    super.dispose();
  }

  Widget _buildContactList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_contacts.isEmpty) {
      return const Center(child: Text('No contacts received yet.'));
    }

    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        BusinessCard contact = _contacts[index];
        return Card(
          child: ListTile(
            title: Text('${contact.firstName} ${contact.lastName}'),
            subtitle: Text('${contact.email}\nReceived at: ${contact.createdAt}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ContactDetailScreen(contact: contact)),
            ),
          ),
        );
      },
    );
  }

  void _showDeviceList() async {
    List<String> deviceNames = await _bleService.startBLEScan(); // Getting names

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Available Bluetooth Devices'),
          content: SingleChildScrollView(
            child: ListBody(
              children: deviceNames.map((name) => Text(name)).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Received Contacts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
      ),
      body: _buildContactList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDeviceList,
        tooltip: 'Show Bluetooth Devices',
        heroTag: 'show_ble_devices',
        child: const Icon(Icons.bluetooth),
      ),
    );
  }
}
