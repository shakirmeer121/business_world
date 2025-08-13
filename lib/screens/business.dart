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
    setState(() => _loading = true);
    try {
      final businesses = await _businessService.getUserBusinesses();
      setState(() {
        _businesses = businesses;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading businesses: $e')),
      );
    }
  }

  void _startBusiness() async {
    final selectedBusinessType = await Navigator.pushNamed(
      context,
      '/business_selection',
    ) as String?;

    if (selectedBusinessType != null) {
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

  IconData _getBusinessIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('tech') || t.contains('software')) return Icons.computer;
    if (t.contains('store') || t.contains('shop')) return Icons.storefront;
    if (t.contains('restaurant') || t.contains('food')) return Icons.restaurant;
    if (t.contains('finance') || t.contains('bank')) return Icons.account_balance;
    if (t.contains('real estate') || t.contains('property')) return Icons.business;
    if (t.contains('factory') || t.contains('manufacturing')) return Icons.factory;
    return Icons.work; // default
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
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final business = _businesses[index];
                      return Card(
                        elevation: 5,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openBusiness(business),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      theme.colorScheme.primary.withOpacity(0.1),
                                  child: Icon(
                                    _getBusinessIcon(business.type),
                                    color: theme.colorScheme.primary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        business.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${business.type} • ${business.tier}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _StatChip(
                                            label: 'Income/min',
                                            value:
                                                '\$${business.incomePerMinute.toStringAsFixed(2)}',
                                            icon: Icons.trending_up,
                                          ),
                                          const SizedBox(width: 8),
                                          _StatChip(
                                            label: 'Capitalization',
                                            value:
                                                '\$${business.totalInvestment.toStringAsFixed(2)}',
                                            icon: Icons.paid,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color:
                                      theme.colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ],
                            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
