import 'firebase_service.dart';

class UserService {
  final FirebaseService _firebaseService = FirebaseService();
  final String collection = "users";

  Future<String> createUser(Map<String, dynamic> userData) async {
    return await _firebaseService.addDocument(collection, userData);
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    return await _firebaseService.getDocument(collection, userId);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _firebaseService.getAllDocuments(collection);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await _firebaseService.updateDocument(collection, userId, updates);
  }

  Future<void> deleteUser(String userId) async {
    await _firebaseService.deleteDocument(collection, userId);
  }

  Stream<List<Map<String, dynamic>>> listenUsers() {
    return _firebaseService.listenToCollection(collection);
  }
}
