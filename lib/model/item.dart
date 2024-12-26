class Item {
  final String? id;  // Changed from int? to String? for UUID
  final String name;
  final String photo;
  final String category;
  final int price;
  int stock;

  Item({
    this.id,
    required this.name,
    required this.photo,
    required this.category,
    required this.price,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photo': photo,
      'category': category,
      'price': price,
      'stock': stock,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      photo: map['photo'] ?? '',
      category: map['category'],
      price: map['price'],
      stock: map['stock'],
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) => Item.fromMap(json);
}