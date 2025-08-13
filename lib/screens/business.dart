import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business.dart';
import '../services/finances.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final BusinessService _businessService = BusinessService();
  final FinanceService _financeService = FinanceService();

  List<BusinessModel> _businesses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBusinesses();
  }

  Future<void> _loadBusinesses() async {
    setState(() {
      _loading = true;
    });
    try {
      final businesses = await _businessService.getUserBusinesses();
      setState(() {
        _businesses = businesses;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading businesses: $e')),
      );
    }
  }

  // Navigate to BusinessSelectionScreen
  void _startBusiness() async {
    final selectedBusinessType = await Navigator.pushNamed(
      context,
      '/business_selection',
    ) as String?;

    if (selectedBusinessType != null) {
      // Navigate to BusinessTierScreen passing the selected business type
      final started = await Navigator.pushNamed(
        context,
        '/business_tier',
        arguments: selectedBusinessType,
      ) as bool?;

      if (started == true) {
        await _loadBusinesses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business started successfully')),
        );
      }
    }
  }

  void _mergeBusinesses() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Merge Businesses feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _businesses.isEmpty
              ? const Center(child: Text('No businesses found. Start one!'))
              : ListView.builder(
                  itemCount: _businesses.length,
                  itemBuilder: (context, index) {
                    final business = _businesses[index];
                    return ListTile(
                      title: Text(business.name),
                      subtitle: Text(
                        'Income/min: \$${business.incomePerMinute.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _businessService.deleteBusiness(business.id);
                          await _loadBusinesses();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _startBusiness,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start a Business'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _mergeBusinesses,
            icon: const Icon(Icons.merge_type),
            label: const Text('Merge Businesses'),
          ),
        ],
      ),
    );
  }
}
