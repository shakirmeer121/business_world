// tax_record_model.dart
class TaxRecordModel {
  String id;
  String businessId;
  double amount;
  DateTime date;

  TaxRecordModel({
    required this.id,
    required this.businessId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory TaxRecordModel.fromMap(Map<String, dynamic> map) {
    return TaxRecordModel(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
