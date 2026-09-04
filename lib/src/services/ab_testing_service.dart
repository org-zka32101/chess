import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/roadmap.dart';

/// A/B Testing Service
class ABTestingService {
  static final ABTestingService _instance = ABTestingService._internal();

  final FirebaseFirestore _firestore;
  final Random _random = Random();

  factory ABTestingService({FirebaseFirestore? firestore}) {
    if (firestore != null) {
      _instance._firestore = firestore;
    }
    return _instance;
  }

  ABTestingService._internal() : _firestore = FirebaseFirestore.instance;

  /// Create A/B test
  Future<void> createTest({
    required String name,
    required String description,
    required List<Variant> variants,
    required List<String> targetMetrics,
    required int sampleSize,
    required double confidenceLevel,
  }) async {
    try {
      final test = ABTest(
        id: _firestore.collection('ab_tests').doc().id,
        name: name,
        description: description,
        startDate: DateTime.now(),
        endDate: null,
        status: TestStatus.active,
        variants: variants,
        targetMetrics: targetMetrics,
        sampleSize: sampleSize,
        confidenceLevel: confidenceLevel,
        winner: null,
        statisticalSignificance: null,
        results: null,
      );

      await _firestore.collection('ab_tests').doc(test.id).set(test.toJson());
    } catch (e) {
      print('A/B test creation error: $e');
      rethrow;
    }
  }

  /// Assign variant to user
  String assignVariant(String userId, String testId, List<Variant> variants) {
    // Deterministic assignment based on user ID
    final hash = userId.hashCode.abs();
    final variantIndex = hash % variants.length;
    return variants[variantIndex].id;
  }

  /// Record metric for test
  Future<void> recordMetric(
    String testId,
    String userId,
    String metricName,
    double value,
  ) async {
    try {
      await _firestore
          .collection('ab_tests')
          .doc(testId)
          .collection('metrics')
          .doc('${userId}_$metricName')
          .set({
            'userId': userId,
            'metricName': metricName,
            'value': value,
            'timestamp': DateTime.now().toIso8601String(),
          });
    } catch (e) {
      print('Metric recording error: $e');
      rethrow;
    }
  }

  /// Analyze test results
  Future<void> analyzeTest(String testId) async {
    try {
      final testDoc = await _firestore.collection('ab_tests').doc(testId).get();
      if (!testDoc.exists) return;

      final testData = testDoc.data() as Map<String, dynamic>;
      final variants = (testData['variants'] as List<dynamic>?)
          ?.map((v) => Variant.fromJson(v as Map<String, dynamic>))
          .toList() ?? [];

      if (variants.length < 2) return;

      // Fetch metrics for each variant
      final metricsSnapshot = await _firestore
          .collection('ab_tests')
          .doc(testId)
          .collection('metrics')
          .get();

      final metrics = metricsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Calculate statistics (simplified)
      final controlMetrics = _calculateMetrics(metrics, variants[0].id);
      final treatmentMetrics = _calculateMetrics(metrics, variants[1].id);

      final significance = _calculateSignificance(controlMetrics, treatmentMetrics);

      final result = TestResult(
        controlVariantMetrics: controlMetrics,
        treatmentVariantMetrics: treatmentMetrics,
        statisticalSignificance: significance,
        confidenceInterval: [significance - 0.05, significance + 0.05],
        recommendation: significance > 0.95
            ? 'Treatment variant is significantly better'
            : 'No significant difference detected',
      );

      await _firestore.collection('ab_tests').doc(testId).update({
        'results': result.toJson(),
        'statisticalSignificance': significance,
        'status': TestStatus.concluded.name,
        'endDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Test analysis error: $e');
      rethrow;
    }
  }

  /// Get active tests
  Future<List<ABTest>> getActiveTests() async {
    try {
      final querySnapshot = await _firestore
          .collection('ab_tests')
          .where('status', isEqualTo: TestStatus.active.name)
          .get();

      return querySnapshot.docs
          .map((doc) => ABTest.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching active tests: $e');
      return [];
    }
  }

  /// Get test results
  Future<ABTest?> getTestResults(String testId) async {
    try {
      final doc = await _firestore.collection('ab_tests').doc(testId).get();
      if (!doc.exists) return null;
      return ABTest.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching test results: $e');
      return null;
    }
  }

  /// Helper: Calculate metrics
  Map<String, double> _calculateMetrics(
    List<Map<String, dynamic>> metrics,
    String variantId,
  ) {
    final variantMetrics = <String, List<double>>{};

    for (final metric in metrics) {
      final value = metric['value'] as double?;
      final metricName = metric['metricName'] as String?;

      if (value != null && metricName != null) {
        variantMetrics.putIfAbsent(metricName, () => []).add(value);
      }
    }

    final result = <String, double>{};
    for (final entry in variantMetrics.entries) {
      final average =
          entry.value.reduce((a, b) => a + b) / entry.value.length;
      result[entry.key] = average;
    }

    return result;
  }

  /// Helper: Calculate statistical significance
  double _calculateSignificance(
    Map<String, double> controlMetrics,
    Map<String, double> treatmentMetrics,
  ) {
    if (controlMetrics.isEmpty || treatmentMetrics.isEmpty) return 0.0;

    // Simplified calculation - compare averages
    final controlAverage =
        controlMetrics.values.reduce((a, b) => a + b) / controlMetrics.length;
    final treatmentAverage = treatmentMetrics.values.reduce((a, b) => a + b) /
        treatmentMetrics.length;

    final difference = (treatmentAverage - controlAverage).abs();
    final maxValue = [controlAverage, treatmentAverage].reduce(max);

    if (maxValue == 0) return 0.5;
    return 0.5 + (difference / maxValue) * 0.5;
  }

  /// Conclude test
  Future<void> concludeTest(String testId, String? winner) async {
    try {
      await _firestore.collection('ab_tests').doc(testId).update({
        'status': TestStatus.concluded.name,
        'endDate': DateTime.now().toIso8601String(),
        'winner': winner,
      });
    } catch (e) {
      print('Test conclusion error: $e');
      rethrow;
    }
  }
}
