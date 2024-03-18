import 'package:flutter/material.dart';
import '../models/business_card.dart';

class ContactDetailScreen extends StatelessWidget {
  final BusinessCard contact;

  ContactDetailScreen({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${contact.firstName} ${contact.lastName}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${contact.firstName} ${contact.lastName}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Phone: ${contact.phoneNumber ?? 'Not provided'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Email: ${contact.email}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('LinkedIn: ${contact.linkedIn ?? 'Not provided'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Company: ${contact.company ?? 'Not provided'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Position: ${contact.position ?? 'Not provided'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Description: ${contact.description ?? 'Not provided'}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Contact received at: ${contact.createdAt ?? 'Not provided'}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
