import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/subscription_service.dart';
import '../screens/premium/premium_screen.dart';
import '../utils/animations.dart';

/// Widget that gates content behind premium subscription
class PremiumGate extends ConsumerWidget {
  final PremiumFeature requiredFeature;
  final Widget child;
  final Widget? lockedWidget;

  const PremiumGate({
    Key? key,
    required this.requiredFeature,
    required this.child,
    this.lockedWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureAccess = ref.watch(premiumFeatureProvider(requiredFeature));

    return featureAccess.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (hasAccess) {
        if (hasAccess) {
          return child;
        } else {
          return lockedWidget ??
              _buildLockedState(context, requiredFeature);
        }
      },
    );
  }

  Widget _buildLockedState(BuildContext context, PremiumFeature feature) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Premium Feature',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.displayName,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                SmoothPageTransition(page: const PremiumScreen()),
              );
            },
            child: const Text('Upgrade to Premium'),
          ),
        ],
      ),
    );
  }
}

/// Dialog that prompts user to upgrade for premium feature
class PremiumUpgradeDialog extends ConsumerWidget {
  final PremiumFeature feature;
  final String? description;

  const PremiumUpgradeDialog({
    Key? key,
    required this.feature,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 12),
          Text(feature.displayName),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description ?? 'This feature is only available with a Premium subscription.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Unlock with Premium',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Get unlimited access to all premium features for just \$4.99/month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not Now'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).push(
              SmoothPageTransition(page: const PremiumScreen()),
            );
          },
          child: const Text('View Plans'),
        ),
      ],
    );
  }
}

/// Extension to show premium upgrade prompt
extension PremiumFeaturePrompt on BuildContext {
  void showPremiumUpgradePrompt(
    PremiumFeature feature, {
    String? description,
  }) {
    showDialog(
      context: this,
      builder: (_) => PremiumUpgradeDialog(
        feature: feature,
        description: description,
      ),
    );
  }
}

/// Widget that shows upgrade prompt when tapped if feature is locked
class PremiumLockedButton extends ConsumerWidget {
  final PremiumFeature requiredFeature;
  final VoidCallback onPressed;
  final Widget child;

  const PremiumLockedButton({
    Key? key,
    required this.requiredFeature,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureAccess = ref.watch(premiumFeatureProvider(requiredFeature));

    return featureAccess.when(
      loading: () => child,
      error: (error, stack) => child,
      data: (hasAccess) {
        return GestureDetector(
          onTap: hasAccess
              ? onPressed
              : () => context.showPremiumUpgradePrompt(requiredFeature),
          child: Opacity(
            opacity: hasAccess ? 1.0 : 0.6,
            child: Stack(
              children: [
                child,
                if (!hasAccess)
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
