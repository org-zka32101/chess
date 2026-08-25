import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Subscription plan types
enum SubscriptionPlan {
  free,
  premium,
  premiumPlus,
}

extension SubscriptionPlanExt on SubscriptionPlan {
  String get planId {
    switch (this) {
      case SubscriptionPlan.free:
        return 'free';
      case SubscriptionPlan.premium:
        return 'premium_monthly';
      case SubscriptionPlan.premiumPlus:
        return 'premium_plus_annual';
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.premium:
        return 'Premium (Monthly)';
      case SubscriptionPlan.premiumPlus:
        return 'Premium+ (Annual)';
    }
  }

  double get monthlyPrice {
    switch (this) {
      case SubscriptionPlan.free:
        return 0.0;
      case SubscriptionPlan.premium:
        return 4.99;
      case SubscriptionPlan.premiumPlus:
        return 2.92; // ~$35/year
    }
  }
}

/// Premium features
enum PremiumFeature {
  unlimitedPuzzles,
  customThemes,
  advancedAnalytics,
  noAds,
  offlineMode,
  unlimitedChallenge,
  prioritySupport,
}

extension PremiumFeatureExt on PremiumFeature {
  String get featureId {
    switch (this) {
      case PremiumFeature.unlimitedPuzzles:
        return 'unlimited_puzzles';
      case PremiumFeature.customThemes:
        return 'custom_themes';
      case PremiumFeature.advancedAnalytics:
        return 'advanced_analytics';
      case PremiumFeature.noAds:
        return 'no_ads';
      case PremiumFeature.offlineMode:
        return 'offline_mode';
      case PremiumFeature.unlimitedChallenge:
        return 'unlimited_challenge';
      case PremiumFeature.prioritySupport:
        return 'priority_support';
    }
  }

  String get displayName {
    switch (this) {
      case PremiumFeature.unlimitedPuzzles:
        return 'Unlimited Puzzles';
      case PremiumFeature.customThemes:
        return 'Custom Themes';
      case PremiumFeature.advancedAnalytics:
        return 'Advanced Analytics';
      case PremiumFeature.noAds:
        return 'No Advertisements';
      case PremiumFeature.offlineMode:
        return 'Offline Mode';
      case PremiumFeature.unlimitedChallenge:
        return 'Unlimited Daily Challenge';
      case PremiumFeature.prioritySupport:
        return 'Priority Support';
    }
  }

  bool isAvailableIn(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return false;
      case SubscriptionPlan.premium:
        // Premium includes most features
        return this != PremiumFeature.prioritySupport;
      case SubscriptionPlan.premiumPlus:
        // Premium+ includes all features
        return true;
    }
  }
}

/// User subscription status
class SubscriptionStatus {
  final String userId;
  final SubscriptionPlan currentPlan;
  final bool isSubscribed;
  final DateTime? expiryDate;
  final String? transactionId;
  final DateTime? purchaseDate;

  SubscriptionStatus({
    required this.userId,
    this.currentPlan = SubscriptionPlan.free,
    this.isSubscribed = false,
    this.expiryDate,
    this.transactionId,
    this.purchaseDate,
  });

  bool get isPremium => currentPlan != SubscriptionPlan.free;
  bool get isExpired => expiryDate != null && expiryDate!.isBefore(DateTime.now());
  bool get isActive => isSubscribed && !isExpired;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'plan': currentPlan.planId,
      'isSubscribed': isSubscribed,
      'expiryDate': expiryDate,
      'transactionId': transactionId,
      'purchaseDate': purchaseDate,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory SubscriptionStatus.fromMap(Map<String, dynamic> map) {
    SubscriptionPlan plan = SubscriptionPlan.free;
    final planStr = map['plan'] as String?;
    if (planStr == 'premium_monthly') {
      plan = SubscriptionPlan.premium;
    } else if (planStr == 'premium_plus_annual') {
      plan = SubscriptionPlan.premiumPlus;
    }

    return SubscriptionStatus(
      userId: map['userId'] ?? '',
      currentPlan: plan,
      isSubscribed: map['isSubscribed'] ?? false,
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      transactionId: map['transactionId'],
      purchaseDate: map['purchaseDate'] != null
          ? (map['purchaseDate'] as Timestamp).toDate()
          : null,
    );
  }
}

/// Subscription and RevenueCat integration service
class SubscriptionService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SubscriptionService(this._firestore, this._auth);

  /// Get current user's subscription status
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    final user = _auth.currentUser;
    if (user == null) {
      return SubscriptionStatus(userId: 'unknown');
    }

    try {
      final doc = await _firestore.collection('subscriptions').doc(user.uid).get();

      if (doc.exists) {
        return SubscriptionStatus.fromMap({
          'userId': user.uid,
          ...doc.data()!,
        });
      }

      // Return free plan if no subscription found
      return SubscriptionStatus(userId: user.uid);
    } catch (e) {
      print('Error fetching subscription status: $e');
      return SubscriptionStatus(userId: user.uid);
    }
  }

  /// Check if user has access to a feature
  Future<bool> hasFeatureAccess(PremiumFeature feature) async {
    final status = await getSubscriptionStatus();
    return feature.isAvailableIn(status.currentPlan) && status.isActive;
  }

  /// Check multiple features
  Future<Map<PremiumFeature, bool>> checkFeatureAccess(
    List<PremiumFeature> features,
  ) async {
    final status = await getSubscriptionStatus();
    return {
      for (final feature in features)
        feature: feature.isAvailableIn(status.currentPlan) && status.isActive,
    };
  }

  /// Update subscription after purchase (called by RevenueCat webhook or client)
  Future<void> updateSubscription({
    required SubscriptionPlan plan,
    required String transactionId,
    required DateTime expiryDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final status = SubscriptionStatus(
        userId: user.uid,
        currentPlan: plan,
        isSubscribed: true,
        expiryDate: expiryDate,
        transactionId: transactionId,
        purchaseDate: DateTime.now(),
      );

      await _firestore.collection('subscriptions').doc(user.uid).set(
            status.toMap(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('Error updating subscription: $e');
      rethrow;
    }
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await _firestore.collection('subscriptions').doc(user.uid).update({
        'isSubscribed': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error cancelling subscription: $e');
      rethrow;
    }
  }

  /// Restore purchases (for RevenueCat restore)
  Future<void> restorePurchases() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      // TODO: Implement RevenueCat restore purchases
      // This would typically call RevenueCat SDK to restore purchases
      print('Restoring purchases for user: ${user.uid}');
    } catch (e) {
      print('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Get subscription options
  List<SubscriptionPlan> getAvailablePlans() {
    return [SubscriptionPlan.premium, SubscriptionPlan.premiumPlus];
  }
}

/// Riverpod provider for subscription service
final subscriptionServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  return SubscriptionService(firestore, auth);
});

/// User subscription status provider
final subscriptionStatusProvider = FutureProvider<SubscriptionStatus>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getSubscriptionStatus();
});

/// Premium features access provider
final premiumFeatureProvider = FutureProvider.family<bool, PremiumFeature>(
  (ref, feature) async {
    final service = ref.watch(subscriptionServiceProvider);
    return service.hasFeatureAccess(feature);
  },
);

/// Multiple features access provider
final premiumFeaturesProvider =
    FutureProvider.family<Map<PremiumFeature, bool>, List<PremiumFeature>>(
  (ref, features) async {
    final service = ref.watch(subscriptionServiceProvider);
    return service.checkFeatureAccess(features);
  },
);
