import 'dart:async';
import 'package:flutter/material.dart';
import '../services/finances.dart';
import '../models/balances.dart';
import '../utilis/number_format.dart';

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
    _accrualTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _applyAccrualAndRefresh(),
    );
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

  Widget _buildBalanceCard(String title, double amount, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<UserFinance?>(
      future: financeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading balances: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('No finance data available.'));
        }

        final finance = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Fortune',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${finance.totalFortune.shorten().toStringAsFixed(2)}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      _buildBalanceCard('Balance', finance.cash.shorten(), Icons.account_balance_wallet, Colors.green),
                      _buildBalanceCard('Businesses', finance.businesses.shorten(), Icons.store, Colors.blue),
                      _buildBalanceCard('Real Estate', finance.realEstate.shorten(), Icons.home_work, Colors.orange),
                      _buildBalanceCard('Crypto Assets', finance.cryptoAssets.shorten(), Icons.currency_bitcoin, Colors.purple),
                      _buildBalanceCard('Stocks Bought', finance.stocksBought.shorten(), Icons.show_chart, Colors.teal),
                      _buildBalanceCard('Personal Things', finance.personalThings.shorten(), Icons.chair_alt, Colors.brown),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _handleTapAddCash,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepPurple, Colors.purpleAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
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
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Tap to add \$1 to Cash',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
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
          ),
        );
      },
    );
  }
}
