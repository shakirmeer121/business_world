import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/business.dart';

class BusinessService {
  final CollectionReference _businessCollection =
      FirebaseFirestore.instance.collection('user_businesses');

  Future<List<BusinessModel>> getUserBusinesses() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final querySnapshot = await _businessCollection.where('ownerId', isEqualTo: uid).get();

    return querySnapshot.docs
        .map((doc) => BusinessModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBusiness(BusinessModel business) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await _businessCollection.add({
      'ownerId': uid,
      ...business.toMap(),
    });
  }

  Future<void> deleteBusiness(String id) async {
    await _businessCollection.doc(id).delete();
  }
}
