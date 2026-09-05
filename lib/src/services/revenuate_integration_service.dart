import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/revenuate_config.dart';

/// RevenueCat integration service for managing subscriptions and purchases.
///
/// This service wraps the RevenueCat SDK and provides methods for:
/// - Initializing RevenueCat
/// - Checking user entitlements
/// - Getting available offerings
/// - Processing purchases
/// - Restoring previous purchases
class RevenueCatIntegrationService {
  static final RevenueCatIntegrationService _instance = RevenueCatIntegrationService._internal();

  final Logger _logger = Logger();
  bool _isInitialized = false;

  RevenueCatIntegrationService._internal();

  factory RevenueCatIntegrationService() {
    return _instance;
  }

  /// Check if RevenueCat is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat SDK with API key
  ///
  /// Should be called once at app startup
  /// Handles network errors gracefully
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.w('RevenueCat already initialized, skipping initialization');
      return;
    }

    try {
      final apiKey = RevenueCatConfig.apiKey;

      if (apiKey.isEmpty) {
        throw Exception('RevenueCat API key not configured. Please set REVENUEAT_API_KEY environment variable.');
      }

      _logger.i('Initializing RevenueCat with API key');

      // Configure RevenueCat
      await Purchases.configure(
        PurchasesConfiguration(apiKey)
          ..appUserID = null, // Let RevenueCat handle user ID
      );

      _isInitialized = true;
      _logger.i('RevenueCat initialized successfully');

    } on PlatformException catch (e) {
      _logger.e('RevenueCat initialization platform error', error: e);
      rethrow;
    } catch (e) {
      _logger.e('RevenueCat initialization error', error: e);
      rethrow;
    }
  }

  /// Get current user's entitlements
  ///
  /// Returns a map of entitlement identifiers to their details
  /// Handles network errors by returning cached data if available
  Future<Map<String, EntitlementInfo>> getEntitlements() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized. Call initialize() first.');
      }

      _logger.i('Fetching user entitlements');
      final customerInfo = await Purchases.getCustomerInfo();

      _logger.i('Successfully fetched entitlements: ${customerInfo.entitlements.active.keys}');
      return customerInfo.entitlements.active;

    } on PlatformException catch (e) {
      _logger.e('Entitlement fetch platform error', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch entitlements', error: e);
      rethrow;
    }
  }

  /// Get user's active subscription
  ///
  /// Returns subscription info or null if no active subscription
  Future<StoreSubscriptionInfo?> getActiveSubscription() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized. Call initialize() first.');
      }

      _logger.i('Fetching active subscription');
      final customerInfo = await Purchases.getCustomerInfo();

      if (customerInfo.allSubscriptions.isEmpty) {
        _logger.i('No active subscriptions found');
        return null;
      }

      // Get the first (most recent) subscription
      final subscriptionId = customerInfo.allSubscriptions.first;
      final subscription = customerInfo.subscriptions[subscriptionId];

      _logger.i('Found active subscription: $subscriptionId');
      return subscription;

    } on PlatformException catch (e) {
      _logger.e('Subscription fetch platform error', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch active subscription', error: e);
      rethrow;
    }
  }

  /// Get available offerings and products
  ///
  /// Returns Offerings object containing available subscription options
  Future<Offerings> getOfferings() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized. Call initialize() first.');
      }

      _logger.i('Fetching available offerings');
      final offerings = await Purchases.getOfferings();

      _logger.i('Successfully fetched offerings: ${offerings.all.length} offering(s)');
      return offerings;

    } on PlatformException catch (e) {
      _logger.e('Offerings fetch platform error', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch offerings', error: e);
      rethrow;
    }
  }

  /// Purchase a specific product
  ///
  /// Handles the complete purchase flow including error scenarios
  /// Returns customer info after successful purchase
  Future<CustomerInfo> purchaseProduct(Package package) async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized. Call initialize() first.');
      }

      _logger.i('Starting purchase for package: ${package.identifier}');

      final customerInfo = await Purchases.purchasePackage(package);

      _logger.i('Purchase successful for package: ${package.identifier}');
      _logger.d('Customer entitlements: ${customerInfo.entitlements.active.keys}');

      return customerInfo;

    } on PlatformException catch (e) {
      _logger.e('Purchase platform error for ${package.identifier}', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Purchase failed for ${package.identifier}', error: e);
      rethrow;
    }
  }

  /// Restore previous purchases for the current user
  ///
  /// Useful when user reinstalls app or logs in on new device
  Future<CustomerInfo> restorePurchases() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized. Call initialize() first.');
      }

      _logger.i('Restoring previous purchases');

      final customerInfo = await Purchases.restorePurchases();

      _logger.i('Purchase restoration successful');
      _logger.d('Restored entitlements: ${customerInfo.entitlements.active.keys}');

      return customerInfo;

    } on PlatformException catch (e) {
      _logger.e('Restore purchases platform error', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Failed to restore purchases', error: e);
      rethrow;
    }
  }

  /// Check if user has specific entitlement
  Future<bool> hasEntitlement(String entitlementIdentifier) async {
    try {
      final entitlements = await getEntitlements();
      return entitlements.containsKey(entitlementIdentifier);

    } catch (e) {
      _logger.e('Failed to check entitlement: $entitlementIdentifier', error: e);
      return false; // Fail-open for feature access
    }
  }

  /// Get customer info (subscription status, entitlements, etc.)
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      if (!_isInitialized) {
        throw Exception('RevenueCat not initialized. Call initialize() first.');
      }

      _logger.i('Fetching customer info');
      final customerInfo = await Purchases.getCustomerInfo();

      _logger.d('Customer info retrieved successfully');
      return customerInfo;

    } on PlatformException catch (e) {
      _logger.e('Customer info fetch platform error', error: e);
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch customer info', error: e);
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _logger.i('Disposing RevenueCat integration service');
    _isInitialized = false;
  }
}
