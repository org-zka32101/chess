# Chess Tactics Master - Development Guide

## Project Overview

**Chess Tactics Master** is a Flutter/Dart application for learning chess through tactical puzzles and multiplayer online matches. Built with Firebase backend and Riverpod state management.

### Key Details
- **Repository**: org-zka32101/chess
- **Development Branch**: claude/chess-j8fad7
- **Tech Stack**: Flutter 3.24, Dart 3.x, Firebase, Riverpod
- **Target Platforms**: iOS 14+, Android 7+
- **Status**: Phase A (Foundation) - In Progress

---

## Project Structure

```
chess/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── firebase_options.dart        # Firebase configuration
│   ├── src/
│   │   ├── app.dart                 # Main app widget
│   │   ├── screens/                 # UI screens
│   │   │   ├── auth/                # Auth screens
│   │   │   ├── home/                # Home screen
│   │   │   ├── puzzle/              # Puzzle screen
│   │   │   └── game/                # Online game screen
│   │   ├── services/                # Business logic
│   │   │   ├── auth_service.dart
│   │   │   ├── firebase_service.dart
│   │   │   ├── chess_engine.dart
│   │   │   └── matchmaking_service.dart
│   │   ├── models/                  # Data models
│   │   │   ├── user.dart
│   │   │   ├── game.dart
│   │   │   └── puzzle.dart
│   │   ├── providers/               # Riverpod providers
│   │   │   ├── auth_provider.dart
│   │   │   ├── user_provider.dart
│   │   │   └── game_provider.dart
│   │   ├── widgets/                 # Reusable widgets
│   │   ├── utils/                   # Utility functions
│   │   └── l10n/                    # Localization (i18n)
│   └── generated/                   # Auto-generated files (Riverpod, Freezed)
├── test/                            # Unit tests
├── integration_test/                # Integration tests
├── assets/                          # Static assets
│   ├── images/
│   ├── lottie/
│   └── data/
├── android/                         # Android native code
├── ios/                             # iOS native code
├── pubspec.yaml                     # Flutter dependencies
├── pubspec.lock                     # Locked dependency versions
├── analysis_options.yaml            # Linting rules
├── .github/
│   ├── workflows/                   # CI/CD pipelines
│   │   ├── ci.yml
│   │   └── security-scan.yml
│   ├── pull_request_template.md
│   └── CODEOWNERS
└── README.md                        # Project readme

```

---

## Development Phases

### Phase A: Foundation (Weeks 1-2) — CURRENT
- [ ] Flutter project setup with Firebase
- [ ] Firebase Authentication (Email/Google/Apple)
- [ ] Basic home screen layout
- [ ] Riverpod state management structure

### Phase B: UI Foundation (Weeks 3-4)
- [ ] Navigation structure
- [ ] User profile screen
- [ ] Settings screen
- [ ] Responsive layout design

### Phase C: CPU Play (Weeks 5-6)
- [ ] Chess board UI (CustomPainter)
- [ ] Chess logic engine integration
- [ ] CPU opponent implementation
- [ ] Game history tracking

### Phase C': Online Multiplayer (Weeks 7-11) — DETAILED DESIGN COMPLETE
- [ ] Matchmaking system
- [ ] Real-time game synchronization
- [ ] Timeout handling
- [ ] Rating system updates
- *See: `online-multiplayer-detailed-design.md`*

### Phase D: UI/UX Polish (Week 12)
- [ ] Dark mode support
- [ ] Sound effects & animations
- [ ] Error handling & notifications

### Phase E: Paywall & Analytics (Week 13)
- [ ] RevenueCat integration
- [ ] Firebase Analytics
- [ ] Premium feature gating

### Phase F: Testing & Release (Weeks 14-15)
- [ ] Unit/Widget/Integration tests
- [ ] Security audit
- [ ] App Store/Play Store submission

---

## Technology Stack

### Frontend
- **Framework**: Flutter 3.24 / Dart 3.x
- **State Management**: Riverpod 2.4+
- **UI**: Material 3
- **Animation**: Lottie
- **Localization**: intl

### Backend
- **Authentication**: Firebase Auth
- **Database**: Firestore (document) + Realtime DB (sync)
- **Cloud Compute**: Cloud Functions (Node.js 18)
- **Storage**: Firebase Storage
- **Analytics**: Firebase Analytics

### Libraries
- **chess**: Chess logic & validation
- **sqflite**: Local puzzle database
- **freezed**: Immutable data models
- **json_serializable**: JSON serialization
- **google_fonts**: Typography
- **logger**: Logging

---

## Key Files & Entry Points

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point & Firebase init |
| `lib/src/app.dart` | Material app configuration |
| `lib/src/services/auth_service.dart` | Firebase auth logic |
| `lib/src/providers/*` | Riverpod state management |
| `lib/src/models/*` | Data structures (Freezed) |
| `pubspec.yaml` | Dependency management |
| `analysis_options.yaml` | Dart linting rules |
| `.github/workflows/ci.yml` | GitHub Actions CI/CD |

---

## Setup Instructions

### Prerequisites
```bash
flutter --version    # >= 3.24.0
dart --version       # >= 3.x
firebase-tools       # For Firebase CLI
```

### Installation
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (Riverpod, Freezed)
dart run build_runner build

# 3. Configure Firebase
flutterfire configure

# 4. Run the app
flutter run
```

### Firebase Configuration
1. Create Firebase project at `console.firebase.google.com`
2. Enable these services:
   - Authentication (Email, Google, Apple)
   - Firestore Database
   - Realtime Database
   - Cloud Functions
   - Cloud Storage
   - Analytics
   - Crashlytics

3. Update `lib/firebase_options.dart` with your config

---

## Development Workflow

### Branch Strategy
- **Base**: `main` (production-ready)
- **Development**: `claude/chess-j8fad7` (active development)
- **Feature**: `feat/feature-name` (from dev branch)

### Commit Convention
```
feat: Add user authentication
fix: Resolve chess move validation bug
refactor: Simplify game state management
test: Add unit tests for ELO calculation
docs: Update phase A documentation
chore: Update dependencies
```

### Code Quality
```bash
# Format code
dart format lib/

# Lint check
dart analyze lib/

# Run tests
flutter test

# Coverage report
flutter test --coverage
```

---

## Important URLs & Resources

### Documentation
- Flutter Docs: https://flutter.dev/docs
- Firebase Flutter: https://firebase.flutter.dev
- Riverpod Docs: https://riverpod.dev
- Chess Logic: https://github.com/dralletje/chess.dart

### Firebase Console
- Project: https://console.firebase.google.com/project/yourwish-chess
- Firestore: https://console.firebase.google.com/project/yourwish-chess/firestore
- Functions: https://console.firebase.google.com/project/yourwish-chess/functions
- Auth: https://console.firebase.google.com/project/yourwish-chess/authentication

### Design Docs
- **Online Multiplayer Design**: `online-multiplayer-detailed-design.md`
- **Project Handoff**: Stored in project notes

---

## Testing Strategy

### Unit Tests
- Chess engine logic
- Rating calculations
- Validation functions
- Location: `test/`

### Widget Tests
- UI components
- Screen layouts
- Button interactions
- Location: `test/widgets/`

### Integration Tests
- Complete user flows
- Firebase integration
- API calls
- Location: `integration_test/`

### Coverage Target
- Overall: 60%+
- Chess engine: 90%+

---

## Security & Best Practices

### Secrets Management
- Use `.env` for local configuration
- Never commit API keys or credentials
- Store secrets in GitHub Secrets for CI/CD

### Firebase Rules
- Implement least-privilege access
- Validate user authentication on all reads/writes
- Reference: App Privacy Security SKILL

### Code Review
- All PRs require code review
- Mandatory CI/CD checks pass
- Security scan must pass before merge

---

## Troubleshooting

### Common Issues

**Issue**: Build fails with "Unresolved reference"
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

**Issue**: Firebase configuration missing
```bash
flutterfire configure --project=yourwish-chess
```

**Issue**: Riverpod code generation fails
```bash
dart run build_runner clean
dart run build_runner build
```

---

## Contact & Attribution

- **Owner**: かずき (yourwish-dev)
- **Developer**: Claude (AI)
- **Session**: https://claude.ai/code/session_015qWQDTgX7nUUH94CwJce7J

---

**Last Updated**: 2026-09-04
**Phase**: J - AI-Powered Lesson Generation
**Status**: ✅ All Phases A-J Complete & Integrated

---

## Phase I: Chess Tactics & Opening Explanations (NEW)

### Overview
Phase I adds comprehensive, interactive explanations for chess tactics, openings, and strategy concepts. This phase transforms Chess Tactics Master into an educational platform with structured lessons, progress tracking, and difficulty-based learning paths.

### Phase I Architecture

#### 1. Content System
**Three Content Categories:**
- **Opening Explanations** - ECO-coded chess openings with main lines, alternatives, traps, and statistics
- **Tactics Patterns** - Common tactical motifs (forks, pins, skewers, etc.) with recognition features
- **Strategy Guides** - Positional principles, evaluation criteria, and planning guidelines

#### 2. Services Implemented

**ChessLessonsService** (6 core methods):
- `getLessonsByType()` - Filter lessons by content type and difficulty
- `getOpeningByEco()` - Retrieve specific opening by ECO code
- `getTacticsByDifficulty()` - Get tactics at specific skill level
- `startLesson()` - Initialize user lesson progress
- `updateLessonProgress()` - Track percentage completion
- `getUserProgress()` - Retrieve all user lesson progress

#### 3. Data Models (5 Core Models)

**ChessLesson**
- Title, description, content type, difficulty level
- PGN examples, key points, common mistakes
- Prerequisites, related topics, statistics
- Instructor notes and estimated duration

**OpeningExplanation**
- Name, ECO code, strategic ideas
- Main lines and alternative lines (PGN)
- Opening statistics (win rates, draw rate, total games)
- Historical notes and typical plans

**TacticsPattern**
- Name, description, recognition features
- Execution steps, related tactics
- Motif classification, frequency data

**StrategyGuide**
- Principles and key concepts
- Position evaluation criteria
- Plan formation guidelines
- Related strategy topics

**UserLessonProgress**
- Lesson status (not started, in progress, completed, reviewed)
- Percentage complete and times reviewed
- Self-assessment scores
- Notes added and interaction data

#### 4. Riverpod Providers (15+ Providers)

**Lesson Providers:**
- `openingLessons` - Opening lessons by difficulty
- `tacticLessons` - Tactic lessons by difficulty
- `strategyLessons` - Strategy lessons by difficulty
- `allOpenings` - Complete opening library
- `tacticsByDifficulty` - Tactics filtered by level
- `strategyGuides` - All strategy content

**Progress Providers:**
- `userLessonProgress` - User's all progress
- `lessonProgress` - Progress on specific lesson
- `userProgressAnalytics` - Aggregated statistics

**Analytics:**
- `openingStatistics` - Win rates, draw rates, totals
- `userProgressAnalytics` - Learning streaks, completion rates

#### 5. Interactive Widgets

**InteractiveLessonBoard**
- Position display with PGN parsing
- Move-by-move navigation (next, previous, reset)
- Annotations and key points display
- Keyboard and button controls

**LessonCompletionCard**
- Progress bar visualization
- Completion percentage
- Continue learning button

**OpeningStatisticsWidget**
- Win rate for white/black
- Draw rate display
- Total games counter

#### 6. Key Features

✅ **Difficulty Progression** - Beginner → Intermediate → Advanced → Expert  
✅ **Interactive Board** - Move through lessons step-by-step  
✅ **Learning Streaks** - Track consecutive learning days  
✅ **Progress Tracking** - Completion percentage, ratings, time spent  
✅ **Lesson Collections** - Curated learning paths  
✅ **Opening Statistics** - Real game statistics for openings  
✅ **Note Taking** - Add personal annotations to lessons  
✅ **Comprehensive Coverage** - 3 content types × 4 difficulty levels  

### Files Created

**Models:**
- `lib/src/models/lesson.dart` - All lesson-related data structures

**Services:**
- `lib/src/services/chess_lessons_service.dart` - Lesson management and progress tracking

**Providers:**
- `lib/src/providers/phase_i_providers.dart` - 15+ reactive providers

**Widgets:**
- `lib/src/widgets/interactive_lesson_board.dart` - Interactive lesson display components

### Firebase Collections

- `chess_lessons` - Core lesson content
- `opening_explanations` - Opening library
- `tactics_patterns` - Tactical patterns
- `strategy_guides` - Strategic concepts
- `user_lesson_progress` - User progress tracking
- `lesson_collections` - Curated lesson paths

### Integration Points

1. **With Phase E (Analytics)** - Track lesson completion events
2. **With Phase G (Launch)** - Include lesson content in beta testing
3. **With Phase H (Community)** - Share lesson achievements

### Success Metrics

- Lesson completion rate: 60%+ for beginner lessons
- Average time per lesson: Within estimated duration ±10%
- User retention: 70%+ return rate for lesson continuation
- Rating accuracy: 90%+ users agree with difficulty level

---

**Phase I Status:** Implementation Complete  
**Total Lines:** 1,200+ (models, services, providers, widgets)  
**Next Phase:** Phase J (AI-Powered Lesson Generation)

---

## Phase J: AI-Powered Lesson Generation (NEW)

### Overview
Phase J adds intelligent AI-powered analysis, personalized lesson generation, and adaptive learning recommendations. This phase transforms Chess Tactics Master into a truly personalized learning platform that adapts to each user's unique strengths, weaknesses, and play style.

### Phase J Architecture

#### 1. AI Analysis System
**Three Core Analysis Types:**
- **Game Analysis** - Deep analysis of completed games with move-by-move evaluation
- **Player Profiling** - Comprehensive player profile from game history
- **Improvement Paths** - AI-generated personalized learning roadmaps

#### 2. Services Implemented

**AILessonGenerationService** (12 core methods):
- `analyzeGame()` - Analyze single game with AI evaluation
- `generateOpeningRecommendations()` - Recommend openings based on play style
- `generateImprovementPath()` - Create personalized learning roadmap
- `getAIGeneratedLessons()` - Retrieve AI lessons by type/level
- `rateLessonUsefulness()` - Feedback mechanism for AI recommendations
- `generatePlayerProfile()` - Build comprehensive player analytics
- `analyzeEndgameWeaknesses()` - Identify endgame-specific weaknesses
- `getRecentInsights()` - Quick insights from recent games
- `respondToLesson()` - Accept/decline lesson recommendations
- `getPerformanceProgressAnalytics()` - Track improvement over time
- `clearCachedAnalysis()` - Cache management utility

#### 3. Data Models (8 Core Models)

**AIGeneratedLesson**
- AI-generated lesson with content type, title, description
- Relevance score and personalized difficulty recommendation
- Review tracking and user feedback scores

**GameAnalysis**
- Complete game analysis with move-by-move breakdown
- Error classification (blunders, mistakes, inaccuracies)
- Identified weaknesses and tactic patterns encountered
- Overall assessment and suggested lessons

**MoveAnalysis**
- Individual move evaluation with analysis type classification
- Best move comparison and explanation
- Tactical pattern identification and evaluation difference

**AIOpeningRecommendation**
- Opening recommendation with ECO code and reasoning
- Compatibility score based on play style
- Main lines, tactical themes, and strategic ideas
- Win rates and performance statistics

**PlayerProfile**
- Comprehensive player analytics from game history
- Strengths, weaknesses, and preferred openings
- Play style classification (e.g., Tactical, Strategic, Balanced)
- Recommended lessons based on profile

**EndgameInsight**
- Endgame-specific weakness identification
- Technique analysis and key principles
- Relevance to broader tactical themes

**ImprovementPath**
- Personalized learning roadmap with priority areas
- Curated lesson recommendations
- Estimated improvement timeline
- Personalized advice based on profile

**AIInsight**
- Quick, actionable insights from recent games
- Relevance ranking for prioritization
- Content type classification and read status

#### 4. Riverpod Providers (20+ Providers)

**Service Provider:**
- `aiLessonGenerationServiceProvider` - Singleton service access

**AI Lesson Providers:**
- `aiGeneratedLessonsProvider` - All AI lessons for user
- `aiGeneratedLessonsByTypeProvider` - Filtered by content type
- `aiGeneratedLessonsByLevelProvider` - Filtered by skill level

**Analysis Providers:**
- `gameAnalysisProvider` - Deep game analysis
- `openingRecommendationsProvider` - Opening suggestions
- `playerProfileProvider` - Comprehensive player analytics
- `improvementPathProvider` - Personalized learning roadmap
- `endgameInsightsProvider` - Endgame weakness analysis
- `recentAIInsightsProvider` - Quick insights from recent games

**Analytics Providers:**
- `performanceProgressAnalyticsProvider` - Improvement tracking
- `userLearningAnalyticsProvider` - Aggregated learning statistics
- `personalizedDashboardProvider` - Complete dashboard data

**State Management:**
- `aiLessonInteractionNotifier` - Rating, feedback, cache management
- `aiLessonInteractionProvider` - Interaction state provider

#### 5. Interactive Widgets (4 Major Widgets)

**AIGameAnalysisCard**
- Displays accuracy, move count, error breakdown
- Shows identified weaknesses with prioritization
- Provides overall game assessment

**PlayerProfileCard**
- Shows game statistics and learning metrics
- Displays strengths (green) and weaknesses (red)
- Shows play style badge and recommendations

**ImprovementPathCard**
- Priority focus areas with ranking
- Estimated improvement timeline
- Personalized advice container
- Practice suggestions

**AILessonsList**
- Filterable list of AI-generated lessons
- Like/favorite functionality
- Difficulty level and duration display
- Relevance scoring visualization

#### 6. Key Features

✅ **Game Analysis** - Automated deep analysis of completed games  
✅ **Player Profiling** - Comprehensive strength/weakness analysis  
✅ **Personalized Recommendations** - Opening suggestions aligned with play style  
✅ **Improvement Paths** - AI-generated learning roadmaps with timelines  
✅ **Endgame Analysis** - Specific focus on endgame weaknesses  
✅ **Performance Tracking** - Track improvement over time  
✅ **Adaptive Learning** - Recommendations improve based on user feedback  
✅ **Quick Insights** - Actionable insights from recent games  

### Files Created

**Models:**
- `lib/src/models/ai_lesson.dart` - All AI lesson and analysis data structures (450+ lines)

**Services:**
- `lib/src/services/ai_lesson_generation_service.dart` - Service interface definition
- `lib/src/services/ai_lesson_generation_service_impl.dart` - Service implementation (650+ lines)

**Providers:**
- `lib/src/providers/phase_j_providers.dart` - 20+ reactive providers with state management (380+ lines)

**Widgets:**
- `lib/src/widgets/ai_lesson_widgets.dart` - Interactive AI lesson UI components (580+ lines)

### Firebase Collections

- `game_analyses` (nested) - Deep game analysis results
- `opening_recommendations` (nested) - Recommended openings
- `ai_generated_lessons` (nested) - AI-generated lesson content
- `improvement_paths` - User improvement roadmaps (merged into user doc)

### Integration Points

1. **With Phase I (Lessons)** - AI recommends lessons from existing content library
2. **With Phase H (Community)** - Share AI insights and achievements
3. **With Phase G (Analytics)** - Track AI recommendation effectiveness
4. **With Phase C' (Multiplayer)** - Analyze online game results
5. **With Phase E (Premium)** - Premium feature: priority AI analysis

### Machine Learning Capabilities

The AI analysis uses:
- **Move Evaluation** - Chess engine evaluation to classify moves
- **Pattern Recognition** - Identify tactical patterns and strategic themes
- **Play Style Analysis** - Determine user's strategic approach
- **Personalization Engine** - Adapt recommendations to user profile
- **Performance Trend Analysis** - Calculate improvement trajectories

### Success Metrics

- Game analysis accuracy: 85%+ correlation with engine evaluation
- AI lesson acceptance rate: 70%+ users accept recommendations
- Performance improvement: 15%+ accuracy gain within 30 days
- Personalization effectiveness: 80%+ users rate recommendations as relevant
- Feature adoption: 60%+ of users analyze at least 5 games per month

### Future Enhancements (Phase J+)

**Optional Features:**
- Real-time AI coaching during games
- Voice-guided lesson explanations
- Video tutorials generated from analysis
- Competitor analysis (compare play style to famous players)
- Opening preparation engine (prepare for known opponents)

---

**Phase J Status:** Implementation Complete  
**Total Lines:** 2,000+ (models, services, providers, widgets)  
**All Phases:** A-J Complete and Integrated
