import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chess/src/providers/sound_preferences_provider.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-123';
}

void main() {
  group('SoundPreferences Model', () {
    test('creates default preferences correctly', () {
      final prefs = SoundPreferences(userId: 'test-user');

      expect(prefs.userId, 'test-user');
      expect(prefs.soundMasterEnabled, true);
      expect(prefs.volume, 1.0);
      expect(prefs.categoryEnabled[SoundCategory.gamePlay], true);
      expect(prefs.categoryEnabled[SoundCategory.gameEnd], true);
      expect(prefs.categoryEnabled[SoundCategory.ui], true);
      expect(prefs.categoryEnabled[SoundCategory.notifications], true);
    });

    test('copyWith creates a new instance with updated values', () {
      final original = SoundPreferences(userId: 'test-user');
      final updated = original.copyWith(
        soundMasterEnabled: false,
        volume: 0.5,
      );

      expect(original.soundMasterEnabled, true);
      expect(updated.soundMasterEnabled, false);
      expect(updated.volume, 0.5);
      expect(updated.userId, 'test-user');
    });

    test('isCategoryEnabled respects master toggle', () {
      final prefs = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: false,
      );

      expect(prefs.isCategoryEnabled(SoundCategory.gamePlay), false);
      expect(prefs.isCategoryEnabled(SoundCategory.ui), false);
    });

    test('isCategoryEnabled returns category state when master is on', () {
      final prefs = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
        categoryEnabled: {
          SoundCategory.gamePlay: true,
          SoundCategory.gameEnd: false,
          SoundCategory.ui: true,
          SoundCategory.notifications: false,
        },
      );

      expect(prefs.isCategoryEnabled(SoundCategory.gamePlay), true);
      expect(prefs.isCategoryEnabled(SoundCategory.gameEnd), false);
      expect(prefs.isCategoryEnabled(SoundCategory.ui), true);
      expect(prefs.isCategoryEnabled(SoundCategory.notifications), false);
    });

    test('hasAnySoundEnabled returns false when master is off', () {
      final prefs = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: false,
      );

      expect(prefs.hasAnySoundEnabled(), false);
    });

    test('hasAnySoundEnabled returns false when all categories are disabled', () {
      final prefs = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
        categoryEnabled: {
          SoundCategory.gamePlay: false,
          SoundCategory.gameEnd: false,
          SoundCategory.ui: false,
          SoundCategory.notifications: false,
        },
      );

      expect(prefs.hasAnySoundEnabled(), false);
    });

    test('hasAnySoundEnabled returns true when any category is enabled', () {
      final prefs = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
        categoryEnabled: {
          SoundCategory.gamePlay: false,
          SoundCategory.gameEnd: true,
          SoundCategory.ui: false,
          SoundCategory.notifications: false,
        },
      );

      expect(prefs.hasAnySoundEnabled(), true);
    });

    test('toMap serializes preferences correctly', () {
      final prefs = SoundPreferences(
        userId: 'test-user',
        soundMasterEnabled: true,
        volume: 0.75,
      );

      final map = prefs.toMap();

      expect(map['userId'], 'test-user');
      expect(map['soundMasterEnabled'], true);
      expect(map['volume'], 0.75);
      expect(map['categoryEnabled'], isA<Map>());
    });

    test('fromMap deserializes preferences correctly', () {
      final map = {
        'userId': 'test-user',
        'soundMasterEnabled': false,
        'categoryEnabled': {
          'gamePlay': true,
          'gameEnd': false,
          'ui': true,
          'notifications': false,
        },
        'volume': 0.5,
      };

      final prefs = SoundPreferences.fromMap(map);

      expect(prefs.userId, 'test-user');
      expect(prefs.soundMasterEnabled, false);
      expect(prefs.volume, 0.5);
      expect(prefs.categoryEnabled[SoundCategory.gamePlay], true);
      expect(prefs.categoryEnabled[SoundCategory.gameEnd], false);
    });

    test('fromMap handles missing fields with defaults', () {
      final map = {
        'userId': 'test-user',
      };

      final prefs = SoundPreferences.fromMap(map);

      expect(prefs.userId, 'test-user');
      expect(prefs.soundMasterEnabled, true); // Default
      expect(prefs.volume, 1.0); // Default
    });
  });

  group('SoundCategory', () {
    test('SoundCategory has correct display names', () {
      expect(SoundCategory.gamePlay.displayName, 'Gameplay');
      expect(SoundCategory.gameEnd.displayName, 'Game End');
      expect(SoundCategory.ui.displayName, 'UI Sounds');
      expect(SoundCategory.notifications.displayName, 'Notifications');
    });

    test('SoundCategory has correct descriptions', () {
      expect(
        SoundCategory.gamePlay.description,
        'Piece movement, captures, and checks',
      );
      expect(
        SoundCategory.gameEnd.description,
        'Checkmate and game over',
      );
      expect(
        SoundCategory.ui.description,
        'Button taps and menu interactions',
      );
      expect(
        SoundCategory.notifications.description,
        'Notifications and status alerts',
      );
    });

    test('SoundCategory has correct icons', () {
      expect(SoundCategory.gamePlay.icon, Icons.chess_pawn);
      expect(SoundCategory.gameEnd.icon, Icons.flag);
      expect(SoundCategory.ui.icon, Icons.touch_app);
      expect(SoundCategory.notifications.icon, Icons.notifications);
    });
  });

  group('Volume clamping', () {
    test('volume is clamped to valid range', () {
      final prefs1 = SoundPreferences(userId: 'test', volume: 1.5);
      expect(prefs1.volume, 1.0);

      final prefs2 = SoundPreferences(userId: 'test', volume: -0.5);
      expect(prefs2.volume, lessThanOrEqualTo(1.0));
    });
  });

  group('Default categories', () {
    test('all categories are enabled by default', () {
      final prefs = SoundPreferences(userId: 'test');

      for (final category in SoundCategory.values) {
        expect(prefs.categoryEnabled[category], true);
      }
    });
  });
}
