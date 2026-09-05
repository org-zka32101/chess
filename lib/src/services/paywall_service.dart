import 'package:flutter/foundation.dart';

/// Subscription type enumeration
enum SubscriptionType {
  free,
  premium,
  premiumPlus,
}

/// Subscription period
enum SubscriptionPeriod {
  monthly,
  yearly,
  lifetime,
}

/// Subscription status
enum SubscriptionStatus {
  active,
  cancelled,
  expired,
  paused,
  pendingRenewal,
}

/// Subscription model
class Subscription {
  final String id;
  final SubscriptionType type;
  final SubscriptionPeriod period;
  final SubscriptionStatus status;
  final double price;
  final String currency;
  final DateTime startDate;
  final DateTime? expiryDate;
  final bool autoRenew;
  final String? renewalPrice;

  Subscription({
    required this.id,
    required this.type,
    required this.period,
    required this.status,
    required this.price,
    required this.currency,
    required this.startDate,
    this.expiryDate,
    this.autoRenew = true,
    this.renewalPrice,
  });

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpired => expiryDate != null && DateTime.now().isAfter(expiryDate!);
  bool get isPremium => type == SubscriptionType.premium || type == SubscriptionType.premiumPlus;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString().split('.').last,
        'period': period.toString().split('.').last,
        'status': status.toString().split('.').last,
        'price': price,
        'currency': currency,
        'startDate': startDate.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'autoRenew': autoRenew,
        'renewalPrice': renewalPrice,
      };

  @override
  String toString() => 'Subscription($type - $status)';
}

/// Premium feature definition
class PremiumFeature {
  final String id;
  final String name;
  final String description;
  final SubscriptionType requiredTier;
  final String? icon;

  PremiumFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.requiredTier,
    this.icon,
  });

  @override
  String toString() => 'PremiumFeature($name)';
}

/// Paywall and subscription manager
class PaywallService {
  static final PaywallService _instance = PaywallService._internal();

  Subscription? _currentSubscription;
  final _premiumFeatures = <PremiumFeature>[];
  final _subscriptionCallbacks = <Function(Subscription)>[];

  factory PaywallService() {
    return _instance;
  }

  PaywallService._internal() {
    _initializePremiumFeatures();
  }

  /// Initialize premium features
  void _initializePremiumFeatures() {
    _premiumFeatures.addAll([
      PremiumFeature(
        id: 'unlimited_puzzles',
        name: 'Unlimited Puzzles',
        description: 'Access to unlimited daily puzzles',
        requiredTier: SubscriptionType.premium,
      ),
      PremiumFeature(
        id: 'online_multiplayer',
        name: 'Online Multiplayer',
        description: 'Play against opponents online',
        requiredTier: SubscriptionType.premium,
      ),
      PremiumFeature(
        id: 'advanced_analytics',
        name: 'Advanced Analytics',
        description: 'Detailed game statistics and analysis',
        requiredTier: SubscriptionType.premium,
      ),
      PremiumFeature(
        id: 'ad_free',
        name: 'Ad-Free Experience',
        description: 'No advertisements while playing',
        requiredTier: SubscriptionType.premium,
      ),
      PremiumFeature(
        id: 'exclusive_content',
        name: 'Exclusive Content',
        description: 'Premium puzzles and game modes',
        requiredTier: SubscriptionType.premiumPlus,
      ),
      PremiumFeature(
        id: 'ai_coach',
        name: 'AI Chess Coach',
        description: 'Personal AI coach for improvement',
        requiredTier: SubscriptionType.premiumPlus,
      ),
      PremiumFeature(
        id: 'early_access',
        name: 'Early Access',
        description: 'Access new features before release',
        requiredTier: SubscriptionType.premiumPlus,
      ),
    ]);

    debugPrint('[PaywallService] Initialized with ${_premiumFeatures.length} premium features');
  }

  /// Initialize subscription (would connect to RevenueCat in production)
  Future<void> initialize() async {
    try {
      debugPrint('[PaywallService] Initializing...');
      // In production: await Purchases.setup("revenueCat_key");
      // For now, set default free subscription
      _setCurrentSubscription(Subscription(
        id: 'free_default',
        type: SubscriptionType.free,
        period: SubscriptionPeriod.monthly,
        status: SubscriptionStatus.active,
        price: 0.0,
        currency: 'USD',
        startDate: DateTime.now(),
        autoRenew: false,
      ));
      debugPrint('[PaywallService] Initialized successfully');
    } catch (e) {
      debugPrint('[PaywallService] Initialization error: $e');
    }
  }

  /// Fetch user subscription (would connect to RevenueCat in production)
  Future<Subscription?> fetchSubscription() async {
    try {
      // In production: final info = await Purchases.getCustomerInfo();
      return _currentSubscription;
    } catch (e) {
      debugPrint('[PaywallService] Error fetching subscription: $e');
      return null;
    }
  }

  /// Purchase subscription (would connect to RevenueCat in production)
  Future<bool> purchaseSubscription({
    required SubscriptionType type,
    required SubscriptionPeriod period,
  }) async {
    try {
      debugPrint('[PaywallService] Attempting to purchase $type subscription...');

      // Simulate purchase delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Determine price based on type and period
      double price = _getPriceForSubscription(type, period);

      final subscription = Subscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        period: period,
        status: SubscriptionStatus.active,
        price: price,
        currency: 'USD',
        startDate: DateTime.now(),
        expiryDate: _calculateExpiryDate(period),
        autoRenew: true,
      );

      _setCurrentSubscription(subscription);
      debugPrint('[PaywallService] Purchase successful: $type');
      return true;
    } catch (e) {
      debugPrint('[PaywallService] Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      debugPrint('[PaywallService] Restoring purchases...');
      // In production: await Purchases.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('[PaywallService] Restore error: $e');
      return false;
    }
  }

  /// Cancel subscription
  Future<bool> cancelSubscription() async {
    try {
      debugPrint('[PaywallService] Cancelling subscription...');

      if (_currentSubscription == null) {
        return false;
      }

      final cancelled = Subscription(
        id: _currentSubscription!.id,
        type: SubscriptionType.free,
        period: _currentSubscription!.period,
        status: SubscriptionStatus.cancelled,
        price: 0.0,
        currency: _currentSubscription!.currency,
        startDate: _currentSubscription!.startDate,
        expiryDate: DateTime.now(),
        autoRenew: false,
      );

      _setCurrentSubscription(cancelled);
      debugPrint('[PaywallService] Subscription cancelled');
      return true;
    } catch (e) {
      debugPrint('[PaywallService] Cancellation error: $e');
      return false;
    }
  }

  /// Check if feature is available
  bool isFeatureAvailable(String featureId) {
    if (_currentSubscription == null || _currentSubscription!.type == SubscriptionType.free) {
      return false;
    }

    final feature = _premiumFeatures.firstWhere(
      (f) => f.id == featureId,
      orElse: () => null as dynamic,
    );

    if (feature == null) {
      return false;
    }

    return _currentSubscription!.type.index >= feature.requiredTier.index;
  }

  /// Get subscription price
  double getPrice(SubscriptionType type, SubscriptionPeriod period) {
    return _getPriceForSubscription(type, period);
  }

  /// Get all premium features
  List<PremiumFeature> getAllPremiumFeatures() =>
      List.unmodifiable(_premiumFeatures);

  /// Get features for subscription tier
  List<PremiumFeature> getFeaturesForTier(SubscriptionType type) =>
      _premiumFeatures.where((f) => f.requiredTier.index <= type.index).toList();

  /// Get current subscription
  Subscription? getCurrentSubscription() => _currentSubscription;

  /// Subscribe to subscription changes
  void addSubscriptionListener(Function(Subscription) callback) {
    _subscriptionCallbacks.add(callback);
  }

  /// Remove subscription listener
  void removeSubscriptionListener(Function(Subscription) callback) {
    _subscriptionCallbacks.remove(callback);
  }

  /// Generate subscription report
  String generateSubscriptionReport() {
    final subscription = _currentSubscription;

    if (subscription == null) {
      return 'No subscription data available';
    }

    final buffer = StringBuffer();
    buffer.writeln('''
╔══════════════════════════════════════════════════════════════════╗
║                    SUBSCRIPTION DETAILS                          ║
╠══════════════════════════════════════════════════════════════════╣
║ Type: ${subscription.type.toString().split('.').last.padRight(56)}║
║ Status: ${subscription.status.toString().split('.').last.padRight(54)}║
║ Period: ${subscription.period.toString().split('.').last.padRight(54)}║
║ Price: \$${subscription.price.toStringAsFixed(2)}${subscription.currency.padRight(50)}║
║ Start Date: ${subscription.startDate.toString().padRight(48)}║
║ Expiry Date: ${(subscription.expiryDate?.toString() ?? 'N/A').padRight(47)}║
║ Auto Renew: ${(subscription.autoRenew ? 'Yes' : 'No').padRight(52)}║
╠══════════════════════════════════════════════════════════════════╣
║ AVAILABLE FEATURES:
    ''');

    final features = getFeaturesForTier(subscription.type);
    for (final feature in features) {
      buffer.writeln('║ ✓ ${feature.name}: ${feature.description.padRight(40)}║');
    }

    buffer.writeln('╚══════════════════════════════════════════════════════════════════╝');
    return buffer.toString();
  }

  /// Internal helper to set current subscription
  void _setCurrentSubscription(Subscription subscription) {
    _currentSubscription = subscription;
    for (final callback in _subscriptionCallbacks) {
      try {
        callback(subscription);
      } catch (e) {
        debugPrint('[PaywallService] Error in subscription callback: $e');
      }
    }
  }

  /// Calculate expiry date based on period
  DateTime _calculateExpiryDate(SubscriptionPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case SubscriptionPeriod.monthly:
        return now.add(const Duration(days: 30));
      case SubscriptionPeriod.yearly:
        return now.add(const Duration(days: 365));
      case SubscriptionPeriod.lifetime:
        return now.add(const Duration(days: 36500)); // ~100 years
    }
  }

  /// Get price for subscription
  double _getPriceForSubscription(SubscriptionType type, SubscriptionPeriod period) {
    const basePrice = <SubscriptionType, double>{
      SubscriptionType.free: 0.0,
      SubscriptionType.premium: 4.99,
      SubscriptionType.premiumPlus: 9.99,
    };

    const periodMultiplier = <SubscriptionPeriod, double>{
      SubscriptionPeriod.monthly: 1.0,
      SubscriptionPeriod.yearly: 10.0, // 17% discount
      SubscriptionPeriod.lifetime: 99.99,
    };

    final base = basePrice[type] ?? 0.0;
    final multiplier = periodMultiplier[period] ?? 1.0;

    return (base * multiplier * 100).round() / 100; // Round to 2 decimals
  }
}
