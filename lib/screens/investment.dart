import 'package:flutter/material.dart';
class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final List<Map<String, dynamic>> _investments = [
    {'name': 'Apple Inc.', 'type': 'Stock', 'price': 145},
    {'name': 'Bitcoin', 'type': 'Crypto', 'price': 50000},
    {'name': 'Tesla', 'type': 'Stock', 'price': 700},
    {'name': 'Ethereum', 'type': 'Crypto', 'price': 3500},
  ];

  void _invest(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invested in ${_investments[index]['name']}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _investments.length,
      itemBuilder: (context, index) {
        final item = _investments[index];
        return ListTile(
          title: Text('${item['name']} (${item['type']})'),
          subtitle: Text('Price: \$${item['price']}'),
          trailing: ElevatedButton(
            onPressed: () => _invest(index),
            child: const Text('Invest'),
          ),
        );
      },
    );
  }
}
