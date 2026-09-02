import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../services/revenuate_integration_service.dart';

/// RevenueCat service provider (singleton)
///
/// Provides access to the RevenueCat integration service
/// Should be initialized before use
final revenuateServiceProvider = Provider<RevenueCatIntegrationService>((ref) {
  return RevenueCatIntegrationService();
});

/// Offerings provider (future)
///
/// Fetches available subscription offerings from RevenueCat
/// Provides pricing and package information
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  final service = ref.watch(revenuateServiceProvider);

  if (!service.isInitialized) {
    throw Exception('RevenueCat service not initialized');
  }

  return service.getOfferings();
});

/// User entitlements provider (future)
///
/// Fetches current user's active entitlements
/// Used to determine which features are available
final entitlementsProvider = FutureProvider<Map<String, EntitlementInfo>>((ref) async {
  final service = ref.watch(revenuateServiceProvider);

  if (!service.isInitialized) {
    throw Exception('RevenueCat service not initialized');
  }

  return service.getEntitlements();
});

/// User's active subscription provider (future)
///
/// Gets information about the current subscription
/// Returns null if no active subscription
final activeSubscriptionProvider = FutureProvider<StoreSubscriptionInfo?>((ref) async {
  final service = ref.watch(revenuateServiceProvider);

  if (!service.isInitialized) {
    throw Exception('RevenueCat service not initialized');
  }

  return service.getActiveSubscription();
});

/// Customer info provider (future)
///
/// Gets complete customer information including all subscriptions
/// and entitlements
final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  final service = ref.watch(revenuateServiceProvider);

  if (!service.isInitialized) {
    throw Exception('RevenueCat service not initialized');
  }

  return service.getCustomerInfo();
});

/// Entitlement checker provider (family)
///
/// Check if user has a specific entitlement
/// Usage: ref.watch(entitlementCheckerProvider('entitlement_id'))
final entitlementCheckerProvider = FutureProvider.family<bool, String>((ref, entitlementId) async {
  final service = ref.watch(revenuateServiceProvider);

  if (!service.isInitialized) {
    return false; // Fail-open for feature access
  }

  return service.hasEntitlement(entitlementId);
});

/// Purchase action state notifier
///
/// Handles purchase operations and their state
class PurchaseStateNotifier extends StateNotifier<AsyncValue<CustomerInfo>> {
  final RevenueCatIntegrationService _service;

  PurchaseStateNotifier(this._service) : super(const AsyncValue.data(state: null));

  /// Purchase a package
  Future<void> purchasePackage(Package package) async {
    state = const AsyncValue.loading();

    try {
      final customerInfo = await _service.purchaseProduct(package);
      state = AsyncValue.data(customerInfo);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();

    try {
      final customerInfo = await _service.restorePurchases();
      state = AsyncValue.data(customerInfo);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(state: null);
  }
}

/// Purchase action provider (state notifier)
///
/// Manages purchase operations and loading states
final purchaseActionProvider = StateNotifierProvider<PurchaseStateNotifier, AsyncValue<CustomerInfo>>((ref) {
  final service = ref.watch(revenuateServiceProvider);
  return PurchaseStateNotifier(service);
});

/// Subscription tier provider (future family)
///
/// Determine user's subscription tier based on entitlements
/// Returns 'free', 'pro', or 'elite'
final subscriptionTierProvider = FutureProvider<String>((ref) async {
  try {
    final entitlements = await ref.watch(entitlementsProvider.future);

    if (entitlements.containsKey('elite_features')) {
      return 'elite';
    } else if (entitlements.containsKey('pro_features')) {
      return 'pro';
    } else {
      return 'free';
    }
  } catch (_) {
    return 'free'; // Fail-open to free tier
  }
});

/// Premium access provider
///
/// Check if user has premium access (Pro or Elite tier)
final hasPremiumAccessProvider = FutureProvider<bool>((ref) async {
  try {
    final tier = await ref.watch(subscriptionTierProvider.future);
    return tier != 'free';
  } catch (_) {
    return false;
  }
});

/// Elite access provider
///
/// Check if user has elite tier access
final hasEliteAccessProvider = FutureProvider<bool>((ref) async {
  try {
    final tier = await ref.watch(subscriptionTierProvider.future);
    return tier == 'elite';
  } catch (_) {
    return false;
  }
});
