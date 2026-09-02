import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../providers/revenuate_provider.dart';

/// Paywall screen displaying subscription offerings
///
/// Shows available subscription tiers with pricing and features
class PaywallScreen extends ConsumerStatefulWidget {
  final VoidCallback? onPurchaseComplete;
  final VoidCallback? onDismiss;

  const PaywallScreen({
    this.onPurchaseComplete,
    this.onDismiss,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  Widget build(BuildContext context) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final purchaseState = ref.watch(purchaseActionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Premium Features'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onDismiss ?? () => Navigator.of(context).pop(),
        ),
      ),
      body: offeringsAsync.when(
        data: (offerings) => _buildPaywallContent(
          context,
          offerings,
          purchaseState,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load offerings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(offeringsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaywallContent(
    BuildContext context,
    Offerings offerings,
    AsyncValue<CustomerInfo> purchaseState,
  ) {
    if (offerings.all.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 48),
            const SizedBox(height: 16),
            Text(
              'No offerings available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Choose Your Plan',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock premium features',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Offerings
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offerings.all.length,
              itemBuilder: (context, index) {
                final offering = offerings.all.values.elementAt(index);
                return _buildOfferingCard(
                  context,
                  offering,
                  purchaseState,
                  index == offerings.all.length - 1, // Is premium
                );
              },
            ),

            const SizedBox(height: 24),

            // Terms and Privacy
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'By subscribing, you agree to our Terms of Service and Privacy Policy',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Restore purchases button
            TextButton(
              onPressed: () => _restorePurchases(),
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferingCard(
    BuildContext context,
    Offering offering,
    AsyncValue<CustomerInfo> purchaseState,
    bool isPremium,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offering.identifier.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'POPULAR',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              offering.serverDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            _buildPackagesList(context, offering, purchaseState),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesList(
    BuildContext context,
    Offering offering,
    AsyncValue<CustomerInfo> purchaseState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: offering.availablePackages.map((package) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  package.product.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  package.product.priceString,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: purchaseState.isLoading
                  ? null
                  : () => _purchasePackage(package),
              child: purchaseState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('Subscribe for ${package.product.priceString}'),
            ),
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    final purchaseNotifier = ref.read(purchaseActionProvider.notifier);

    try {
      await purchaseNotifier.purchasePackage(package);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase successful!')),
        );
        widget.onPurchaseComplete?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    final purchaseNotifier = ref.read(purchaseActionProvider.notifier);

    try {
      await purchaseNotifier.restorePurchases();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    }
  }
}
