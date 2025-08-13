import 'package:cloud_firestore/cloud_firestore.dart';

class UserFinance {
  final double cash;
  final double businesses;
  final double realEstate;
  final double cryptoAssets;
  final double stocksBought;
  final double personalThings;
  final Timestamp? lastUpdated;

  UserFinance({
    required this.cash,
    required this.businesses,
    required this.realEstate,
    required this.cryptoAssets,
    required this.stocksBought,
    required this.personalThings,
    this.lastUpdated,
  });

  /// Calculate total fortune from all assets
  double get totalFortune =>
      cash +
      businesses +
      realEstate +
      cryptoAssets +
      stocksBought +
      personalThings;

  /// Convert Firestore map to UserFinance
  factory UserFinance.fromMap(Map<String, dynamic> data) {
    return UserFinance(
      cash: (data['cash'] ?? 0).toDouble(),
      businesses: (data['businesses'] ?? 0).toDouble(),
      realEstate: (data['realEstate'] ?? 0).toDouble(),
      cryptoAssets: (data['cryptoAssets'] ?? 0).toDouble(),
      stocksBought: (data['stocksBought'] ?? 0).toDouble(),
      personalThings: (data['personalThings'] ?? 0).toDouble(),
      lastUpdated: data['lastUpdated'] is Timestamp
          ? data['lastUpdated']
          : null,
    );
  }

  /// Convert UserFinance to Firestore map
  Map<String, dynamic> toMap() => {
        'cash': cash,
        'businesses': businesses,
        'realEstate': realEstate,
        'cryptoAssets': cryptoAssets,
        'stocksBought': stocksBought,
        'personalThings': personalThings,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

  /// Create an empty finance object
  factory UserFinance.zero() => UserFinance(
        cash: 0,
        businesses: 0,
        realEstate: 0,
        cryptoAssets: 0,
        stocksBought: 0,
        personalThings: 0,
      );

  /// Create a copy with updated values
  UserFinance copyWith({
    double? cash,
    double? businesses,
    double? realEstate,
    double? cryptoAssets,
    double? stocksBought,
    double? personalThings,
    Timestamp? lastUpdated,
  }) {
    return UserFinance(
      cash: cash ?? this.cash,
      businesses: businesses ?? this.businesses,
      realEstate: realEstate ?? this.realEstate,
      cryptoAssets: cryptoAssets ?? this.cryptoAssets,
      stocksBought: stocksBought ?? this.stocksBought,
      personalThings: personalThings ?? this.personalThings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
