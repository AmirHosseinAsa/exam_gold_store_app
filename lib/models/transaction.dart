class Transaction {
  final int? id;
  final String type; // sell or buy
  final String itemType;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final String customerName;
  final String? customerPhone;
  final String date;
  final String? description;
  final bool isInStoreNow; 
  final int? soldFromTransactionId; 

  Transaction({
    this.id,
    required this.type,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.customerName,
    this.customerPhone,
    required this.date,
    this.description,
    this.isInStoreNow = true, 
    this.soldFromTransactionId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'itemType': itemType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'date': date,
      'description': description,
      'isInStoreNow': isInStoreNow ? 1 : 0,
      'soldFromTransactionId': soldFromTransactionId,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toInt(),
      type: map['type'] ?? '',
      itemType: map['itemType'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unitPrice: map['unitPrice']?.toDouble() ?? 0.0,
      totalPrice: map['totalPrice']?.toDouble() ?? 0.0,
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'],
      date: map['date'] ?? '',
      description: map['description'],
      isInStoreNow: (map['isInStoreNow'] ?? 1) == 1,
      soldFromTransactionId: map['soldFromTransactionId']?.toInt(),
    );
  }

  Transaction copyWith({
    int? id,
    String? type,
    String? itemType,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    String? customerName,
    String? customerPhone,
    String? date,
    String? description,
    bool? isInStoreNow,
    int? soldFromTransactionId,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      date: date ?? this.date,
      description: description ?? this.description,
      isInStoreNow: isInStoreNow ?? this.isInStoreNow,
      soldFromTransactionId: soldFromTransactionId ?? this.soldFromTransactionId,
    );
  }
} 