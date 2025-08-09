class StockMovement {
  int? id;
  String itemType; // 'food' or 'drink'
  int itemId;
  String itemName;
  String movementType; // 'in' or 'out'
  int quantity;
  String reason; // 'purchase', 'sale', 'adjustment', 'expired'
  DateTime date;
  String? notes;

  StockMovement({
    this.id,
    required this.itemType,
    required this.itemId,
    required this.itemName,
    required this.movementType,
    required this.quantity,
    required this.reason,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemType': itemType,
      'itemId': itemId,
      'itemName': itemName,
      'movementType': movementType,
      'quantity': quantity,
      'reason': reason,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'],
      itemType: map['itemType'],
      itemId: map['itemId'],
      itemName: map['itemName'],
      movementType: map['movementType'],
      quantity: map['quantity'],
      reason: map['reason'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}
