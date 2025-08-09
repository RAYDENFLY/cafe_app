class Member {
  int? id;
  String name;
  String? phone;
  String? email;
  String? address;
  int loyaltyPoints;
  DateTime? createdAt;
  DateTime? updatedAt;

  Member({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.loyaltyPoints = 0,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      loyaltyPoints: map['loyaltyPoints'] ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Member copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    int? loyaltyPoints,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
