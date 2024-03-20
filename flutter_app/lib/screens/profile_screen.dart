import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/business_card.dart';
import '../services/database_helper.dart';
import '../services/ble_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  BusinessCard? _personalCard;
  bool _isLoading = true;

  // Text Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();

  // BLE Service
  final BLEService _bleService = BLEService();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
    _bleService.initialize(); // Initialize BLE service to prepare for operations.
  }

  Future<void> _initializeProfile() async {
    _personalCard = await DatabaseHelper.instance.getPersonalCard();
    if (_personalCard != null) {
      _setDataToControllers(_personalCard!);
    }
    setState(() => _isLoading = false);
  }

  void _setDataToControllers(BusinessCard card) {
    _firstNameController.text = card.firstName;
    _lastNameController.text = card.lastName;
    _phoneNumberController.text = card.phoneNumber;
    _emailController.text = card.email;
    _linkedInController.text = card.linkedIn;
    _companyController.text = card.company;
    _positionController.text = card.position;
    _descriptionController.text = card.description;
  }

  void _toggleEditMode() => setState(() => _isEditMode = !_isEditMode);

  void _createOrSaveProfile() async {
    if (_isEditMode && _formKey.currentState!.validate()) {
      await _saveProfile();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved!')));

      if (_personalCard != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sending profile via BLE...')));

        bool sentSuccessfully = await _bleService.sendPersonalProfile(_personalCard!);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (sentSuccessfully) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile sent via BLE')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send profile via BLE')));
        }

        setState(() => _isEditMode = false);
      }
    } else {
      setState(() => _isEditMode = true);
    }
  }

  Future<void> _saveProfile() async {
    String currentTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final updatedCard = BusinessCard(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phoneNumber: _phoneNumberController.text,
      email: _emailController.text,
      linkedIn: _linkedInController.text,
      company: _companyController.text,
      position: _positionController.text,
      description: _descriptionController.text,
      createdAt: currentTimestamp,
      updatedAt: currentTimestamp,
    );

    await DatabaseHelper.instance.insertOrUpdatePersonalCard(updatedCard);
    setState(() => _personalCard = updatedCard);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_isEditMode || _personalCard == null ? _buildEditableView() : _buildReadOnlyView()),
      floatingActionButton: FloatingActionButton(
        onPressed: _createOrSaveProfile,
        tooltip: _isEditMode || _personalCard == null ? 'Save' : 'Edit',
        child: Icon(_isEditMode || _personalCard == null ? Icons.check : Icons.edit),
      ),
    );
  }

  Widget _buildReadOnlyView() {
    if (_personalCard == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ListTile(title: const Text('First Name'), subtitle: Text(_personalCard!.firstName)),
        ListTile(title: const Text('Last Name'), subtitle: Text(_personalCard!.lastName)),
        ListTile(title: const Text('Phone Number'), subtitle: Text(_personalCard!.phoneNumber)),
        ListTile(title: const Text('Email'), subtitle: Text(_personalCard!.email)),
        ListTile(title: const Text('LinkedIn Profile'), subtitle: Text(_personalCard!.linkedIn)),
        ListTile(title: const Text('Company'), subtitle: Text(_personalCard!.company)),
        ListTile(title: const Text('Position'), subtitle: Text(_personalCard!.position)),
        ListTile(title: const Text('Description'), subtitle: Text(_personalCard!.description)),
      ],
    );
  }

  Widget _buildEditableView() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _linkedInController,
                decoration: const InputDecoration(labelText: 'LinkedIn Profile'),
                validator: (value) => value!.isEmpty ? 'Please enter your LinkedIn profile URL' : null,
              ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
                validator: (value) => value!.isEmpty ? 'Please enter your company' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Position'),
                validator: (value) => value!.isEmpty ? 'Please enter your position' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers and the BLE service
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _linkedInController.dispose();
    _companyController.dispose();
    _positionController.dispose();
    _descriptionController.dispose();
    _bleService.dispose();
    super.dispose();
  }
}
