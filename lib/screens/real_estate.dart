import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/real_estate.dart';
import '../models/real_estate.dart';
import '../services/finances.dart';

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  final RealEstateService _service = RealEstateService();
  final FinanceService _financeService = FinanceService();

  List<RealEstateModel> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _service.getUserRealEstate();
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load properties: $e')),
      );
    }
  }

  Future<void> _buyProperty() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buy New Property'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Property name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(hintText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0;
                if (name.isEmpty || price <= 0) return;
                Navigator.pop(context, {'name': name, 'price': price});
              },
              child: const Text('Buy'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    try {
      await _financeService.updateMultipleBalances({
        'cash': -result['price'],
        'realEstate': result['price'],
      });

      final model = RealEstateModel(
        id: '',
        ownerId: FirebaseAuth.instance.currentUser!.uid,
        name: result['name'],
        type: 'Property',
        price: result['price'],
      );

      await _service.addRealEstate(model);
      await _load();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property purchased')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to purchase property: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return Scaffold(
        body: const Center(child: Text('No properties owned. Buy one!')),
        floatingActionButton: FloatingActionButton(
          onPressed: _buyProperty,
          child: const Icon(Icons.add),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}'),
            trailing: const Icon(Icons.home),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _buyProperty,
        child: const Icon(Icons.add),
      ),
    );
  }
}
