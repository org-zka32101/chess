import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/revenuate_provider.dart';

/// Subscription management screen
///
/// Shows current subscription status, expiration date, and management options
class SubscriptionManagementScreen extends ConsumerWidget {
  final VoidCallback? onUpgradeRequested;

  const SubscriptionManagementScreen({
    this.onUpgradeRequested,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerInfoAsync = ref.watch(customerInfoProvider);
    final subscriptionTierAsync = ref.watch(subscriptionTierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        centerTitle: true,
      ),
      body: customerInfoAsync.when(
        data: (customerInfo) => _buildSubscriptionContent(
          context,
          ref,
          customerInfo,
          subscriptionTierAsync,
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
                'Failed to load subscription',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(customerInfoProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(
    BuildContext context,
    WidgetRef ref,
    dynamic customerInfo,
    AsyncValue<String> subscriptionTierAsync,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Subscription
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Subscription',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    subscriptionTierAsync.when(
                      data: (tier) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            context,
                            'Plan',
                            tier.toUpperCase(),
                          ),
                          const SizedBox(height: 12),
                          if (customerInfo.allSubscriptions.isNotEmpty)
                            _buildInfoRow(
                              context,
                              'Status',
                              'Active',
                            ),
                          if (customerInfo.allSubscriptions.isEmpty)
                            _buildInfoRow(
                              context,
                              'Status',
                              'Free',
                            ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Active Subscriptions
            if (customerInfo.allSubscriptions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Subscriptions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customerInfo.allSubscriptions.length,
                    itemBuilder: (context, index) {
                      final subscriptionId =
                          customerInfo.allSubscriptions[index];
                      final subscription =
                          customerInfo.subscriptions[subscriptionId];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subscription?.productIdentifier ??
                                    'Unknown Product',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              if (subscription != null)
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow(
                                      context,
                                      'Expires',
                                      _formatDate(
                                        subscription.expiresDate,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      context,
                                      'Renews',
                                      subscription.isActive
                                          ? 'Yes'
                                          : 'No',
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Subscriptions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upgrade to premium to unlock exclusive features',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onUpgradeRequested,
                    child: const Text('Upgrade to Premium'),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Account Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'App User ID',
                      customerInfo.originalAppUserId ?? 'Unknown',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      'Last Updated',
                      _formatDate(customerInfo.requestDate),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Help Links
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact support: support@example.com'),
                  ),
                );
              },
              child: const Text('Contact Support'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
