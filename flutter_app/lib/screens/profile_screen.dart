import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/business_card.dart';
import '../services/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditMode = false;
  BusinessCard? _personalCard;
  bool _isLoading = true; // Indicate loading state initially

  // Text Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _companyController = TextEditingController();
  final _positionController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    _personalCard = await DatabaseHelper.instance.getPersonalCard();
    if (_personalCard != null) {
      _setDataToControllers(_personalCard!);
    }
    setState(() {
      _isLoading = false; // Loading complete, update UI accordingly
    });
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

  void _toggleEditMode() {
    setState(() {
      if (!_isEditMode && _personalCard != null) {
        // When transitioning to edit mode, populate the text fields if there is profile data.
        _setDataToControllers(_personalCard!);
      }
      _isEditMode = !_isEditMode;
    });
  }

  void _createOrSaveProfile() {
    if (_isEditMode && _formKey.currentState!.validate()) {
      _saveProfile();
    } else {
      // If not in edit mode and there is no profile, switch to edit mode to create a new profile.
      setState(() {
        _isEditMode = true;
      });
    }
  }

  void _saveProfile() async {
    String currentTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    // When creating a new profile, there won't be an existing ID or timestamps.
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
    setState(() {
      _personalCard = updatedCard;
      _isEditMode = false; // Exit edit mode after saving.
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_isEditMode || _personalCard == null ? _buildEditableView() : _buildReadOnlyView()),
      floatingActionButton: FloatingActionButton(
        onPressed: _createOrSaveProfile,
        child: Icon(_isEditMode || _personalCard == null ? Icons.check : Icons.edit),
        tooltip: _isEditMode || _personalCard == null ? 'Save' : 'Edit',
      ),
    );
  }

  Widget _buildNoProfileView() {
    // This view is now redundant as _buildEditableView handles the case.
    return Center(
      child: Text('No profile available.'),
    );
  }

  Widget _buildReadOnlyView() {
    if (_personalCard == null) return Center(child: CircularProgressIndicator());
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        ListTile(title: Text('First Name'), subtitle: Text(_personalCard!.firstName)),
        ListTile(title: Text('Last Name'), subtitle: Text(_personalCard!.lastName)),
        ListTile(title: Text('Phone Number'), subtitle: Text(_personalCard!.phoneNumber)),
        ListTile(title: Text('Email'), subtitle: Text(_personalCard!.email)),
        ListTile(title: Text('LinkedIn Profile'), subtitle: Text(_personalCard!.linkedIn)),
        ListTile(title: Text('Company'), subtitle: Text(_personalCard!.company)),
        ListTile(title: Text('Position'), subtitle: Text(_personalCard!.position)),
        ListTile(title: Text('Description'), subtitle: Text(_personalCard!.description)),
      ],
    );
  }

  Widget _buildEditableView() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter your first name' : null),
              TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value!.isEmpty ? 'Please enter your last name' : null),
              TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) => value!.isEmpty ? 'Please enter your email' : null),
              TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null),
              TextFormField(
                  controller: _linkedInController,
                  decoration: InputDecoration(labelText: 'LinkedIn'),
                  validator: (value) => value!.isEmpty ? 'Please enter your LinkedIn profile' : null),
              TextFormField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: 'Company'),
                  validator: (value) => value!.isEmpty ? 'Please enter your company' : null),
              TextFormField(
                  controller: _positionController,
                  decoration: InputDecoration(labelText: 'Position'),
                  validator: (value) => value!.isEmpty ? 'Please enter your position' : null),
              TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Please enter your personal description' : null),
            ],
          ),
        ),
      ),
    );
  }
}
