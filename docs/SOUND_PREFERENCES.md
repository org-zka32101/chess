# Sound Preferences Feature Documentation

## Overview

The Sound Preferences feature provides granular control over sound effects throughout the Chess Tactics Master application. Users can enable/disable specific sound categories (gameplay, UI, notifications) and adjust the overall volume.

## Architecture

### Components

1. **SoundService** (`lib/src/services/sound_service.dart`)
   - Core audio playback handler
   - Manages sound categorization (gamePlay, gameEnd, ui, notifications)
   - Supports master enable/disable and per-category control
   - Placeholder implementation ready for audio_players/just_audio integration

2. **SoundPreferences Model** (`lib/src/providers/sound_preferences_provider.dart`)
   - Data model for user sound preferences
   - Stores master toggle, category toggles, and volume level
   - Firebase persistence (Firestore)

3. **SoundPreferencesService** (`lib/src/providers/sound_preferences_provider.dart`)
   - Handles Firebase communication for sound preferences
   - CRUD operations for preferences
   - Automatic serialization/deserialization

4. **SoundManager** (`lib/src/providers/sound_manager_provider.dart`)
   - High-level API for playing sounds
   - Automatically applies user preferences
   - Preferred interface for the rest of the app

5. **SoundPreferencesScreen** (`lib/src/screens/settings/sound_preferences_screen.dart`)
   - User-facing UI for managing preferences
   - Master sound toggle
   - Per-category toggles
   - Volume slider with real-time feedback

## Sound Categories

| Category | Includes | Description |
|----------|----------|-------------|
| **Gameplay** | movePiece, capture, check | Chess action sounds |
| **Game End** | checkmate, gameOver | Match conclusion sounds |
| **UI** | buttonTap, uiSwipe | Interface interaction sounds |
| **Notifications** | notification, success, error | Alert and status sounds |

## Sound Effects

```dart
enum SoundEffect {
  movePiece,      // Category: gamePlay
  capture,        // Category: gamePlay
  check,          // Category: gamePlay
  checkmate,      // Category: gameEnd
  gameOver,       // Category: gameEnd
  buttonTap,      // Category: ui
  notification,   // Category: notifications
  success,        // Category: notifications
  error,          // Category: notifications
  uiSwipe,        // Category: ui
}
```

## Usage Examples

### Basic Sound Playback

```dart
// In a ConsumerWidget or ConsumerStatefulWidget
class MyGameBoard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final soundManager = await ref.read(soundManagerProvider.future);
        await soundManager.play(SoundEffect.movePiece);
      },
      child: YourBoardWidget(),
    );
  }
}
```

### Check if Category is Enabled

```dart
class GameController {
  final SoundManager soundManager;
  
  void handleMove() {
    if (soundManager.isCategoryEnabled(SoundCategory.gamePlay)) {
      // Only show visual feedback if sounds are enabled
      showMoveAnimation();
    }
  }
}
```

### Play Sequence of Sounds

```dart
final soundManager = await ref.read(soundManagerProvider.future);
await soundManager.playSequence([
  SoundEffect.check,
  SoundEffect.checkmate,
]);
```

### Check Sound Status

```dart
final soundManager = await ref.read(soundManagerProvider.future);
if (!soundManager.hasAnySoundEnabled()) {
  // Show message that sounds are muted
  showSnackBar('All sounds are muted');
}
```

## Firebase Storage Structure

```
user_preferences/{userId}/
  └── sound/
      └── preferences
          ├── soundMasterEnabled: bool
          ├── categoryEnabled: Map<String, bool>
          │   ├── gamePlay: bool
          │   ├── gameEnd: bool
          │   ├── ui: bool
          │   └── notifications: bool
          ├── volume: double (0.0 - 1.0)
          └── lastUpdated: timestamp
```

## Riverpod Providers

### FutureProviders (Async Data)

```dart
// Get user's sound preferences (cached)
final soundPreferencesProvider = FutureProvider<SoundPreferences>

// Get sound manager instance (combines service + preferences)
final soundManagerProvider = FutureProvider<SoundManager>
```

### StateProviders (UI State)

```dart
// Master sound toggle state
final soundMasterEnabledProvider = StateProvider<bool>

// Individual category enable state
final soundCategoryProvider = StateProvider.family<bool, SoundCategory>

// Volume level state
final soundVolumeProvider = StateProvider<double>
```

## Integration Points

### Settings Screen

Users access sound preferences via Settings → Sound Settings:

```dart
// In SettingsScreen
ListTile(
  leading: const Icon(Icons.volume_up),
  title: const Text('Sound Settings'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SoundPreferencesScreen(),
      ),
    );
  },
)
```

### Game Screens

Play sounds when game events occur:

```dart
// In GameScreen or GameController
void onPieceMoved(Move move) {
  _soundManager.play(SoundEffect.movePiece);
}

void onCaptured() {
  _soundManager.play(SoundEffect.capture);
}

void onCheckmate() {
  _soundManager.playSequence([
    SoundEffect.checkmate,
    SoundEffect.gameOver,
  ]);
}
```

### UI Interactions

Provide audio feedback for user actions:

```dart
// In custom buttons
GestureDetector(
  onTap: () async {
    final soundManager = await ref.read(soundManagerProvider.future);
    await soundManager.play(SoundEffect.buttonTap);
    _handleButtonPress();
  },
  child: CustomButton(),
)
```

## Implementation Status

### Completed ✅
- [x] Sound categorization system
- [x] SoundPreferences data model
- [x] Firebase persistence
- [x] SoundPreferencesService CRUD operations
- [x] SoundManager high-level API
- [x] SoundPreferencesScreen UI
- [x] Riverpod provider integration
- [x] Settings screen integration

### TODO (Ready for Implementation)
- [ ] Audio playback using audio_players or just_audio package
- [ ] Sound asset bundling and optimization
- [ ] Haptic feedback option (paired with sound)
- [ ] Advanced settings (per-category volume control)
- [ ] Sound preview in settings
- [ ] Analytics tracking for sound usage

## Future Enhancements

1. **Per-Category Volume Control**
   - Allow users to adjust volume for each category independently
   - Add `Map<SoundCategory, double>` to SoundPreferences

2. **Haptic Feedback**
   - Optional haptic feedback when sounds are muted
   - Integrate with vibration_plugin

3. **Sound Profiles**
   - Pre-configured profiles (Silent, Casual, Intense)
   - Quick profile switching from settings

4. **Advanced Analytics**
   - Track which sounds are most used
   - User preferences trends
   - Help optimize audio library

5. **Custom Sound Upload**
   - Allow users to upload custom sound effects
   - Premium feature with Firebase Storage integration

## Testing

See `lib/src/widgets/sound_preference_example.dart` for a demo widget that:
- Shows current preferences
- Allows testing each sound category
- Displays usage examples
- Provides code snippets

## Related Files

- Settings Screen: `lib/src/screens/settings/settings_screen.dart`
- User Preferences: `lib/src/providers/user_preferences_provider.dart`
- Theme Provider: `lib/src/providers/theme_provider.dart`
- Sound Service: `lib/src/services/sound_service.dart`

## Notes

- Sound preferences are per-user and stored in Firebase
- Volume is normalized to 0.0 - 1.0 range (multiply by 100 for percentage display)
- Master toggle overrides all category toggles
- Sound service is stateless - preferences are fetched per play request
- Categories allow users to customize their audio experience granularly
- Default: All sounds enabled at 100% volume

---

**Last Updated:** 2026-08-29  
**Status:** Phase D - Sound Preferences UI Complete  
**Next:** Integration with audio playback library
