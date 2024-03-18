class BusinessCard {
  final int? id; // SQLite automatically uses an integer key called 'id'.
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String linkedIn;
  final String company;
  final String position;
  final String description;

  BusinessCard({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.linkedIn = '', // Assuming these can have default empty values
    this.company = '',
    this.position = '',
    this.description = '',
  });

  Map<String, dynamic> toMap({bool forUpdate = false}) {
    final map = {
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'email': email,
      'linkedIn': linkedIn,
      'company': company,
      'position': position,
      'description': description,
    };

    // Exclude 'id' from the map when updating records
    if (!forUpdate && id != null) {
      map['id'] = id.toString();
    }

    return map;
  }

  factory BusinessCard.fromMap(Map<String, dynamic> map) {
    return BusinessCard(
      id: map['id'] as int?, // Safe casting to handle potential type issues
      firstName: map['firstName'] ?? '', // Default to empty string if null
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      linkedIn: map['linkedIn'] ?? '',
      company: map['company'] ?? '',
      position: map['position'] ?? '',
      description: map['description'] ?? '',
    );
  }

  @override
  String toString() {
    // Helps with debugging by providing a string representation of the object.
    return 'BusinessCard(id: $id, firstName: $firstName, lastName: $lastName, '
        'phoneNumber: $phoneNumber, email: $email, linkedIn: $linkedIn, '
        'company: $company, position: $position, description: $description)';
  }
}
