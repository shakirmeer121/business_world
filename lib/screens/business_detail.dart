import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessId;

  const BusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final BusinessService _businessService = BusinessService();

  BusinessModel? _business;
  bool _loading = true;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final b = await _businessService.getBusinessById(widget.businessId);
      setState(() {
        _business = b;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Duration _timeUntilNextExpansion() {
    if (_business?.nextExpansionAvailableAt == null) return Duration.zero;
    final now = Timestamp.now();
    final next = _business!.nextExpansionAvailableAt!;
    final remainingMs =
        next.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
    return Duration(milliseconds: remainingMs.clamp(0, 1 << 31));
  }

  Future<void> _expand() async {
    if (_business == null) return;
    try {
      await _businessService.expandBusiness(_business!.id);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business expanded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expansion failed: $e')),
      );
    }
  }

  Future<void> _sell() async {
    if (_business == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sell Business'),
        content: Text(
          'You will receive 75% of capitalization (\$${_business!.totalInvestment.toStringAsFixed(2)}). Continue?',
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
      final refund = await _businessService.sellBusiness(_business!.id);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sold for \$${refund.toStringAsFixed(2)}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sell failed: $e')),
      );
    }
  }

  Future<void> _rename() async {
    if (_business == null) return;
    final controller = TextEditingController(text: _business!.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Business'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == _business!.name) {
      return;
    }

    try {
      await _businessService
          .updateBusiness(_business!.id, {'name': newName});
      await _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rename failed: $e')),
      );
    }
  }

  IconData _getBusinessIcon(String type) {
    switch (type.toLowerCase()) {
      case 'store':
        return Icons.storefront;
      case 'real_estate':
        return Icons.apartment;
      case 'restaurant':
        return Icons.restaurant;
      case 'tech':
        return Icons.computer;
      default:
        return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_business?.name ?? 'Business'),
        actions: [
          IconButton(
            tooltip: 'Rename',
            icon: const Icon(Icons.edit),
            onPressed: _business == null ? null : _rename,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _business == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderCard(
                            business: _business!,
                            icon: _getBusinessIcon(_business!.type),
                          ),
                          const SizedBox(height: 16),
                          _StatsGrid(business: _business!),
                          const SizedBox(height: 16),
                          _ExpansionCard(
                            business: _business!,
                            onExpand: _expand,
                            timeRemaining: _timeUntilNextExpansion(),
                          ),
                          const SizedBox(height: 16),
                          _ActionsCard(onSell: _sell),
                        ],
                      ),
                    ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final BusinessModel business;
  final IconData icon;

  const _HeaderCard({required this.business, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Icon(icon, size: 36, color: Colors.blue.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business.name,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Type: ${business.type}'),
                  Text('Tier: ${business.tier}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final BusinessModel business;

  const _StatsGrid({required this.business});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(title: 'Expenses', value: business.expenses, icon: Icons.money_off),
        _StatCard(title: 'Income/Minute', value: business.incomePerMinute, icon: Icons.attach_money),
        _StatCard(title: 'Investment', value: business.totalInvestment, icon: Icons.trending_up),
        _StatCard(title: 'Expansion', value: business.expansionLevel.toDouble(), icon: Icons.upgrade),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('\$${value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _ExpansionCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onExpand;
  final Duration timeRemaining;

  const _ExpansionCard({
    required this.business,
    required this.onExpand,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = timeRemaining <= Duration.zero;
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds % 60;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expansion Level: ${business.expansionLevel}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Next Expansion Cost: \$${business.nextExpansionCost.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Time until next expansion: ${isReady ? "Ready" : "$minutes min $seconds sec"}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.upgrade),
              onPressed: isReady ? onExpand : null,
              label: const Text('Expand Business'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final VoidCallback onSell;

  const _ActionsCard({required this.onSell});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.sell),
              onPressed: onSell,
              label: const Text('Sell Business'),
            ),
          ],
        ),
      ),
    );
  }
}
