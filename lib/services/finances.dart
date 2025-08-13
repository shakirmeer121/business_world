import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/balances.dart';

class FinanceService {
  final CollectionReference _financeCollection =
      FirebaseFirestore.instance.collection('user_finances');

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
        throw Exception("User finance doc not found");
      }

      final data = snapshot.data()! as Map<String, dynamic>;
      double currentBalance = (data[category] ?? 0).toDouble();
      double newBalance = currentBalance + amount;

      if (newBalance < 0) {
        throw Exception("Insufficient funds in $category");
      }

      transaction.update(docRef, {category: newBalance});
    });
  }

  /// Update multiple categories
  Future<void> updateMultipleBalances(Map<String, double> changes) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception("User finance doc not found");
      }

      final data = Map<String, dynamic>.from(snapshot.data()! as Map<String, dynamic>);

      changes.forEach((field, amount) {
        final currentValue = (data[field] ?? 0).toDouble();
        final newValue = currentValue + amount;
        if (newValue < 0) {
          throw Exception("Insufficient funds in $field");
        }
        data[field] = newValue;
      });

      transaction.update(docRef, data);
    });
  }

  /// Add or subtract cash
  Future<void> addCash(double amount) async {
    await updateBalance('cash', amount);
  }

  /// Start a specific business and track its fortune
  Future<void> startBusiness(String businessName, double cost, double fortune) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception("User finance doc not found");
      }

      final data = Map<String, dynamic>.from(snapshot.data()! as Map<String, dynamic>);
      double currentCash = (data['cash'] ?? 0).toDouble();

      if (currentCash < cost) {
        throw Exception("Not enough cash to start this business");
      }

      // Deduct cash
      data['cash'] = currentCash - cost;

      // Update business fortune
      final businesses = Map<String, dynamic>.from(data['businesses'] ?? {});
      final currentFortune = (businesses[businessName]?['fortune'] ?? 0).toDouble();
      businesses[businessName] = {
        'fortune': currentFortune + fortune,
        'income_per_hour': businesses[businessName]?['income_per_hour'] ?? 0
      };

      data['businesses'] = businesses;

      transaction.update(docRef, data);
    });
  }

  /// Apply income from all businesses
  Future<void> applyHourlyIncome() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception("User finance doc not found");
      }

      final data = Map<String, dynamic>.from(snapshot.data()! as Map<String, dynamic>);
      double currentCash = (data['cash'] ?? 0).toDouble();
      double totalIncome = 0;

      if (data['businesses'] != null) {
        final businesses = Map<String, dynamic>.from(data['businesses']);
        businesses.forEach((_, b) {
          totalIncome += (b['income_per_hour'] ?? 0).toDouble();
        });
      }

      data['cash'] = currentCash + totalIncome;
      transaction.update(docRef, data);
    });
  }
}
