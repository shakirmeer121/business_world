import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final BusinessService _businessService = BusinessService();

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

  void _openBusiness(BusinessModel business) async {
    await Navigator.pushNamed(
      context,
      '/business_detail',
      arguments: business.id,
    );
    if (!mounted) return;
    await _loadBusinesses();
  }

  Future<void> _sellBusiness(BusinessModel business) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sell Business'),
        content: Text(
          'You will receive 75% of capitalization (\$${business.totalInvestment.toStringAsFixed(2)}). Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sell'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final refund = await _businessService.sellBusiness(business.id);
      await _loadBusinesses();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sold for \$${refund.toStringAsFixed(2)}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sell failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _businesses.isEmpty
              ? const Center(child: Text('No businesses found. Start one!'))
              : RefreshIndicator(
                  onRefresh: _loadBusinesses,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _businesses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final business = _businesses[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.surface,
                                theme.colorScheme.surfaceVariant,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      business.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${business.type} • ${business.tier}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        _StatChip(
                                          label: 'Income/min',
                                          value: '\$${business.incomePerMinute.toStringAsFixed(2)}',
                                          icon: Icons.trending_up,
                                        ),
                                        _StatChip(
                                          label: 'Capitalization',
                                          value: '\$${business.totalInvestment.toStringAsFixed(2)}',
                                          icon: Icons.paid,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _openBusiness(business),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Open'),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _sellBusiness(business),
                                    icon: const Icon(Icons.sell),
                                    label: const Text('Sell'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
