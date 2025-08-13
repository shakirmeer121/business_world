// real_estate_model.dart
class RealEstateModel {
  String id;
  String ownerId;
  String name;
  String type; // e.g., Apartment, House
  double price;
  double incomePerMinute; // optional passive income, default 0

  RealEstateModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.price,
    this.incomePerMinute = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'price': price,
      'incomePerMinute': incomePerMinute,
    };
  }

  factory RealEstateModel.fromMap(Map<String, dynamic> map) {
    return RealEstateModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      incomePerMinute: (map['incomePerMinute'] ?? 0).toDouble(),
    );
  }
}
