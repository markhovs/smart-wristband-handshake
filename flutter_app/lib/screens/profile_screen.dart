import 'package:flutter/material.dart';
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
    } else {
      // Handle the case where there is no profile card.
      // This can be setting default values, or leaving them empty.
    }
    setState(() {}); // Refresh the UI with the data.
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

  // Toggle edit mode and ensure controllers are updated with the latest data.
  void _toggleEditMode() {
    if (_isEditMode) {
      // In case we are currently in edit mode, save the profile.
      _saveProfile();
    } else {
      // If we are going into edit mode, make sure to set the controllers.
      if (_personalCard != null) {
        _setDataToControllers(_personalCard!);
      }
    }
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedCard = BusinessCard(
        id: _personalCard?.id, // Keep the original ID
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        linkedIn: _linkedInController.text,
        company: _companyController.text,
        position: _positionController.text,
        description: _descriptionController.text,
      );
      await DatabaseHelper.instance.insertOrUpdatePersonalCard(updatedCard);

      // After saving, update the state with the new card data
      setState(() {
        _personalCard = updatedCard;
        _isEditMode = false; // Also ensure we exit edit mode
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
      ),
      body: _isEditMode ? _buildEditableView() : _buildReadOnlyView(),
      floatingActionButton: _personalCard != null
          ? FloatingActionButton(
              onPressed: () {
                if (_isEditMode) {
                  _saveProfile(); // Save changes and exit edit mode
                } else {
                  setState(() {
                    _isEditMode = true; // Enter edit mode
                  });
                }
              },
              child: Icon(_isEditMode ? Icons.check : Icons.edit),
              tooltip: _isEditMode ? 'Save' : 'Edit', // Optional: adds a long press tooltip
            )
          : null, // Don't show the button if there's no profile loaded
    );
  }

  Widget _buildReadOnlyView() {
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
                validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              TextFormField(
                controller: _linkedInController,
                decoration: InputDecoration(labelText: 'LinkedIn'),
                validator: (value) => value!.isEmpty ? 'Please enter your LinkedIn profile' : null,
              ),
              TextFormField(
                controller: _companyController,
                decoration: InputDecoration(labelText: 'Company'),
                validator: (value) => value!.isEmpty ? 'Please enter your company' : null,
              ),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(labelText: 'Position'),
                validator: (value) => value!.isEmpty ? 'Please enter your position' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) => value!.isEmpty ? 'Please enter your personal description' : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
