// business_model.dart
class BusinessModel {
  String id;
  String ownerId;
  String name;
  String type;
  double expenses; // starting expenses
  String tier; // e.g. 'Small', 'Medium', 'Large'
  double incomePerMinute;


  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.expenses,
    required this.tier,
    required this.incomePerMinute,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'expenses': expenses,
      'tier': tier,
      'incomePerMinute': incomePerMinute,

    };
  }

  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    return BusinessModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      incomePerMinute: (map['incomePerMinute'] ?? 0).toDouble(),
      expenses: (map['expenses'] ?? 0).toDouble(),
      tier: map['tier'],
    );
  }
}
