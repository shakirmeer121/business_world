import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModel {
  String id;
  String ownerId;
  String name;
  String type;
  double expenses; // starting expenses
  String tier; // e.g. 'Small', 'Medium', 'Large'
  double incomePerMinute;
  double totalInvestment; // cumulative invested amount (capitalization)
  int expansionLevel; // number of expansions applied
  double nextExpansionCost; // cost required for the next expansion
  Timestamp? nextExpansionAvailableAt; // when next expansion becomes available

  BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.expenses,
    required this.tier,
    required this.incomePerMinute,
    required this.totalInvestment,
    required this.expansionLevel,
    required this.nextExpansionCost,
    this.nextExpansionAvailableAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'type': type,
      'expenses': expenses,
      'tier': tier,
      'incomePerMinute': incomePerMinute,
      'totalInvestment': totalInvestment,
      'expansionLevel': expansionLevel,
      'nextExpansionCost': nextExpansionCost,
      'nextExpansionAvailableAt': nextExpansionAvailableAt,
    };
  }

  factory BusinessModel.fromMap(Map<String, dynamic> map) {
    final double expenses = (map['expenses'] ?? 0).toDouble();
    final double incomePerMinute = (map['incomePerMinute'] ?? 0).toDouble();

    // Derive sane defaults for backward compatibility with older docs
    final double totalInvestment = (map['totalInvestment'] ?? expenses).toDouble();
    final int expansionLevel = (map['expansionLevel'] ?? 0).toInt();
    final double nextExpansionCost = (map['nextExpansionCost'] ?? (expenses * 0.5)).toDouble();

    return BusinessModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      expenses: expenses,
      tier: map['tier'] ?? '',
      incomePerMinute: incomePerMinute,
      totalInvestment: totalInvestment,
      expansionLevel: expansionLevel,
      nextExpansionCost: nextExpansionCost,
      nextExpansionAvailableAt: map['nextExpansionAvailableAt'] is Timestamp ? map['nextExpansionAvailableAt'] : null,
    );
  }
}
