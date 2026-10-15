// lib/services/auth/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../core/enums/user_role.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login
  Future<UserModel> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      final userData = userDoc.data()!;
      userData['id'] = result.user!.uid;
      userData['emailVerified'] = result.user!.emailVerified;

      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Register
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required UserRole role,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        mobile: mobile,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
        emailVerified: result.user!.emailVerified,
      );

      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      userData['id'] = user.uid;
      userData['emailVerified'] = user.emailVerified;

      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update password
  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Re-authenticate first
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Update password
    await user.updatePassword(newPassword);
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    await user.sendEmailVerification();
  }

  // Check email verification
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return user.emailVerified;
  }

  // Delete account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Delete user data from Firestore
    await _firestore.collection('users').doc(user.uid).delete();

    // Delete auth account
    await user.delete();
  }
}