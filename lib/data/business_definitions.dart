// business_definitions.dart

class BusinessOption {
  final String name;               // Business display name
  final String tier;               // Small, Medium, Large, etc.
  final double startupCost;        // Amount to start the business
  final double incomePerMinute;    // Income generated per minute
  final String imageAssetPath;     // Path to image asset (local image)

  BusinessOption({
    required this.name,
    required this.tier,
    required this.startupCost,
    required this.incomePerMinute,
    required this.imageAssetPath,
  });
}

/// Predefined businesses and their tiers/options
final Map<String, List<BusinessOption>> businessOptions = {
  'Shop': [
    BusinessOption(
      name: 'Coffee Shop',
      tier: 'Small',
      startupCost: 100.0,
      incomePerMinute: 5.0,
      imageAssetPath: 'assets/images/coffee_shop.jpg',
    ),
    BusinessOption(
      name: 'Coffee Shop',
      tier: 'Medium',
      startupCost: 500.0,
      incomePerMinute: 25.0,
      imageAssetPath: 'assets/images/medium_coffee_shop.png',
    ),
    BusinessOption(
      name: 'Coffee Shop',
      tier: 'Large',
      startupCost: 1000.0,
      incomePerMinute: 60.0,
      imageAssetPath: 'assets/images/large_coffee_shop.png',
    ),
  ],

  'Tech Startup': [
    BusinessOption(
      name: 'Tech Startup',
      tier: 'Small',
      startupCost: 1000.0,
      incomePerMinute: 50.0,
      imageAssetPath: 'assets/images/small_tech_startup.png',
    ),
    BusinessOption(
      name: 'Tech Startup',
      tier: 'Medium',
      startupCost: 5000.0,
      incomePerMinute: 300.0,
      imageAssetPath: 'assets/images/medium_tech_startup.png',
    ),
    BusinessOption(
      name: 'Tech Startup',
      tier: 'Large',
      startupCost: 10000.0,
      incomePerMinute: 700.0,
      imageAssetPath: 'assets/images/large_tech_startup.png',
    ),
  ],

  // Add more business types below as needed...
  'Restaurant': [
    BusinessOption(
      name: 'Restaurant',
      tier: 'Small',
      startupCost: 300.0,
      incomePerMinute: 15.0,
      imageAssetPath: 'assets/images/small_restaurant.png',
    ),
    BusinessOption(
      name: 'Restaurant',
      tier: 'Medium',
      startupCost: 1500.0,
      incomePerMinute: 80.0,
      imageAssetPath: 'assets/images/medium_restaurant.png',
    ),
    BusinessOption(
      name: 'Restaurant',
      tier: 'Large',
      startupCost: 4000.0,
      incomePerMinute: 200.0,
      imageAssetPath: 'assets/images/large_restaurant.png',
    ),
  ],
};
