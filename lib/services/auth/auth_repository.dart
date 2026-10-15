// lib/services/auth/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../core/enums/user_role.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

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
        createdAt: DateTime.now(),
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

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    return UserModel.fromJson(userDoc.data()!);
  }
}