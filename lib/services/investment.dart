import 'firebase_service.dart';

class InvestmentService {
  final FirebaseService _firebaseService = FirebaseService();
  final String collection = "investments";

  Future<String> createInvestment(Map<String, dynamic> investmentData) async {
    return await _firebaseService.addDocument(collection, investmentData);
  }

  Future<Map<String, dynamic>?> getInvestment(String investmentId) async {
    return await _firebaseService.getDocument(collection, investmentId);
  }

  Future<List<Map<String, dynamic>>> getAllInvestments() async {
    return await _firebaseService.getAllDocuments(collection);
  }

  Future<void> updateInvestment(String investmentId, Map<String, dynamic> updates) async {
    await _firebaseService.updateDocument(collection, investmentId, updates);
  }

  Future<void> deleteInvestment(String investmentId) async {
    await _firebaseService.deleteDocument(collection, investmentId);
  }

  Stream<List<Map<String, dynamic>>> listenInvestments() {
    return _firebaseService.listenToCollection(collection);
  }
}
