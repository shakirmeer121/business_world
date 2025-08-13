import 'package:flutter/material.dart';
import '../data/business_definitions.dart';
import '../services/finances.dart'; // your FinanceService
import '../services/business.dart'; // your BusinessService
import '../models/business.dart'; // your BusinessModel
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessTierSelectionScreen extends StatefulWidget {
  final String businessType;

  const BusinessTierSelectionScreen({super.key, required this.businessType});

  @override
  State<BusinessTierSelectionScreen> createState() => _BusinessTierSelectionScreenState();
}

class _BusinessTierSelectionScreenState extends State<BusinessTierSelectionScreen> {
  final FinanceService _financeService = FinanceService();
  final BusinessService _businessService = BusinessService();

  String? _selectedTier;

  @override
  void initState() {
    super.initState();
    _selectedTier = businessOptions[widget.businessType]![0].tier;
  }

  Future<void> _startBusiness() async {
    final selectedOption = businessOptions[widget.businessType]!
        .firstWhere((opt) => opt.tier == _selectedTier);

    final finance = await _financeService.getUserFinance();
    if (finance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching finance data')),
      );
      return;
    }

    if (finance.cash < selectedOption.startupCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Insufficient cash. Need \$${selectedOption.startupCost.toStringAsFixed(2)}')),
      );
      return;
    }

    // Deduct cash and add to businesses asset
    await _financeService.updateMultipleBalances({
      'cash': -selectedOption.startupCost,
      'businesses': selectedOption.startupCost,
    });
    // Create business model
    final newBusiness = BusinessModel(
      id: '', // Firestore will generate
      ownerId: FirebaseAuth.instance.currentUser!.uid,
      name: selectedOption.name,
      type: widget.businessType,
      tier: selectedOption.tier,
      expenses: selectedOption.startupCost,
      incomePerMinute: selectedOption.incomePerMinute,
      totalInvestment: selectedOption.startupCost,
      expansionLevel: 0,
      nextExpansionCost: selectedOption.startupCost * 0.5,
      nextExpansionAvailableAt: Timestamp.now(),
    );

    await _businessService.addBusiness(newBusiness);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business started successfully!')),
    );

    Navigator.pushReplacementNamed(context, '/business');
  }

  @override
  Widget build(BuildContext context) {
    final options = businessOptions[widget.businessType]!;

    return Scaffold(
      appBar: AppBar(title: Text('Choose Tier for ${widget.businessType}')),
      body: Column(
        children: [
          ...options.map((option) {
            return RadioListTile<String>(
              title: Text(
                  '${option.tier} - Startup: \$${option.startupCost.toStringAsFixed(2)}, Income/min: \$${option.incomePerMinute.toStringAsFixed(2)}'),
              value: option.tier,
              groupValue: _selectedTier,
              onChanged: (value) {
                setState(() {
                  _selectedTier = value;
                });
              },
            );
          }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startBusiness,
            child: const Text('Start Business'),
          ),
        ],
      ),
    );
  }
}
