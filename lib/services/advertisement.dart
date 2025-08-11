import 'firebase_service.dart';

class AdvertisementService {
  final FirebaseService _firebaseService = FirebaseService();
  final String collection = "advertisements";

  Future<String> createAdvertisement(Map<String, dynamic> adData) async {
    return await _firebaseService.addDocument(collection, adData);
  }

  Future<Map<String, dynamic>?> getAdvertisement(String adId) async {
    return await _firebaseService.getDocument(collection, adId);
  }

  Future<List<Map<String, dynamic>>> getAllAdvertisements() async {
    return await _firebaseService.getAllDocuments(collection);
  }

  Future<void> updateAdvertisement(String adId, Map<String, dynamic> updates) async {
    await _firebaseService.updateDocument(collection, adId, updates);
  }

  Future<void> deleteAdvertisement(String adId) async {
    await _firebaseService.deleteDocument(collection, adId);
  }

  Stream<List<Map<String, dynamic>>> listenAdvertisements() {
    return _firebaseService.listenToCollection(collection);
  }
}
