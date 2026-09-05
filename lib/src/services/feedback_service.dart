import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/feedback.dart';

/// Feedback Service for user feedback collection and management
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();

  final FirebaseFirestore _firestore;

  factory FeedbackService({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      _instance._firestore = firestore;
    }
    return _instance;
  }

  FeedbackService._internal() : _firestore = FirebaseFirestore.instance;

  /// Submit user feedback
  Future<void> submitFeedback({
    required String userId,
    required FeedbackCategory category,
    required String message,
    required int rating,
    required String deviceInfo,
    required String appVersion,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final feedback = UserFeedback(
        id: _firestore.collection('feedback').doc().id,
        userId: userId,
        category: category,
        message: message,
        rating: rating,
        deviceInfo: deviceInfo,
        appVersion: appVersion,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      await _firestore.collection('feedback').doc(feedback.id).set(feedback.toJson());
    } catch (e) {
      print('Feedback error: $e');
      rethrow;
    }
  }

  /// Report a bug
  Future<void> reportBug({
    required String userId,
    required String title,
    required String description,
    String? stackTrace,
    required BugSeverity severity,
    required String deviceInfo,
    required String appVersion,
    required bool reproducible,
    required List<String> steps,
  }) async {
    try {
      final bugReport = BugReport(
        id: _firestore.collection('bug_reports').doc().id,
        userId: userId,
        title: title,
        description: description,
        stackTrace: stackTrace,
        severity: severity,
        deviceInfo: deviceInfo,
        appVersion: appVersion,
        reproducible: reproducible,
        steps: steps,
        status: BugStatus.new_,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('bug_reports').doc(bugReport.id).set(bugReport.toJson());
    } catch (e) {
      print('Bug report error: $e');
      rethrow;
    }
  }

  /// Submit a feature request
  Future<void> submitFeatureRequest({
    required String userId,
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      final request = FeatureRequest(
        id: _firestore.collection('feature_requests').doc().id,
        userId: userId,
        title: title,
        description: description,
        votesCount: 1,
        category: category,
        priority: 0,
        status: RequestStatus.new_,
        timestamp: DateTime.now(),
      );

      await _firestore.collection('feature_requests').doc(request.id).set(request.toJson());
    } catch (e) {
      print('Feature request error: $e');
      rethrow;
    }
  }

  /// Get all feedback
  Future<List<UserFeedback>> getAllFeedback({int limit = 50, String? cursor}) async {
    try {
      Query query = _firestore
          .collection('feedback')
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (cursor != null) {
        final docSnapshot =
            await _firestore.collection('feedback').doc(cursor).get();
        query = query.startAfterDocument(docSnapshot);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => UserFeedback.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching feedback: $e');
      return [];
    }
  }

  /// Get feedback by category
  Future<List<UserFeedback>> getFeedbackByCategory(FeedbackCategory category) async {
    try {
      final querySnapshot = await _firestore
          .collection('feedback')
          .where('category', isEqualTo: category.name)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserFeedback.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching feedback by category: $e');
      return [];
    }
  }

  /// Get all bug reports
  Future<List<BugReport>> getAllBugReports({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('bug_reports')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => BugReport.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching bug reports: $e');
      return [];
    }
  }

  /// Get bug reports by severity
  Future<List<BugReport>> getBugReportsBySeverity(BugSeverity severity) async {
    try {
      final querySnapshot = await _firestore
          .collection('bug_reports')
          .where('severity', isEqualTo: severity.name)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BugReport.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching bug reports by severity: $e');
      return [];
    }
  }

  /// Get feature requests
  Future<List<FeatureRequest>> getFeatureRequests({int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('feature_requests')
          .orderBy('votesCount', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => FeatureRequest.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching feature requests: $e');
      return [];
    }
  }

  /// Upvote a feature request
  Future<void> upvoteFeatureRequest(String requestId) async {
    try {
      await _firestore.collection('feature_requests').doc(requestId).update({
        'votesCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error upvoting feature request: $e');
      rethrow;
    }
  }

  /// Get feedback statistics
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final totalFeedback = await _firestore.collection('feedback').count().get();
      final totalBugs = await _firestore.collection('bug_reports').count().get();
      final totalRequests = await _firestore.collection('feature_requests').count().get();

      final averageRating = await _firestore
          .collection('feedback')
          .get()
          .then((snapshot) {
        if (snapshot.docs.isEmpty) return 0.0;
        final sum =
            snapshot.docs.fold<int>(0, (acc, doc) => acc + (doc['rating'] as int? ?? 0));
        return sum / snapshot.docs.length;
      });

      return {
        'totalFeedback': totalFeedback.count,
        'totalBugReports': totalBugs.count,
        'totalFeatureRequests': totalRequests.count,
        'averageRating': averageRating,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting feedback statistics: $e');
      return {};
    }
  }

  /// Update bug report status
  Future<void> updateBugReportStatus(String bugId, BugStatus status) async {
    try {
      await _firestore.collection('bug_reports').doc(bugId).update({
        'status': status.name,
      });
    } catch (e) {
      print('Error updating bug report status: $e');
      rethrow;
    }
  }

  /// Update feature request status
  Future<void> updateFeatureRequestStatus(
      String requestId, RequestStatus status) async {
    try {
      await _firestore.collection('feature_requests').doc(requestId).update({
        'status': status.name,
      });
    } catch (e) {
      print('Error updating feature request status: $e');
      rethrow;
    }
  }
}
