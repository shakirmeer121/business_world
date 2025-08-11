import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/balances.dart';

class FinanceService {
  final CollectionReference _financeCollection =
      FirebaseFirestore.instance.collection('user_finances');

  /// Fetch UserFinance for current user
  Future<UserFinance?> getUserFinance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _financeCollection.doc(uid).get();
    if (doc.exists) {
      return UserFinance.fromMap(doc.data()! as Map<String, dynamic>);
    } else {
      final newFinance = UserFinance.zero();
      await _financeCollection.doc(uid).set(newFinance.toMap());
      return newFinance;
    }
  }

  /// Update balance by adding or subtracting an amount in the given category
  /// amount can be positive (to add) or negative (to subtract)
  Future<void> updateBalance(String category, double amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) throw Exception("User finance doc not found");

      final data = snapshot.data()! as Map<String, dynamic>;
      double currentBalance = (data[category] ?? 0).toDouble();

      double newBalance = currentBalance + amount;
      if (newBalance < 0) {
        throw Exception("Insufficient funds in $category");
      }

      transaction.update(docRef, {category: newBalance});
    });
  }

  /// Convenience method to add cash (positive or negative)
  Future<void> addCash(double amount) async {
    await updateBalance('cash', amount);
  }
}
