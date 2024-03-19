class BusinessCard {
  final int? id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String linkedIn;
  final String company;
  final String position;
  final String description;
  final String createdAt; // New field
  final String updatedAt; // New field

  BusinessCard({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    this.linkedIn = '',
    this.company = '',
    this.position = '',
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
  });

  BusinessCard copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    String? linkedIn,
    String? company,
    String? position,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return BusinessCard(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      linkedIn: linkedIn ?? this.linkedIn,
      company: company ?? this.company,
      position: position ?? this.position,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };

    if (!forUpdate && id != null) {
      map['id'] = id.toString();
    }

    return map;
  }

  factory BusinessCard.fromMap(Map<String, dynamic> map) {
    return BusinessCard(
      id: map['id'] as int?,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      linkedIn: map['linkedIn'] ?? '',
      company: map['company'] ?? '',
      position: map['position'] ?? '',
      description: map['description'] ?? '',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }
}
