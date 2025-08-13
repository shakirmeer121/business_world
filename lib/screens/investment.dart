import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/investments.dart';
import '../models/investment.dart';
import '../services/finances.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final List<Map<String, dynamic>> _market = [
    {'name': 'Apple Inc.', 'type': 'Stock', 'price': 145.0},
    {'name': 'Bitcoin', 'type': 'Crypto', 'price': 50000.0},
    {'name': 'Tesla', 'type': 'Stock', 'price': 700.0},
    {'name': 'Ethereum', 'type': 'Crypto', 'price': 3500.0},
  ];

  final InvestmentsService _service = InvestmentsService();
  final FinanceService _financeService = FinanceService();

  List<InvestmentModel> _owned = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _service.getUserInvestments();
      setState(() {
        _owned = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load investments: $e')),
      );
    }
  }

  Future<void> _invest(Map<String, dynamic> item) async {
    final controller = TextEditingController();
    final amountStr = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invest in ${item['name']}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Amount to invest'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Invest')),
          ],
        );
      },
    );

    if (amountStr == null) return;
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount <= 0) return;

    try {
      await _financeService.updateMultipleBalances({
        'cash': -amount,
        'stocksBought': amount,
      });

      final model = InvestmentModel(
        id: '',
        investorId: FirebaseAuth.instance.currentUser!.uid,
        businessId: item['name'],
        amount: amount,
        date: DateTime.now(),
      );

      await _service.addInvestment(model);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invested in ${item['name']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to invest: $e')),
      );
    }
  }

  bool _isOwned(String name) => _owned.any((i) => i.businessId == name);

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
          title: Text('${item['name']} (${item['type']})'),
          subtitle: Text('Price: \$${(item['price'] as double).toStringAsFixed(2)}'),
          trailing: owned
              ? const Icon(Icons.check, color: Colors.green)
              : ElevatedButton(
                  onPressed: () => _invest(item),
                  child: const Text('Invest'),
                ),
        );
      },
    );
  }
}
