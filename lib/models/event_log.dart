// event_log_model.dart
class EventLogModel {
  String id;
  String userId;
  String description;
  DateTime timestamp;

  EventLogModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory EventLogModel.fromMap(Map<String, dynamic> map) {
    return EventLogModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      description: map['description'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
