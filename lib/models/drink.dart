class Drink {
  int? id;
  String name;
  int stock;
  String type;
  double price;
  String? imagePath;
  DateTime? createdAt;
  DateTime? updatedAt;

  Drink({
    this.id,
    required this.name,
    required this.stock,
    required this.type,
    required this.price,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'type': type,
      'price': price,
      'imagePath': imagePath,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Drink.fromMap(Map<String, dynamic> map) {
    return Drink(
      id: map['id'],
      name: map['name'],
      stock: map['stock'],
      type: map['type'],
      price: map['price'],
      imagePath: map['imagePath'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Drink copyWith({
    int? id,
    String? name,
    int? stock,
    String? type,
    double? price,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Drink(
      id: id ?? this.id,
      name: name ?? this.name,
      stock: stock ?? this.stock,
      type: type ?? this.type,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
