import 'package:flutter/material.dart';
class PersonalPurchasesScreen extends StatefulWidget {
  const PersonalPurchasesScreen({super.key});

  @override
  State<PersonalPurchasesScreen> createState() => _PersonalPurchasesScreenState();
}

class _PersonalPurchasesScreenState extends State<PersonalPurchasesScreen> {
  final List<String> _items = ['Car', 'House', 'Gym Membership', 'Private Island'];

  final Set<String> _ownedItems = {};

  void _buyItem(String item) {
    if (_ownedItems.contains(item)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You already own $item')),
      );
      return;
    }
    setState(() {
      _ownedItems.add(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchased $item')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final owned = _ownedItems.contains(item);

        return ListTile(
          title: Text(item),
          trailing: owned
              ? const Icon(Icons.check, color: Colors.green)
              : ElevatedButton(
                  onPressed: () => _buyItem(item),
                  child: const Text('Buy'),
                ),
        );
      },
    );
  }
}
