import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/investment.dart';

class InvestmentsService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('user_investments');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<List<InvestmentModel>> getUserInvestments() async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final snapshot = await _collection.where('ownerId', isEqualTo: uid).get();
    return snapshot.docs
        .map((doc) => InvestmentModel.fromMap({'id': doc.id, ...doc.data() as Map<String, dynamic>}))
        .toList();
  }

  Future<void> addInvestment(InvestmentModel model) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final data = model.toMap()
      ..['ownerId'] = uid
      ..['createdAt'] = FieldValue.serverTimestamp();

    await _collection.add(data);
  }

  Future<void> deleteInvestment(String id) async {
    final uid = _uid;
    if (uid == null) throw Exception('User not logged in');

    final docRef = _collection.doc(id);
    final doc = await docRef.get();
    if (!doc.exists) throw Exception('Item not found');
    if (doc['ownerId'] != uid) throw Exception('Unauthorized');

    await docRef.delete();
  }
}