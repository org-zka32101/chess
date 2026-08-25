import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/user.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  /// Get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Get current app user from Firestore
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  /// Register with email and password
  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _logger.i('Registering user with email: $email');

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Failed to create Firebase user');
      }

      // Update profile
      await firebaseUser.updateDisplayName(displayName);

      // Create user document in Firestore
      final newUser = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? email,
        displayName: displayName,
        photoUrl: firebaseUser.photoURL,
        emailVerified: firebaseUser.emailVerified,
        rating: 1500, // Default starting rating
        onlineRating: 1500,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(newUser.toJson());

      _logger.i('User registered successfully: ${firebaseUser.uid}');
      return newUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error registering user: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Signing in user with email: $email');

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = await getCurrentUser();
      _logger.i('User signed in successfully: ${user?.uid}');
      return user;
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error signing in: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      _logger.i('Signing in with Google');

      // TODO: Implement Google Sign-In
      // This requires google_sign_in package setup
      throw UnimplementedError('Google Sign-In not yet implemented');
    } catch (e) {
      _logger.e('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign in with Apple
  Future<UserModel?> signInWithApple() async {
    try {
      _logger.i('Signing in with Apple');

      // TODO: Implement Apple Sign-In
      // This requires sign_in_with_apple package setup
      throw UnimplementedError('Apple Sign-In not yet implemented');
    } catch (e) {
      _logger.e('Error signing in with Apple: $e');
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent');
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error sending password reset: $e');
      rethrow;
    }
  }

  /// Verify email
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      _logger.i('Sending email verification to: ${user.email}');
      await user.sendEmailVerification();
      _logger.i('Email verification sent');
    } catch (e) {
      _logger.e('Error sending email verification: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      _logger.i('Updating user profile for: ${user.uid}');

      await user.updateDisplayName(displayName ?? user.displayName);
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore
      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      _logger.i('User profile updated');
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      rethrow;
    }
  }

  /// Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      _logger.i('Deleting account for user: ${user.uid}');

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();

      _logger.i('Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      _logger.e('Firebase auth error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      _logger.e('Error deleting account: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _logger.i('Signing out user');
      await _auth.signOut();
      _logger.i('User signed out');
    } catch (e) {
      _logger.e('Error signing out: $e');
      rethrow;
    }
  }

  /// Auth state stream
  Stream<User?> authStateStream() => _auth.authStateChanges();
}
