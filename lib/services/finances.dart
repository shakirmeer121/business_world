import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/balances.dart';

class FinanceService {
  final CollectionReference _financeCollection =
      FirebaseFirestore.instance.collection('user_finances');
  final CollectionReference _businessCollection =
      FirebaseFirestore.instance.collection('user_businesses');

  /// Fetch finance or create new
  Future<UserFinance?> getUserFinance() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _financeCollection.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserFinance.fromMap(doc.data()! as Map<String, dynamic>);
    } else {
      final newFinance = UserFinance.zero();
      await _financeCollection.doc(uid).set(newFinance.toMap());
      return newFinance;
    }
  }

  /// Update a single category
  Future<void> updateBalance(String category, double amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        transaction.set(docRef, UserFinance.zero().toMap());
      }

      final data = Map<String, dynamic>.from(
          (snapshot.data() ?? UserFinance.zero().toMap()) as Map<String, dynamic>);
      final double currentBalance = (data[category] ?? 0).toDouble();
      final double newBalance = currentBalance + amount;

      if (newBalance < 0) {
        throw Exception("Insufficient funds in $category");
      }

      transaction.update(docRef, {
        category: newBalance,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Update multiple categories atomically
  Future<void> updateMultipleBalances(Map<String, double> changes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        transaction.set(docRef, UserFinance.zero().toMap());
      }

      final data = Map<String, dynamic>.from(
          (snapshot.data() ?? UserFinance.zero().toMap()) as Map<String, dynamic>);

      changes.forEach((field, amount) {
        final currentValue = (data[field] ?? 0).toDouble();
        final newValue = currentValue + amount;
        if (newValue < 0) {
          throw Exception("Insufficient funds in $field");
        }
        data[field] = newValue;
      });

      data['lastUpdated'] = FieldValue.serverTimestamp();
      transaction.update(docRef, data);
    });
  }

  /// Add or subtract cash
  Future<void> addCash(double amount) async {
    await updateBalance('cash', amount);
  }

  /// Sum of all businesses' income per minute for the current user
  Future<double> getTotalBusinessIncomePerMinute() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0.0;

    final snapshot = await _businessCollection.where('ownerId', isEqualTo: uid).get();
    double total = 0.0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['incomePerMinute'] ?? 0).toDouble();
    }
    return total;
  }

  /// Apply accrued business income since lastUpdated to the 'businesses' balance
  Future<void> applyBusinessIncomeAccrual() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Get the current total income rate outside the transaction
    final double incomePerMinute = await getTotalBusinessIncomePerMinute();
    if (incomePerMinute <= 0) {
      // Still bump lastUpdated to now to avoid accumulating large gaps
      await _financeCollection.doc(uid).update({'lastUpdated': FieldValue.serverTimestamp()});
      return;
    }

    final docRef = _financeCollection.doc(uid);
    final now = Timestamp.now();

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      Map<String, dynamic> data;
      if (!snapshot.exists || snapshot.data() == null) {
        data = UserFinance.zero().toMap();
        transaction.set(docRef, data);
      } else {
        data = Map<String, dynamic>.from(snapshot.data()! as Map<String, dynamic>);
      }

      Timestamp? last = data['lastUpdated'] is Timestamp ? data['lastUpdated'] as Timestamp : null;
      last ??= now;

      final elapsedMs = now.millisecondsSinceEpoch - last.millisecondsSinceEpoch;
      final elapsedMinutes = elapsedMs > 0 ? (elapsedMs ~/ (60 * 1000)) : 0;

      if (elapsedMinutes <= 0) {
        transaction.update(docRef, {'lastUpdated': FieldValue.serverTimestamp()});
        return;
      }

      final double currentBusinesses = (data['businesses'] ?? 0).toDouble();
      final double increment = incomePerMinute * elapsedMinutes;
      final double newBusinesses = currentBusinesses + increment;

      transaction.update(docRef, {
        'businesses': newBusinesses,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
  }
}
