class Supplier {
  final String? id;
  final String name;
  final String address;
  final String contact;
  final double latitude;
  final double longitude;
  final String userId;

  Supplier({
    this.id,
    required this.name,
    required this.address,
    required this.contact,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'contact': contact,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': userId,
    };
  }

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      contact: json['contact'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      userId: json['user_id'],
    );
  }
}