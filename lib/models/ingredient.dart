class Ingredient {
  final int? id;
  final String name;
  final double quantity;
  final String unit;
  final double minStock;
  final DateTime? expiryDate;
  final double pricePerUnit;
  final DateTime createdAt;

  Ingredient({
    this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.minStock,
    this.expiryDate,
    required this.pricePerUnit,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Getter untuk kompatibilitas dengan kode lama
  double get stock => quantity;
  double get minimumStock => minStock;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'min_stock': minStock,
      'expiry_date': expiryDate?.millisecondsSinceEpoch,
      'price_per_unit': pricePerUnit,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      minStock: map['min_stock']?.toDouble() ?? 0.0,
      expiryDate: map['expiry_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiry_date'])
          : null,
      pricePerUnit: map['price_per_unit']?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : DateTime.now(),
    );
  }

  Ingredient copyWith({
    int? id,
    String? name,
    double? quantity,
    String? unit,
    double? minStock,
    DateTime? expiryDate,
    double? pricePerUnit,
    DateTime? createdAt,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minStock: minStock ?? this.minStock,
      expiryDate: expiryDate ?? this.expiryDate,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, quantity: $quantity, unit: $unit, minStock: $minStock, expiryDate: $expiryDate, pricePerUnit: $pricePerUnit, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.minStock == minStock &&
        other.expiryDate == expiryDate &&
        other.pricePerUnit == pricePerUnit;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        minStock.hashCode ^
        expiryDate.hashCode ^
        pricePerUnit.hashCode;
  }
}
