import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business_card.dart';
import '../services/database_helper.dart';

class ContactDetailScreen extends StatelessWidget {
  final BusinessCard contact;

  const ContactDetailScreen({Key? key, required this.contact}) : super(key: key);

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      return;
    }
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw 'Could not launch $urlString';
    }
  }

  Future<void> _deleteContact(BuildContext context) async {
    try {
      await DatabaseHelper.instance.deleteContactCard(contact.id);
      // Use 'deleted' as a signal to the previous screen that the contact has been deleted
      Navigator.of(context).pop('deleted');
    } catch (e) {
      // Handle or show error if deletion fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete contact: $e')),
      );
    }
  }

  Widget _infoRow(String label, String? value, {bool isUrl = false}) {
    final content = Text(
      '$label: ${value ?? 'Not provided'}',
      style: const TextStyle(fontSize: 18),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: isUrl && value != null
          ? InkWell(
              child: content,
              onTap: () => _launchUrl(value),
            )
          : content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${contact.firstName} ${contact.lastName}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('Confirm Deletion'),
                content: const Text('Are you sure you want to delete this contact?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(), // Dismiss dialog
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => _deleteContact(context),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _infoRow('Name', '${contact.firstName} ${contact.lastName}'),
            _infoRow('Phone', contact.phoneNumber),
            _infoRow('Email', contact.email),
            _infoRow('LinkedIn', contact.linkedIn, isUrl: true),
            _infoRow('Company', contact.company),
            _infoRow('Position', contact.position),
            _infoRow('Description', contact.description),
            _infoRow('Contact received at', contact.createdAt),
          ],
        ),
      ),
    );
  }
}
