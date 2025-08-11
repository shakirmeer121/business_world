import 'firebase_service.dart';

class TaxRecordService {
  final FirebaseService _firebaseService = FirebaseService();
  final String collection = "taxRecords";

  Future<String> createTaxRecord(Map<String, dynamic> taxData) async {
    return await _firebaseService.addDocument(collection, taxData);
  }

  Future<Map<String, dynamic>?> getTaxRecord(String taxId) async {
    return await _firebaseService.getDocument(collection, taxId);
  }

  Future<List<Map<String, dynamic>>> getAllTaxRecords() async {
    return await _firebaseService.getAllDocuments(collection);
  }

  Future<void> updateTaxRecord(String taxId, Map<String, dynamic> updates) async {
    await _firebaseService.updateDocument(collection, taxId, updates);
  }

  Future<void> deleteTaxRecord(String taxId) async {
    await _firebaseService.deleteDocument(collection, taxId);
  }

  Stream<List<Map<String, dynamic>>> listenTaxRecords() {
    return _firebaseService.listenToCollection(collection);
  }
}
