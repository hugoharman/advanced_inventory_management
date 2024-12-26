class History {
  final String? id;  // Changed from int? to String? for UUID
  final String itemId;  // Changed from int to String for UUID
  final String itemName;
  final String type;
  final int quantity;
  final String date;

  History({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,  // Changed to match Supabase snake_case
      'item_name': itemName,  // Changed to match Supabase snake_case
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      id: map['id'],
      itemId: map['item_id'],  // Changed to match Supabase snake_case
      itemName: map['item_name'],  // Changed to match Supabase snake_case
      type: map['type'],
      quantity: map['quantity'],
      date: map['date'],
    );
  }

  factory History.fromJson(Map<String, dynamic> json) => History.fromMap(json);
}