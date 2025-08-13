import 'package:flutter/material.dart';
import '../data/business_definitions.dart';

class BusinessSelectionScreen extends StatelessWidget {
  const BusinessSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final businessTypes = businessOptions.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Business Type')),
      body: ListView.builder(
        itemCount: businessTypes.length,
        itemBuilder: (context, index) {
          final businessType = businessTypes[index];
          final image = businessOptions[businessType]![0].imageAssetPath;
          final name = businessOptions[businessType]![0].name;

          return ListTile(
            leading: Image.asset(
              image,
              width: 50,
              height: 50,
              errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 40),
            ),
            title: Text(name),
            subtitle: Text(businessType),
            onTap: () {
              Navigator.pop(context, businessType);
            },
          );
        },
      ),
    );
  }
}
