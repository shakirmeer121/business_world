import 'dart:async';
import 'package:flutter/material.dart';
import '../services/finances.dart';
import '../models/balances.dart';

/// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  late Future<UserFinance?> financeFuture;
  final FinanceService _financeService = FinanceService();

  bool _isAddingCash = false;
  Timer? _accrualTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    financeFuture = _financeService.getUserFinance();
    _applyAccrualAndRefresh();
    _startAccrualTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accrualTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applyAccrualAndRefresh();
    }
  }

  void _startAccrualTimer() {
    _accrualTimer?.cancel();
    // Apply accrual every minute when the dashboard is visible
    _accrualTimer = Timer.periodic(const Duration(minutes: 1), (_) => _applyAccrualAndRefresh());
  }

  Future<void> _applyAccrualAndRefresh() async {
    await _financeService.applyBusinessIncomeAccrual();
    _refreshFinance();
  }

  void _refreshFinance() {
    setState(() {
      financeFuture = _financeService.getUserFinance();
    });
  }

  Future<void> _handleTapAddCash() async {
    if (_isAddingCash) return;

    setState(() {
      _isAddingCash = true;
    });

    try {
      await _financeService.addCash(1.0);
      _refreshFinance();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\$1 added to cash')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add cash: $e')),
      );
    } finally {
      setState(() {
        _isAddingCash = false;
      });
    }
  }

  Widget _buildBalanceRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text('\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserFinance?> (
      future: financeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading balances: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No finance data available.'));
        }

        final finance = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Fortune',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Text('\$${finance.totalFortune.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildBalanceRow('Balance', finance.cash),
                    _buildBalanceRow('Businesses', finance.businesses),
                    _buildBalanceRow('Real Estate', finance.realEstate),
                    _buildBalanceRow('Crypto Assets', finance.cryptoAssets),
                    _buildBalanceRow('Stocks Bought', finance.stocksBought),
                    _buildBalanceRow('Personal Things', finance.personalThings),

                    const SizedBox(height: 30),

                    // Tap box to add $1 to cash balance
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: GestureDetector(
                        onTap: _handleTapAddCash,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isAddingCash
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Tap to add \$1 to Cash',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
