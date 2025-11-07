class Item {
  final String? id;
  final String name;
  final int quantity;
  final double price;
  final String category;
  final DateTime createdAt;

  Item({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
      'category': category,
      'createdAt': createdAt,
    };
  }

  factory Item.fromMap(String id, Map<String, dynamic> map) {
    final created = map['createdAt'];
    DateTime createdAt;
    if (created is DateTime) {
      createdAt = created;
    } else if (created is dynamic && created?.toDate != null) {
      createdAt = created.toDate();
    } else {
      createdAt = DateTime.now();
    }
    return Item(
      id: id,
      name: (map['name'] ?? '').toString(),
      quantity: (map['quantity'] ?? 0) is int
          ? map['quantity'] as int
          : int.tryParse((map['quantity'] ?? '0').toString()) ?? 0,
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse((map['price'] ?? '0').toString()) ?? 0.0,
      category: (map['category'] ?? '').toString(),
      createdAt: createdAt,
    );
  }
}
