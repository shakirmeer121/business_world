import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business.dart';

class BusinessDetailScreen extends StatefulWidget {
  final String businessId;

  const BusinessDetailScreen({super.key, required this.businessId});

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
      if (mounted) setState(() {}); // tick countdown
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
    final remainingMs = next.millisecondsSinceEpoch - now.millisecondsSinceEpoch;
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
            'You will receive 75% of capitalization (\$${_business!.totalInvestment.toStringAsFixed(2)}). Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sell')),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || newName == _business!.name) return;

    try {
      await _businessService.updateBusiness(_business!.id, {'name': newName});
      await _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rename failed: $e')),
      );
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
                          _HeaderCard(business: _business!),
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
  const _HeaderCard({required this.business});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primaryContainer, theme.colorScheme.secondaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.business, size: 40, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${business.type} • ${business.tier}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            )
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
    final theme = Theme.of(context);
    TextStyle valueStyle = theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _kv('Income / min', '\$${business.incomePerMinute.toStringAsFixed(2)}', valueStyle)),
                Expanded(child: _kv('Capitalization', '\$${business.totalInvestment.toStringAsFixed(2)}', valueStyle)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _kv('Expansion level', business.expansionLevel.toString(), valueStyle)),
                Expanded(child: _kv('Next expansion cost', '\$${business.nextExpansionCost.toStringAsFixed(2)}', valueStyle)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v, TextStyle valueStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k),
        const SizedBox(height: 4),
        Text(v, style: valueStyle),
      ],
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

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    return '${two(minutes)}:${two(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool available = timeRemaining.inMilliseconds <= 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expansion', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Increase income and capitalization by investing more into this business.'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Next cost: \$${business.nextExpansionCost.toStringAsFixed(2)}', style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 6),
                    available
                        ? const Text('Ready to expand')
                        : Text('Available in ${_formatDuration(timeRemaining)}'),
                  ],
                ),
                FilledButton.icon(
                  onPressed: available ? onExpand : null,
                  icon: const Icon(Icons.upgrade),
                  label: const Text('Expand'),
                ),
              ],
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
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sell Business', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Get 75% of capitalization back in cash.'),
              ],
            ),
            OutlinedButton.icon(
              onPressed: onSell,
              icon: const Icon(Icons.sell),
              label: const Text('Sell'),
            )
          ],
        ),
      ),
    );
  }
}