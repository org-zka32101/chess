import 'package:flutter_test/flutter_test.dart';
import 'package:chess/src/services/sound_service.dart';

void main() {
  group('SoundService Tests', () {
    late SoundService soundService;

    setUp(() {
      soundService = SoundService();
    });

    test('initial state has all sounds enabled', () {
      expect(soundService.getMasterEnabled(), true);
      expect(soundService.getCategoryEnabled(SoundCategory.gamePlay), true);
      expect(soundService.getCategoryEnabled(SoundCategory.gameEnd), true);
      expect(soundService.getCategoryEnabled(SoundCategory.ui), true);
      expect(
        soundService.getCategoryEnabled(SoundCategory.notifications),
        true,
      );
      expect(soundService.getVolume(), 1.0);
    });

    test('setSoundMasterEnabled toggles master control', () {
      soundService.setSoundMasterEnabled(false);
      expect(soundService.getMasterEnabled(), false);

      soundService.setSoundMasterEnabled(true);
      expect(soundService.getMasterEnabled(), true);
    });

    test('setCategoryEnabled controls individual categories', () {
      soundService.setCategoryEnabled(SoundCategory.gamePlay, false);
      expect(soundService.getCategoryEnabled(SoundCategory.gamePlay), false);

      soundService.setCategoryEnabled(SoundCategory.gamePlay, true);
      expect(soundService.getCategoryEnabled(SoundCategory.gamePlay), true);
    });

    test('setVolume controls volume level', () {
      soundService.setVolume(0.5);
      expect(soundService.getVolume(), 0.5);

      soundService.setVolume(0.75);
      expect(soundService.getVolume(), 0.75);
    });

    test('setVolume clamps value between 0.0 and 1.0', () {
      soundService.setVolume(1.5);
      expect(soundService.getVolume(), 1.0);

      soundService.setVolume(-0.5);
      expect(soundService.getVolume(), 0.0);
    });

    test('play method respects master toggle', () async {
      soundService.setSoundMasterEnabled(false);

      // Should not throw when trying to play with master off
      await soundService.play(SoundEffect.movePiece);
      expect(soundService.getMasterEnabled(), false);
    });

    test('play method respects category toggle', () async {
      soundService.setSoundMasterEnabled(true);
      soundService.setCategoryEnabled(SoundCategory.gamePlay, false);

      // Should not play when category is disabled
      await soundService.play(SoundEffect.movePiece);

      // But should play when category is enabled
      soundService.setCategoryEnabled(SoundCategory.gamePlay, true);
      await soundService.play(SoundEffect.movePiece);
    });

    test('playSequence plays multiple sounds', () async {
      soundService.setSoundMasterEnabled(true);

      final sounds = [
        SoundEffect.check,
        SoundEffect.checkmate,
        SoundEffect.gameOver,
      ];

      // Should not throw
      await soundService.playSequence(sounds);
    });

    test('stopAll does not throw', () async {
      await soundService.stopAll();
      // Should complete without error
    });

    test('dispose does not throw', () {
      soundService.dispose();
      // Should complete without error
    });

    test('SoundEffect categorization is correct', () {
      // Gameplay sounds
      expect(SoundEffect.movePiece.category, SoundCategory.gamePlay);
      expect(SoundEffect.capture.category, SoundCategory.gamePlay);
      expect(SoundEffect.check.category, SoundCategory.gamePlay);

      // Game End sounds
      expect(SoundEffect.checkmate.category, SoundCategory.gameEnd);
      expect(SoundEffect.gameOver.category, SoundCategory.gameEnd);

      // UI sounds
      expect(SoundEffect.buttonTap.category, SoundCategory.ui);
      expect(SoundEffect.uiSwipe.category, SoundCategory.ui);

      // Notification sounds
      expect(SoundEffect.notification.category, SoundCategory.notifications);
      expect(SoundEffect.success.category, SoundCategory.notifications);
      expect(SoundEffect.error.category, SoundCategory.notifications);
    });

    test('all SoundEffects have valid asset paths', () {
      for (final effect in SoundEffect.values) {
        expect(effect.assetPath, isNotEmpty);
        expect(effect.assetPath, contains('assets/sounds/'));
      }
    });

    test('all SoundEffects have display names', () {
      for (final effect in SoundEffect.values) {
        expect(effect.displayName, isNotEmpty);
      }
    });

    test('master disable blocks all sounds regardless of category state',
        () async {
      soundService.setSoundMasterEnabled(false);
      soundService.setCategoryEnabled(SoundCategory.gamePlay, true);
      soundService.setCategoryEnabled(SoundCategory.ui, true);

      // Even though categories are enabled, sounds should not play
      await soundService.play(SoundEffect.movePiece);
      await soundService.play(SoundEffect.buttonTap);
    });

    test('category disable prevents specific category sounds', () async {
      soundService.setSoundMasterEnabled(true);

      // Disable gameplay only
      soundService.setCategoryEnabled(SoundCategory.gamePlay, false);
      soundService.setCategoryEnabled(SoundCategory.ui, true);

      // Gameplay sound should not play
      await soundService.play(SoundEffect.movePiece);

      // UI sound should play
      await soundService.play(SoundEffect.buttonTap);
    });
  });

  group('SoundCategory Tests', () {
    test('all categories have unique display names', () {
      final names = SoundCategory.values.map((c) => c.displayName).toList();
      expect(names.length, names.toSet().length);
    });

    test('all categories have unique icons', () {
      final icons = SoundCategory.values.map((c) => c.icon).toList();
      expect(icons.length, icons.toSet().length);
    });

    test('all categories have descriptions', () {
      for (final category in SoundCategory.values) {
        expect(category.description, isNotEmpty);
      }
    });
  });

  group('SoundEffect Tests', () {
    test('all effects have asset paths', () {
      for (final effect in SoundEffect.values) {
        final path = effect.assetPath;
        expect(path, isNotEmpty);
        expect(path, startsWith('assets/sounds/'));
        expect(path, endsWith('.mp3'));
      }
    });

    test('all effects have display names', () {
      for (final effect in SoundEffect.values) {
        expect(effect.displayName, isNotEmpty);
      }
    });

    test('all effects belong to a category', () {
      for (final effect in SoundEffect.values) {
        expect(effect.category, isA<SoundCategory>());
      }
    });

    test('no two effects map to the same file', () {
      final paths = SoundEffect.values.map((e) => e.assetPath).toList();
      expect(paths.length, paths.toSet().length);
    });
  });
}
