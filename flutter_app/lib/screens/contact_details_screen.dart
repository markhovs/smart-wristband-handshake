import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/business_card.dart';

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
