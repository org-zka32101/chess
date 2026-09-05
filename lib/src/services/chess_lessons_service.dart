import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';

/// Chess Lessons Service for managing tactics, openings, and strategy explanations
class ChessLessonsService {
  static final ChessLessonsService _instance = ChessLessonsService._internal();

  final FirebaseFirestore _firestore;

  factory ChessLessonsService({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      _instance._firestore = firestore;
    }
    return _instance;
  }

  ChessLessonsService._internal() : _firestore = FirebaseFirestore.instance;

  /// Get lessons by type and difficulty
  Future<List<ChessLesson>> getLessonsByType(
    ContentType type, {
    DifficultyLevel? difficulty,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('chess_lessons')
          .where('type', isEqualTo: type.name);

      if (difficulty != null) {
        query = query.where('difficulty', isEqualTo: difficulty.name);
      }

      final querySnapshot = await query
          .orderBy('difficulty')
          .orderBy('createdDate', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              ChessLesson.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching lessons: $e');
      return [];
    }
  }

  /// Get opening explanation by ECO code
  Future<OpeningExplanation?> getOpeningByEco(String ecoCode) async {
    try {
      final querySnapshot = await _firestore
          .collection('opening_explanations')
          .where('ecoCode', isEqualTo: ecoCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return OpeningExplanation.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching opening: $e');
      return null;
    }
  }

  /// Get all openings
  Future<List<OpeningExplanation>> getAllOpenings({int limit = 100}) async {
    try {
      final querySnapshot = await _firestore
          .collection('opening_explanations')
          .orderBy('difficulty')
          .orderBy('totalGamesWithOpening', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              OpeningExplanation.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching openings: $e');
      return [];
    }
  }

  /// Get tactics by difficulty
  Future<List<TacticsPattern>> getTacticsByDifficulty(
      DifficultyLevel difficulty) async {
    try {
      final querySnapshot = await _firestore
          .collection('tactics_patterns')
          .where('difficulty', isEqualTo: difficulty.name)
          .orderBy('typicalOccurrenceFrequency', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              TacticsPattern.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching tactics: $e');
      return [];
    }
  }

  /// Get all tactics
  Future<List<TacticsPattern>> getAllTactics() async {
    try {
      final querySnapshot = await _firestore
          .collection('tactics_patterns')
          .orderBy('difficulty')
          .orderBy('typicalOccurrenceFrequency', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              TacticsPattern.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching tactics: $e');
      return [];
    }
  }

  /// Get strategy guides
  Future<List<StrategyGuide>> getStrategyGuides({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('strategy_guides')
          .orderBy('difficulty')
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              StrategyGuide.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching strategy guides: $e');
      return [];
    }
  }

  /// Start lesson
  Future<void> startLesson(String userId, String lessonId) async {
    try {
      final progress = UserLessonProgress(
        id: _firestore.collection('user_lesson_progress').doc().id,
        userId: userId,
        lessonId: lessonId,
        status: LessonStatus.inProgress,
        percentageComplete: 0,
        timesReviewed: 0,
        startedDate: DateTime.now(),
        completedDate: null,
        lastAccessedDate: DateTime.now(),
        selfAssessmentScore: 0.0,
        notesAdded: [],
        interactionData: {},
      );

      await _firestore
          .collection('user_lesson_progress')
          .doc(progress.id)
          .set(progress.toJson());
    } catch (e) {
      print('Error starting lesson: $e');
      rethrow;
    }
  }

  /// Update lesson progress
  Future<void> updateLessonProgress(
    String userId,
    String lessonId,
    int percentageComplete,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_lesson_progress')
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final docId = querySnapshot.docs.first.id;
      final status = percentageComplete >= 100
          ? LessonStatus.completed
          : LessonStatus.inProgress;

      await _firestore
          .collection('user_lesson_progress')
          .doc(docId)
          .update({
            'percentageComplete': percentageComplete,
            'status': status.name,
            'lastAccessedDate': DateTime.now().toIso8601String(),
            if (status == LessonStatus.completed)
              'completedDate': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Error updating lesson progress: $e');
      rethrow;
    }
  }

  /// Get user progress for a lesson
  Future<UserLessonProgress?> getUserLessonProgress(
    String userId,
    String lessonId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_lesson_progress')
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      return UserLessonProgress.fromJson(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching user lesson progress: $e');
      return null;
    }
  }

  /// Get all user progress
  Future<List<UserLessonProgress>> getUserProgress(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_lesson_progress')
          .where('userId', isEqualTo: userId)
          .orderBy('lastAccessedDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              UserLessonProgress.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user progress: $e');
      return [];
    }
  }

  /// Add note to lesson
  Future<void> addNoteToLesson(
    String userId,
    String lessonId,
    String note,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_lesson_progress')
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final docId = querySnapshot.docs.first.id;
      final doc = querySnapshot.docs.first.data();
      final notes = List<String>.from(doc['notesAdded'] as List? ?? []);
      notes.add(note);

      await _firestore
          .collection('user_lesson_progress')
          .doc(docId)
          .update({'notesAdded': notes});
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  /// Get lesson collections
  Future<List<LessonCollection>> getLessonCollections(
      {DifficultyLevel? difficulty}) async {
    try {
      Query query = _firestore.collection('lesson_collections');

      if (difficulty != null) {
        query = query.where('targetDifficulty', isEqualTo: difficulty.name);
      }

      final querySnapshot = await query
          .orderBy('createdDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              LessonCollection.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching lesson collections: $e');
      return [];
    }
  }

  /// Rate lesson
  Future<void> rateLessonCompletion(
    String userId,
    String lessonId,
    double score,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_lesson_progress')
          .where('userId', isEqualTo: userId)
          .where('lessonId', isEqualTo: lessonId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return;

      final docId = querySnapshot.docs.first.id;

      await _firestore
          .collection('user_lesson_progress')
          .doc(docId)
          .update({'selfAssessmentScore': score});
    } catch (e) {
      print('Error rating lesson: $e');
      rethrow;
    }
  }

  /// Get statistics for opening
  Future<Map<String, dynamic>> getOpeningStatistics(String ecoCode) async {
    try {
      final opening = await getOpeningByEco(ecoCode);
      if (opening == null) return {};

      return {
        'totalGames': opening.totalGamesWithOpening,
        'winRateWhite': opening.winRateWhite,
        'winRateBlack': opening.winRateBlack,
        'drawRate': opening.drawRate,
        'name': opening.name,
        'difficulty': opening.difficulty.name,
      };
    } catch (e) {
      print('Error fetching opening statistics: $e');
      return {};
    }
  }
}
