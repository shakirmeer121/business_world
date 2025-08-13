import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/business.dart';

class BusinessService {
  final CollectionReference _businessCollection =
      FirebaseFirestore.instance.collection('user_businesses');

  final CollectionReference _financeCollection =
      FirebaseFirestore.instance.collection('user_finances');

  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;

  /// Tuning parameters for business progression
  static const double expansionIncomeIncreaseFactor = 0.20; // +20% income per expansion
  static const double expansionCostIncreaseFactor = 1.5; // next cost grows by 1.5x
  static const Duration expansionCooldown = Duration(minutes: 10); // time between expansions

  /// Fetch all businesses for the current user
  Future<List<BusinessModel>> getUserBusinesses() async {
    final uid = _currentUserId;
    if (uid == null) throw Exception("User not logged in");

    try {
      final querySnapshot = await _businessCollection
          .where('ownerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return BusinessModel.fromMap({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }).toList();
    } on FirebaseException catch (e) {
      // Fallback when composite index is missing: fetch without order and sort client-side
      if (e.code == 'failed-precondition') {
        final querySnapshot = await _businessCollection
            .where('ownerId', isEqualTo: uid)
            .get();

        final docs = querySnapshot.docs.toList();
        docs.sort((a, b) {
          final aTs = a.data().containsKey('createdAt') && a['createdAt'] is Timestamp
              ? (a['createdAt'] as Timestamp).millisecondsSinceEpoch
              : 0;
          final bTs = b.data().containsKey('createdAt') && b['createdAt'] is Timestamp
              ? (b['createdAt'] as Timestamp).millisecondsSinceEpoch
              : 0;
          return bTs.compareTo(aTs); // desc
        });

        return docs.map((doc) {
          return BusinessModel.fromMap({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          });
        }).toList();
      }
      rethrow;
    }
  }

  /// Fetch single business by id
  Future<BusinessModel> getBusinessById(String id) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception("User not logged in");

    final docRef = _businessCollection.doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw Exception('Business not found');
    }
    final data = doc.data() as Map<String, dynamic>;
    if (data['ownerId'] != uid) {
      throw Exception('Unauthorized');
    }
    return BusinessModel.fromMap({...data, 'id': doc.id});
  }

  /// Add a new business
  Future<void> addBusiness(BusinessModel business) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception("User not logged in");

    final initialTotalInvestment = business.totalInvestment == 0
        ? business.expenses
        : business.totalInvestment;

    final data = business.toMap()
      ..remove('id')
      ..['ownerId'] = uid
      ..['totalInvestment'] = initialTotalInvestment
      ..['expansionLevel'] = business.expansionLevel
      ..['nextExpansionCost'] = business.nextExpansionCost
      ..['nextExpansionAvailableAt'] = business.nextExpansionAvailableAt ?? FieldValue.serverTimestamp()
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

  /// Expand a business: deduct cost from cash, add to businesses asset, increase income, schedule next expansion
  Future<void> expandBusiness(String id) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not logged in');

    final businessRef = _businessCollection.doc(id);
    final financeRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final businessSnap = await transaction.get(businessRef);
      if (!businessSnap.exists) {
        throw Exception('Business not found');
      }
      final b = businessSnap.data() as Map<String, dynamic>;
      if (b['ownerId'] != uid) {
        throw Exception('Unauthorized');
      }

      final financeSnap = await transaction.get(financeRef);
      if (!financeSnap.exists) {
        throw Exception('User finance doc not found');
      }

      final finance = Map<String, dynamic>.from(financeSnap.data()! as Map<String, dynamic>);
      final double cash = (finance['cash'] ?? 0).toDouble();

      final double nextCost = (b['nextExpansionCost'] ?? ((b['expenses'] ?? 0).toDouble() * 0.5)).toDouble();
      final Timestamp now = Timestamp.now();
      final Timestamp? availableAt = b['nextExpansionAvailableAt'] is Timestamp ? b['nextExpansionAvailableAt'] as Timestamp : null;

      if (availableAt != null && now.millisecondsSinceEpoch < availableAt.millisecondsSinceEpoch) {
        throw Exception('Expansion not available yet');
      }

      if (cash < nextCost) {
        throw Exception('Insufficient cash');
      }

      // Update finance balances
      finance['cash'] = cash - nextCost;
      finance['businesses'] = ((finance['businesses'] ?? 0).toDouble()) + nextCost;

      // Update business
      final double currentIncomePerMinute = (b['incomePerMinute'] ?? 0).toDouble();
      final double newIncomePerMinute = currentIncomePerMinute * (1 + expansionIncomeIncreaseFactor);
      final double currentInvestment = (b['totalInvestment'] ?? (b['expenses'] ?? 0)).toDouble();
      final int currentLevel = (b['expansionLevel'] ?? 0).toInt();

      final Map<String, dynamic> updates = {
        'incomePerMinute': newIncomePerMinute,
        'totalInvestment': currentInvestment + nextCost,
        'expansionLevel': currentLevel + 1,
        'nextExpansionCost': nextCost * expansionCostIncreaseFactor,
        'nextExpansionAvailableAt': Timestamp.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch + expansionCooldown.inMilliseconds),
      };

      transaction.update(financeRef, finance);
      transaction.update(businessRef, updates);
    });
  }

  /// Sell a business: refund 75% of totalInvestment, remove business, update finances
  Future<double> sellBusiness(String id) async {
    final uid = _currentUserId;
    if (uid == null) throw Exception('User not logged in');

    final businessRef = _businessCollection.doc(id);
    final financeRef = _financeCollection.doc(uid);

    double refund = 0;

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final businessSnap = await transaction.get(businessRef);
      if (!businessSnap.exists) {
        throw Exception('Business not found');
      }
      final b = businessSnap.data() as Map<String, dynamic>;
      if (b['ownerId'] != uid) {
        throw Exception('Unauthorized');
      }

      final financeSnap = await transaction.get(financeRef);
      if (!financeSnap.exists) {
        throw Exception('User finance doc not found');
      }

      final finance = Map<String, dynamic>.from(financeSnap.data()! as Map<String, dynamic>);

      final double totalInvestment = (b['totalInvestment'] ?? (b['expenses'] ?? 0)).toDouble();
      refund = totalInvestment * 0.75;

      // Update finances
      finance['cash'] = ((finance['cash'] ?? 0).toDouble()) + refund;
      finance['businesses'] = ((finance['businesses'] ?? 0).toDouble()) - totalInvestment;

      if ((finance['businesses'] as num).toDouble() < 0) {
        finance['businesses'] = 0.0; // guard against negative due to legacy data mismatch
      }

      transaction.update(financeRef, finance);
      transaction.delete(businessRef);
    });

    return refund;
  }
}
