import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/business.dart';

class BusinessService {
  final CollectionReference _businessCollection =
      FirebaseFirestore.instance.collection('user_businesses');

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Fetch all businesses for the current user
  Future<List<BusinessModel>> getUserBusinesses() async {
    final uid = _currentUserId;
    if (uid == null) throw Exception("User not logged in");

    final querySnapshot = await _businessCollection
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs.map((doc) {
      return BusinessModel.fromMap({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }).toList();
  }

  /// Add a new business
  Future<void> addBusiness(BusinessModel business) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception("User not logged in");

    final data = business.toMap()
      ..['ownerId'] = uid
      ..['createdAt'] = FieldValue.serverTimestamp();

    await _businessCollection.add(data);
  }

  /// Update an existing business
  Future<void> updateBusiness(String id, Map<String, dynamic> updatedFields) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception("User not logged in");

    final docRef = _businessCollection.doc(id);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception("Business not found");
    }

    if (docSnapshot['ownerId'] != uid) {
      throw Exception("Unauthorized: You can only update your own businesses");
    }

    await docRef.update(updatedFields);
  }

  /// Delete a business
  Future<void> deleteBusiness(String id) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception("User not logged in");

    final docRef = _businessCollection.doc(id);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      throw Exception("Business not found");
    }

    if (docSnapshot['ownerId'] != uid) {
      throw Exception("Unauthorized: You can only delete your own businesses");
    }

    await docRef.delete();
  }
}
