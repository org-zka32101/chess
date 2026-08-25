# Chess Tactics Master 🎯♟️

A Flutter/Dart chess learning application featuring tactical puzzles, AI-powered training, and real-time multiplayer matches. Built with Firebase backend and optimized for iOS and Android.

## Features

✨ **Core Features (MVP)**
- 🧩 **Tactical Puzzles** — Learn chess tactics with 500,000+ puzzles from Lichess DB
- 🤖 **CPU Opponent** — Play against AI at 4 difficulty levels (ELO 800-3000)
- 🎮 **Online Multiplayer** — Real-time player-vs-player matches with rating system
- 📊 **Progress Tracking** — Track your rating, win rate, and learning progress
- 🔐 **User Authentication** — Firebase Auth (Email, Google, Apple)
- 💎 **Premium Features** — Subscription-based advanced analytics and training modes

📱 **Platform Support**
- iOS 14+
- Android 7+

🛠️ **Tech Stack**
- **Frontend**: Flutter 3.24, Dart 3.x
- **State Management**: Riverpod
- **Backend**: Firebase (Auth, Firestore, Realtime DB, Cloud Functions)
- **Chess Engine**: chess.js library
- **Analytics**: Firebase Analytics & Crashlytics

## Quick Start

### Prerequisites
```bash
flutter --version    # >= 3.24.0
dart --version       # >= 3.x
firebase-tools       # Latest
```

### Installation

1. **Clone and setup**
   ```bash
   git clone https://github.com/org-zka32101/chess.git
   cd chess
   git checkout claude/chess-j8fad7
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   flutterfire configure --project=yourwish-chess
   ```

4. **Generate code (Riverpod, Freezed)**
   ```bash
   dart run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Development

### Project Structure
See [CLAUDE.md](./CLAUDE.md) for complete project documentation.

```
lib/
├── main.dart              # Entry point
├── src/
│   ├── screens/           # UI screens
│   ├── services/          # Business logic
│   ├── models/            # Data models
│   ├── providers/         # Riverpod state
│   ├── widgets/           # Reusable UI components
│   └── utils/             # Utilities
├── test/                  # Unit & widget tests
└── integration_test/      # Integration tests
```

### Development Workflow

**Code Quality**
```bash
# Format code
dart format lib/

# Lint check
dart analyze lib/

# Run tests
flutter test

# Full analysis
dart analyze --fatal-infos
```

**Commit Messages**
```
feat: Add multiplayer matchmaking
fix: Resolve move validation bug
refactor: Simplify game state
test: Add ELO calculation tests
docs: Update API documentation
chore: Upgrade dependencies
```

### Build & Release

```bash
# Build APK (Android)
flutter build apk --split-per-abi

# Build iOS
flutter build ios

# Build Web (optional)
flutter build web
```

## Documentation

- **[CLAUDE.md](./CLAUDE.md)** — Project structure, setup, and workflow
- **[online-multiplayer-detailed-design.md](./online-multiplayer-detailed-design.md)** — Online multiplayer architecture and implementation guide
- **[Firebase Setup Guide](#firebase-setup)** — Firebase configuration details

### Firebase Setup

1. Create project at [Firebase Console](https://console.firebase.google.com)
2. Enable these services:
   - Authentication (Email, Google Sign-in, Apple Sign-in)
   - Cloud Firestore
   - Realtime Database
   - Cloud Functions
   - Cloud Storage
   - Analytics
   - Crashlytics

3. Download config files:
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Android: `google-services.json` → `android/app/`

4. Run: `flutterfire configure --project=yourwish-chess`

## Project Phases

| Phase | Focus | Duration | Status |
|-------|-------|----------|--------|
| **A** | Foundation & Auth | 3-4 weeks | 🔄 In Progress |
| **B** | UI Foundation | 2-3 weeks | ⏳ Upcoming |
| **C** | CPU Opponent | 4-5 weeks | ⏳ Upcoming |
| **C'** | Online Multiplayer | 5-6 weeks | ⏳ Upcoming |
| **D** | UI Polish & Polish | 3 weeks | ⏳ Upcoming |
| **E** | Paywall & Analytics | 2 weeks | ⏳ Upcoming |
| **F** | Testing & Release | 2 weeks | ⏳ Upcoming |

## Performance Targets

- **App Load Time**: < 2 seconds
- **Puzzle Load**: < 500ms
- **CPU Move Generation**: < 2 seconds (beginner level)
- **Memory Usage**: < 150MB
- **Firestore Reads**: p99 < 200ms
- **Day 1 Retention**: 35%+
- **Day 7 Retention**: 18%+
- **Premium Conversion**: 5%+

## Security

- ✅ Firebase Security Rules (least privilege)
- ✅ Secrets management via GitHub Secrets
- ✅ OWASP MASVS compliance (mobile)
- ✅ No personal data in logs (Crashlytics)
- ✅ TLS for all network communication
- ✅ Server-side move validation

## Testing

### Test Coverage
- **Unit Tests**: Chess logic, rating calculations, validation
- **Widget Tests**: UI components and screens
- **Integration Tests**: Complete user flows

**Target**: 60%+ coverage (Chess engine: 90%+)

### Run Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/chess_engine_test.dart

# With coverage
flutter test --coverage

# Watch mode
flutter test --watch
```

## Monitoring & Analytics

**Firebase Analytics Events**
- `user_created` — New user signup
- `puzzle_start` — Puzzle session started
- `puzzle_solved` — Puzzle solved correctly
- `game_completed` — Online match finished
- `premium_purchased` — Subscription activated

**Crashlytics**
- Automatic crash reporting
- Error tracking & grouping
- Version correlation

## Contributing

1. Create a feature branch: `git checkout -b feat/my-feature`
2. Make changes and commit: `git commit -m "feat: My feature"`
3. Push to remote: `git push origin feat/my-feature`
4. Create Pull Request (see [CLAUDE.md](./CLAUDE.md) for standards)

## License

Proprietary - Your Wish Inc. / かずき

## Contact

- **GitHub**: [@yourwish-dev](https://github.com/yourwish-dev)
- **Repository**: [org-zka32101/chess](https://github.com/org-zka32101/chess)

---

**Current Phase**: A - Foundation 🚀  
**Last Updated**: 2026-08-25  
**Status**: Active Development