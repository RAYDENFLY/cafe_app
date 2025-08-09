class Transaction {
  int? id;
  DateTime date;
  double totalAmount;
  String paymentMethod; // 'cash', 'transfer', 'qris'
  double? cashAmount;
  double? change;
  String? bankAccount;
  String? qrisCode;
  List<TransactionItem> items;
  String? invoiceNumber;
  int? memberId;
  String? memberName;

  Transaction({
    this.id,
    required this.date,
    required this.totalAmount,
    required this.paymentMethod,
    this.cashAmount,
    this.change,
    this.bankAccount,
    this.qrisCode,
    required this.items,
    this.invoiceNumber,
    this.memberId,
    this.memberName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'cashAmount': cashAmount,
      'change': change,
      'bankAccount': bankAccount,
      'qrisCode': qrisCode,
      'invoiceNumber': invoiceNumber,
      'memberId': memberId,
      'memberName': memberName,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      date: DateTime.parse(map['date']),
      totalAmount: map['totalAmount'],
      paymentMethod: map['paymentMethod'],
      cashAmount: map['cashAmount'],
      change: map['change'],
      bankAccount: map['bankAccount'],
      qrisCode: map['qrisCode'],
      items: [],
      invoiceNumber: map['invoiceNumber'],
      memberId: map['memberId'],
      memberName: map['memberName'],
    );
  }

  // Getter untuk kompatibilitas dengan provider
  DateTime get createdAt => date;

  Transaction copyWith({
    int? id,
    DateTime? date,
    double? totalAmount,
    String? paymentMethod,
    double? cashAmount,
    double? change,
    String? bankAccount,
    String? qrisCode,
    List<TransactionItem>? items,
    String? invoiceNumber,
    int? memberId,
    String? memberName,
  }) {
    return Transaction(
      id: id ?? this.id,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cashAmount: cashAmount ?? this.cashAmount,
      change: change ?? this.change,
      bankAccount: bankAccount ?? this.bankAccount,
      qrisCode: qrisCode ?? this.qrisCode,
      items: items ?? this.items,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
    );
  }
}

class TransactionItem {
  int? id;
  int transactionId;
  String itemName;
  String itemType;
  int itemId;
  int quantity;
  double price;
  double totalPrice;

  TransactionItem({
    this.id,
    required this.transactionId,
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
      'transactionId': transactionId,
      'itemName': itemName,
      'itemType': itemType,
      'itemId': itemId,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'],
      transactionId: map['transactionId'],
      itemName: map['itemName'],
      itemType: map['itemType'],
      itemId: map['itemId'],
      quantity: map['quantity'],
      price: map['price'],
      totalPrice: map['totalPrice'],
    );
  }
}
