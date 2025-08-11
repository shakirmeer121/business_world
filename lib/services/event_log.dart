import 'firebase_service.dart';

class EventLogService {
  final FirebaseService _firebaseService = FirebaseService();
  final String collection = "eventLogs";

  Future<String> createEventLog(Map<String, dynamic> eventLogData) async {
    return await _firebaseService.addDocument(collection, eventLogData);
  }

  Future<Map<String, dynamic>?> getEventLog(String eventLogId) async {
    return await _firebaseService.getDocument(collection, eventLogId);
  }

  Future<List<Map<String, dynamic>>> getAllEventLogs() async {
    return await _firebaseService.getAllDocuments(collection);
  }

  Future<void> updateEventLog(String eventLogId, Map<String, dynamic> updates) async {
    await _firebaseService.updateDocument(collection, eventLogId, updates);
  }

  Future<void> deleteEventLog(String eventLogId) async {
    await _firebaseService.deleteDocument(collection, eventLogId);
  }

  Stream<List<Map<String, dynamic>>> listenEventLogs() {
    return _firebaseService.listenToCollection(collection);
  }
}

