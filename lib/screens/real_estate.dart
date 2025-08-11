import 'package:flutter/material.dart';
class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  final List<String> _properties = ['Downtown Apartment', 'Beach House'];

  void _buyProperty() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buy New Property'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Property name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _properties.add(controller.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Buy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _properties.isEmpty
        ? const Center(child: Text('No properties owned. Buy one!'))
        : Scaffold(
            body: ListView.builder(
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_properties[index]),
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