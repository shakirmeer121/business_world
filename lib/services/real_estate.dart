import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/real_estate.dart';

class RealEstateService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('user_real_estate');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<List<RealEstateModel>> getUserRealEstate() async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final snapshot = await _collection.where('ownerId', isEqualTo: uid).get();
    return snapshot.docs
        .map((doc) => RealEstateModel.fromMap({'id': doc.id, ...doc.data() as Map<String, dynamic>}))
        .toList();
  }

  Future<void> addRealEstate(RealEstateModel model) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final data = model.toMap()
      ..['ownerId'] = uid
      ..['createdAt'] = FieldValue.serverTimestamp();

    await _collection.add(data);
  }

  Future<void> deleteRealEstate(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final docRef = _collection.doc(id);
    final doc = await docRef.get();
    if (!doc.exists) throw Exception('Item not found');
    if (doc['ownerId'] != uid) throw Exception('Unauthorized');

    await docRef.delete();
  }
}