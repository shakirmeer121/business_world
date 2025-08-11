class UserFinance {
  final double cash;
  final double businesses;
  final double realEstate;
  final double cryptoAssets;
  final double stocksBought;
  final double personalThings;

  UserFinance({
    required this.cash,
    required this.businesses,
    required this.realEstate,
    required this.cryptoAssets,
    required this.stocksBought,
    required this.personalThings,
  });

  double get totalFortune =>
      cash + businesses + realEstate + cryptoAssets + stocksBought + personalThings;

  factory UserFinance.fromMap(Map<String, dynamic> data) {
    return UserFinance(
      cash: (data['cash'] ?? 0).toDouble(),
      businesses: (data['businesses'] ?? 0).toDouble(),
      realEstate: (data['realEstate'] ?? 0).toDouble(),
      cryptoAssets: (data['cryptoAssets'] ?? 0).toDouble(),
      stocksBought: (data['stocksBought'] ?? 0).toDouble(),
      personalThings: (data['personalThings'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'cash': cash,
        'businesses': businesses,
        'realEstate': realEstate,
        'cryptoAssets': cryptoAssets,
        'stocksBought': stocksBought,
        'personalThings': personalThings,
      };

  factory UserFinance.zero() => UserFinance(
        cash: 0,
        businesses: 0,
        realEstate: 0,
        cryptoAssets: 0,
        stocksBought: 0,
        personalThings: 0,
      );
}
