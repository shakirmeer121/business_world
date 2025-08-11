// investment_model.dart
class InvestmentModel {
  String id;
  String investorId;
  String businessId;
  double amount;
  DateTime date;

  InvestmentModel({
    required this.id,
    required this.investorId,
    required this.businessId,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'investorId': investorId,
      'businessId': businessId,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory InvestmentModel.fromMap(Map<String, dynamic> map) {
    return InvestmentModel(
      id: map['id'] ?? '',
      investorId: map['investorId'] ?? '',
      businessId: map['businessId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
    );
  }
}
