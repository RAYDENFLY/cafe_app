class CartItem {
  int? id;
  String itemName;
  String itemType; // 'food' or 'drink'
  int itemId;
  int quantity;
  double price;
  double totalPrice;

  CartItem({
    this.id,
    required this.itemName,
    required this.itemType,
    required this.itemId,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemName': itemName,
      'itemType': itemType,
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      itemName: map['itemName'],
      itemType: map['itemType'],
      itemId: map['itemId'],
      quantity: map['quantity'],
      price: map['price'],
      totalPrice: map['totalPrice'],
    );
  }

  CartItem copyWith({
    int? id,
    String? itemName,
    String? itemType,
    int? itemId,
    int? quantity,
    double? price,
    double? totalPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
