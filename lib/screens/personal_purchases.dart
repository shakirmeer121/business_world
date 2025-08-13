import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/personal_purchases.dart';
import '../models/personal_purchase.dart';
import '../services/finances.dart';

class PersonalPurchasesScreen extends StatefulWidget {
  const PersonalPurchasesScreen({super.key});

  @override
  State<PersonalPurchasesScreen> createState() => _PersonalPurchasesScreenState();
}

class _PersonalPurchasesScreenState extends State<PersonalPurchasesScreen> {
  final List<Map<String, dynamic>> _market = [
    {'name': 'Car', 'price': 10000.0},
    {'name': 'House', 'price': 250000.0},
    {'name': 'Gym Membership', 'price': 500.0},
    {'name': 'Private Island', 'price': 10000000.0},
  ];

  final PersonalPurchasesService _service = PersonalPurchasesService();
  final FinanceService _financeService = FinanceService();

  List<PersonalPurchaseModel> _owned = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _service.getUserPurchases();
      setState(() {
        _owned = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load purchases: $e')),
      );
    }
  }

  Future<void> _buy(Map<String, dynamic> item) async {
    try {
      await _financeService.updateMultipleBalances({
        'cash': -item['price'],
        'personalThings': item['price'],
      });

      final model = PersonalPurchaseModel(
        id: '',
        ownerId: FirebaseAuth.instance.currentUser!.uid,
        name: item['name'],
        price: item['price'],
        purchasedAt: DateTime.now(),
      );

      await _service.addPurchase(model);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchased ${item['name']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase: $e')),
      );
    }
  }

  bool _isOwned(String name) => _owned.any((p) => p.name == name);

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _market.length,
      itemBuilder: (context, index) {
        final item = _market[index];
        final owned = _isOwned(item['name']);

        return ListTile(
          title: Text('${item['name']}'),
          subtitle: Text('Price: \$${(item['price'] as double).toStringAsFixed(2)}'),
          trailing: owned
              ? const Icon(Icons.check, color: Colors.green)
              : ElevatedButton(
                  onPressed: () => _buy(item),
                  child: const Text('Buy'),
                ),
        );
      },
    );
  }
}
