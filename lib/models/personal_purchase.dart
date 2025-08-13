// personal_purchase_model.dart
class PersonalPurchaseModel {
  String id;
  String ownerId;
  String name;
  double price;
  DateTime purchasedAt;

  PersonalPurchaseModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.price,
    required this.purchasedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'ownerId': ownerId,
        'name': name,
        'price': price,
        'purchasedAt': purchasedAt.toIso8601String(),
      };

  factory PersonalPurchaseModel.fromMap(Map<String, dynamic> map) {
    return PersonalPurchaseModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      purchasedAt: DateTime.tryParse(map['purchasedAt'] ?? '') ?? DateTime.now(),
    );
  }
}