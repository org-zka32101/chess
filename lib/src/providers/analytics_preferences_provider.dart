import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Analytics preferences and user consent
class AnalyticsPreferences {
  /// User has consented to analytics collection
  final bool analyticsEnabled;

  /// User has consented to crash reporting
  final bool crashReportingEnabled;

  /// User has consented to personalization
  final bool personalizationEnabled;

  /// User has consented to marketing emails
  final bool marketingEnabled;

  /// Timestamp when preferences were last updated
  final DateTime lastUpdated;

  /// App version when preferences were set
  final String appVersion;

  AnalyticsPreferences({
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.personalizationEnabled = true,
    this.marketingEnabled = false,
    required this.lastUpdated,
    required this.appVersion,
  });

  /// Create copy with modified fields
  AnalyticsPreferences copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? personalizationEnabled,
    bool? marketingEnabled,
    DateTime? lastUpdated,
    String? appVersion,
  }) {
    return AnalyticsPreferences(
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      personalizationEnabled: personalizationEnabled ?? this.personalizationEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  /// Check if any analytics is enabled
  bool get isAnyAnalyticsEnabled =>
      analyticsEnabled || crashReportingEnabled || personalizationEnabled;

  /// All consents given
  bool get allConsentsGiven =>
      analyticsEnabled &&
      crashReportingEnabled &&
      personalizationEnabled &&
      marketingEnabled;

  /// No consents given
  bool get noConsentsGiven =>
      !analyticsEnabled &&
      !crashReportingEnabled &&
      !personalizationEnabled &&
      !marketingEnabled;
}

/// State notifier for analytics preferences
class AnalyticsPreferencesNotifier
    extends StateNotifier<AsyncValue<AnalyticsPreferences>> {
  static const _boxName = 'analytics_preferences';
  static const _preferencesKey = 'preferences';

  AnalyticsPreferencesNotifier() : super(const AsyncValue.loading()) {
    _loadPreferences();
  }

  /// Load preferences from Hive
  Future<void> _loadPreferences() async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      final json = box.get(_preferencesKey);

      if (json != null) {
        // TODO: Deserialize from JSON when Freezed model is created
        state = AsyncValue.data(
          AnalyticsPreferences(
            lastUpdated: DateTime.now(),
            appVersion: '1.0.0',
          ),
        );
      } else {
        // Default preferences
        state = AsyncValue.data(
          AnalyticsPreferences(
            lastUpdated: DateTime.now(),
            appVersion: '1.0.0',
          ),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Save preferences to Hive
  Future<void> savePreferences(AnalyticsPreferences preferences) async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      // TODO: Serialize to JSON when Freezed model is created
      await box.put(_preferencesKey, '');
      state = AsyncValue.data(preferences);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update analytics enabled
  Future<void> setAnalyticsEnabled(bool enabled) async {
    final currentState = state;
    if (currentState is AsyncData) {
      final updated = currentState.value.copyWith(analyticsEnabled: enabled);
      await savePreferences(updated);
    }
  }

  /// Update crash reporting enabled
  Future<void> setCrashReportingEnabled(bool enabled) async {
    final currentState = state;
    if (currentState is AsyncData) {
      final updated =
          currentState.value.copyWith(crashReportingEnabled: enabled);
      await savePreferences(updated);
    }
  }

  /// Update personalization enabled
  Future<void> setPersonalizationEnabled(bool enabled) async {
    final currentState = state;
    if (currentState is AsyncData) {
      final updated =
          currentState.value.copyWith(personalizationEnabled: enabled);
      await savePreferences(updated);
    }
  }

  /// Update marketing enabled
  Future<void> setMarketingEnabled(bool enabled) async {
    final currentState = state;
    if (currentState is AsyncData) {
      final updated = currentState.value.copyWith(marketingEnabled: enabled);
      await savePreferences(updated);
    }
  }

  /// Accept all consents
  Future<void> acceptAllConsents() async {
    await setAnalyticsEnabled(true);
    await setCrashReportingEnabled(true);
    await setPersonalizationEnabled(true);
    await setMarketingEnabled(true);
  }

  /// Reject all non-essential consents
  Future<void> rejectNonEssential() async {
    // Keep crash reporting (essential for app stability)
    await setAnalyticsEnabled(false);
    await setCrashReportingEnabled(true);
    await setPersonalizationEnabled(false);
    await setMarketingEnabled(false);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    await savePreferences(
      AnalyticsPreferences(
        lastUpdated: DateTime.now(),
        appVersion: '1.0.0',
      ),
    );
  }
}

/// Analytics preferences provider
final analyticsPreferencesProvider =
    StateNotifierProvider<AnalyticsPreferencesNotifier,
        AsyncValue<AnalyticsPreferences>>(
  (ref) => AnalyticsPreferencesNotifier(),
);

/// User consent for analytics
final analyticsConsentProvider = FutureProvider<bool>((ref) async {
  final preferences = ref.watch(analyticsPreferencesProvider);
  return preferences.whenData((prefs) => prefs.analyticsEnabled).value ?? false;
});

/// User consent for crash reporting
final crashReportingConsentProvider = FutureProvider<bool>((ref) async {
  final preferences = ref.watch(analyticsPreferencesProvider);
  return preferences.whenData((prefs) => prefs.crashReportingEnabled).value ??
      false;
});

/// User consent for personalization
final personalizationConsentProvider = FutureProvider<bool>((ref) async {
  final preferences = ref.watch(analyticsPreferencesProvider);
  return preferences
          .whenData((prefs) => prefs.personalizationEnabled)
          .value ??
      false;
});

/// User consent for marketing
final marketingConsentProvider = FutureProvider<bool>((ref) async {
  final preferences = ref.watch(analyticsPreferencesProvider);
  return preferences.whenData((prefs) => prefs.marketingEnabled).value ?? false;
});

/// All consents flag
final allConsentsGivenProvider = FutureProvider<bool>((ref) async {
  final preferences = ref.watch(analyticsPreferencesProvider);
  return preferences.whenData((prefs) => prefs.allConsentsGiven).value ?? false;
});

/// No consents flag
final noConsentsGivenProvider = FutureProvider<bool>((ref) async {
  final preferences = ref.watch(analyticsPreferencesProvider);
  return preferences.whenData((prefs) => prefs.noConsentsGiven).value ?? false;
});
