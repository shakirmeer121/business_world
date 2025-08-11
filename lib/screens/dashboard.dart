import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// UserFinance model
class UserFinance {
  final double cash;
  final double businesses;
  final double realEstate;
  final double cryptoAssets;
  final double stocksBought;
  final double personalThings;

  UserFinance({
    required this.cash,
    required this.businesses,
    required this.realEstate,
    required this.cryptoAssets,
    required this.stocksBought,
    required this.personalThings,
  });

  double get totalFortune =>
      cash + businesses + realEstate + cryptoAssets + stocksBought + personalThings;

  factory UserFinance.fromMap(Map<String, dynamic> data) {
    return UserFinance(
      cash: (data['cash'] ?? 0).toDouble(),
      businesses: (data['businesses'] ?? 0).toDouble(),
      realEstate: (data['realEstate'] ?? 0).toDouble(),
      cryptoAssets: (data['cryptoAssets'] ?? 0).toDouble(),
      stocksBought: (data['stocksBought'] ?? 0).toDouble(),
      personalThings: (data['personalThings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'cash': cash,
        'businesses': businesses,
        'realEstate': realEstate,
        'cryptoAssets': cryptoAssets,
        'stocksBought': stocksBought,
        'personalThings': personalThings,
      };

  factory UserFinance.zero() => UserFinance(
        cash: 0,
        businesses: 0,
        realEstate: 0,
        cryptoAssets: 0,
        stocksBought: 0,
        personalThings: 0,
      );
}

/// FinanceService to handle Firestore
class FinanceService {
  final CollectionReference _financeCollection =
      FirebaseFirestore.instance.collection('user_finances');

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

  /// Adds [amount] to the 'cash' field atomically in Firestore
  Future<void> addCash(double amount) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final docRef = _financeCollection.doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        transaction.set(docRef, UserFinance.zero().toMap());
      }

      final data = snapshot.data()! as Map<String, dynamic>;
      double currentCash = (data['cash'] ?? 0).toDouble();

      transaction.update(docRef, {'cash': currentCash + amount});
    });
  }
}

/// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<UserFinance?> financeFuture;
  final FinanceService _financeService = FinanceService();

  bool _isAddingCash = false;

  @override
  void initState() {
    super.initState();
    financeFuture = _financeService.getUserFinance();
  }

  void _refreshFinance() {
    setState(() {
      financeFuture = _financeService.getUserFinance();
    });
  }

  Future<void> _handleTapAddCash() async {
    if (_isAddingCash) return;

    setState(() {
      _isAddingCash = true;
    });

    try {
      await _financeService.addCash(1.0);
      _refreshFinance();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\$1 added to cash')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add cash: $e')),
      );
    } finally {
      setState(() {
        _isAddingCash = false;
      });
    }
  }

  Widget _buildBalanceRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text('\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserFinance?>(
      future: financeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading balances: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No finance data available.'));
        }

        final finance = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Overall Balance',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text('\$${finance.totalFortune.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildBalanceRow('Cash', finance.cash),
                    _buildBalanceRow('Businesses', finance.businesses),
                    _buildBalanceRow('Real Estate', finance.realEstate),
                    _buildBalanceRow('Crypto Assets', finance.cryptoAssets),
                    _buildBalanceRow('Stocks Bought', finance.stocksBought),
                    _buildBalanceRow('Personal Things', finance.personalThings),

                    const SizedBox(height: 30),

                    // Tap box to add $1 to cash balance
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GestureDetector(
                        onTap: _handleTapAddCash,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isAddingCash
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Tap here to add \$1 to Cash',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
