import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../models/business_card.dart';
import '../screens/contact_details.dart';
import '../services/database_helper.dart';
import '../services/ble_helper.dart'; // Adjusted import based on your context

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<BusinessCard> _contacts = [];
  late StreamSubscription<BusinessCard> _contactSubscription;
  final MockBLEService _bleService = MockBLEService();
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
    _contactSubscription = _bleService.contactStream.listen((newContact) async {
      String receptionTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      bool confirm = await _showConfirmationDialog(newContact, receptionTimestamp);
      if (confirm) {
        _addContact(newContact, receptionTimestamp);
      }
    });
  }

  Future<bool> _showConfirmationDialog(BusinessCard contact, String timestamp) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm Contact'),
              content: Text(
                  'Would you like to add ${contact.firstName} ${contact.lastName} received at $timestamp to your list?'),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text('Add'),
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
    if (_isLoading) return Center(child: CircularProgressIndicator());
    if (_contacts.isEmpty) return Center(child: Text('No contacts received yet.'));

    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        BusinessCard contact = _contacts[index];
        return Card(
          child: ListTile(
            title: Text('${contact.firstName} ${contact.lastName}'),
            subtitle: Text('${contact.email}\nReceived at: ${contact.createdAt}'),
            isThreeLine: true,
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              print("List item tapped");
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Scaffold(appBar: AppBar(title: Text('Simple Test')))),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Contacts'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadContacts,
          ),
        ],
      ),
      body: _buildContactList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _bleService.simulateContactReception,
        tooltip: 'Simulate Contact Reception',
        child: Icon(Icons.bluetooth_searching),
      ),
    );
  }
}
