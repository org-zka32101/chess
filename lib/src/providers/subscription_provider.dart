import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subscription.dart';
import '../services/subscription_service.dart';
import 'auth_provider.dart';

/// Subscription service provider
final subscriptionServiceProvider = Provider((ref) {
  final firestore = FirebaseFirestore.instance;
  return SubscriptionService(firestore);
});

/// Current user subscription stream provider
final userSubscriptionProvider = StreamProvider<UserSubscription?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  final service = ref.watch(subscriptionServiceProvider);

  return userAsync.when(
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      return service.watchUserSubscription(user.id);
    },
  );
});

/// Check if user has premium subscription
final isPremiumProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(userSubscriptionProvider);

  return subscriptionAsync.when(
    loading: () => false,
    error: (_, __) => false,
    data: (subscription) {
      if (subscription == null) return false;
      return subscription.isActive &&
          (subscription.currentTier == SubscriptionTier.premium ||
              subscription.currentTier == SubscriptionTier.elite);
    },
  );
});

/// Check if user has elite subscription
final isEliteProvider = Provider<bool>((ref) {
  final subscriptionAsync = ref.watch(userSubscriptionProvider);

  return subscriptionAsync.when(
    loading: () => false,
    error: (_, __) => false,
    data: (subscription) {
      if (subscription == null) return false;
      return subscription.isActive &&
          subscription.currentTier == SubscriptionTier.elite;
    },
  );
});

/// Days remaining in subscription
final subscriptionDaysRemainingProvider = Provider<int?>((ref) {
  final subscriptionAsync = ref.watch(userSubscriptionProvider);

  return subscriptionAsync.when(
    loading: () => null,
    error: (_, __) => null,
    data: (subscription) => subscription?.daysRemaining,
  );
});

/// Available offerings provider
final offeringsProvider = FutureProvider<List<SubscriptionOffering>>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return service.getOfferings();
});

/// Feature access checker
final featureAccessProvider =
    FutureProvider.family<bool, PremiumFeature>((ref, feature) async {
  final userAsync = ref.watch(currentUserProvider);
  final service = ref.watch(subscriptionServiceProvider);

  final user = userAsync.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );

  if (user == null) return false;

  return service.hasAccessToFeature(userId: user.id, feature: feature);
});

/// Purchase history provider
final purchaseHistoryProvider =
    FutureProvider<List<PurchaseRecord>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final service = ref.watch(subscriptionServiceProvider);

  final user = userAsync.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );

  if (user == null) return [];

  return service.getPurchaseHistory(user.id);
});

/// Subscription action notifier
final subscriptionActionProvider =
    StateNotifierProvider<SubscriptionActionNotifier, AsyncValue<void>>((ref) {
  return SubscriptionActionNotifier(ref);
});

class SubscriptionActionNotifier extends StateNotifier<AsyncValue<void>> {
  final StateNotifierProviderRef ref;

  SubscriptionActionNotifier(this.ref) : super(const AsyncValue.data(null));

  /// Handle purchase (simulate)
  Future<void> purchaseSubscription({
    required SubscriptionTier tier,
    required String packageId,
    required int durationDays,
  }) async {
    state = const AsyncValue.loading();
    final userAsync = ref.watch(currentUserProvider);
    final service = ref.watch(subscriptionServiceProvider);

    state = await AsyncValue.guard(() async {
      final user = userAsync.maybeWhen(
        data: (u) => u,
        orElse: () => null,
      );

      if (user == null) {
        throw Exception('User not authenticated');
      }

      final expiresAt =
          DateTime.now().add(Duration(days: durationDays));

      await service.updateSubscription(
        userId: user.id,
        tier: tier,
        expiresAt: expiresAt,
        autoRenewing: true,
        transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Invalidate cache
      ref.invalidate(userSubscriptionProvider);
      ref.invalidate(purchaseHistoryProvider);
    });
  }

  /// Cancel subscription
  Future<void> cancelSubscription() async {
    state = const AsyncValue.loading();
    final userAsync = ref.watch(currentUserProvider);
    final service = ref.watch(subscriptionServiceProvider);

    state = await AsyncValue.guard(() async {
      final user = userAsync.maybeWhen(
        data: (u) => u,
        orElse: () => null,
      );

      if (user == null) {
        throw Exception('User not authenticated');
      }

      await service.cancelSubscription(user.id);
      ref.invalidate(userSubscriptionProvider);
    });
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    state = const AsyncValue.loading();
    final userAsync = ref.watch(currentUserProvider);
    final service = ref.watch(subscriptionServiceProvider);

    state = await AsyncValue.guard(() async {
      final user = userAsync.maybeWhen(
        data: (u) => u,
        orElse: () => null,
      );

      if (user == null) {
        throw Exception('User not authenticated');
      }

      await service.restorePurchases(user.id);
      ref.invalidate(userSubscriptionProvider);
      ref.invalidate(purchaseHistoryProvider);
    });
  }
}
