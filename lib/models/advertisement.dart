// advertisement_model.dart
class AdvertisementModel {
  String id;
  String businessId;
  String content;
  double budget;
  DateTime startDate;
  DateTime endDate;

  AdvertisementModel({
    required this.id,
    required this.businessId,
    required this.content,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'content': content,
      'budget': budget,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory AdvertisementModel.fromMap(Map<String, dynamic> map) {
    return AdvertisementModel(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      content: map['content'] ?? '',
      budget: (map['budget'] ?? 0).toDouble(),
      startDate: DateTime.parse(map['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(map['endDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
