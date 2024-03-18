import 'package:flutter/material.dart';
import '../models/business_card.dart';
import '../services/database_helper.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<BusinessCard> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() async {
    List<BusinessCard> contactsList = await DatabaseHelper.instance.getAllContactCards();
    setState(() {
      _contacts = contactsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Contacts'),
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_contacts[index].firstName + ' ' + _contacts[index].lastName),
            subtitle: Text(_contacts[index].email),
            onTap: () {
              // TODO: Navigate to a detailed view for this contact
            },
          );
        },
      ),
    );
  }
}
