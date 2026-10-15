// lib/providers/auth_provider.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/user_model.dart';
import '../core/enums/user_role.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/artist/artist_dashboard_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/customer/customer_home_screen.dart';
import '../services/auth/auth_service.dart';
import '../services/database/firestore_service.dart';

// ============================================================================
// Auth State
// ============================================================================

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final bool isEmailVerified;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.isEmailVerified = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    bool? isEmailVerified,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  // Helper getters
  bool get hasError => error != null;
  bool get isAdmin => user?.role == UserRole.admin;
  bool get isArtist => user?.role == UserRole.artist;
  bool get isCustomer => user?.role == UserRole.customer;
  String get userInitial => user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U';
  String get displayName => user?.name ?? 'User';
  String get displayEmail => user?.email ?? 'No Email';
}

// ============================================================================
// Auth Notifier
// ============================================================================

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    // Check auth status on initialization
    checkAuthStatus();
  }

  final AuthService _authService = AuthService();
  final FirestoreService _firestore = FirestoreService();

  // ==========================================================================
  // Authentication Methods
  // ==========================================================================

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        //isEmailVerified: user.emailVerified ?? false,
      );
      return user;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  /// Register a new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String mobile,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.register(
        name: name,
        email: email,
        password: password,
        mobile: mobile,
        role: role,
      );
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
        isEmailVerified: user.emailVerified ?? false,
      );
      return user;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.logout();
      state = AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        //  isEmailVerified: user.emailVerified ?? false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? mobile,
    String? photoUrl,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentUser = state.user;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final updatedUser = currentUser.copyWith(
        name: name ?? currentUser.name,
        email: email ?? currentUser.email,
        mobile: mobile ?? currentUser.mobile,
        photoUrl: photoUrl ?? currentUser.photoUrl,
      );

      await _firestore.updateUser(updatedUser);
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.updatePassword(currentPassword, newPassword);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.sendEmailVerification();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Check email verification status
  Future<void> checkEmailVerification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isVerified = await _authService.isEmailVerified();
      state = state.copyWith(
        isEmailVerified: isVerified,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // ==========================================================================
  // Role-Based Methods
  // ==========================================================================

  /// Check if user has required role
  bool hasRole(UserRole role) {
    return state.user?.role == role;
  }

  /// Check if user has one of the allowed roles
  bool hasAnyRole(List<UserRole> roles) {
    return roles.contains(state.user?.role);
  }

  /// Get user role
  UserRole? get userRole => state.user?.role;

  /// Check if user is admin
  bool get isAdmin => state.user?.role == UserRole.admin;

  /// Check if user is artist
  bool get isArtist => state.user?.role == UserRole.artist;

  /// Check if user is customer
  bool get isCustomer => state.user?.role == UserRole.customer;

  // ==========================================================================
  // Navigation Helpers
  // ==========================================================================

  /// Get dashboard route based on user role
  String getDashboardRoute() {
    switch (state.user?.role) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.artist:
        return '/artist/dashboard';
      case UserRole.customer:
        return '/customer/home';
      default:
        return '/login';
    }
  }

  /// Get appropriate home screen based on role
  Widget getHomeScreen() {
    switch (state.user?.role) {
      case UserRole.admin:
        return const AdminDashboardScreen();
      case UserRole.artist:
        return const ArtistDashboardScreen();
      case UserRole.customer:
        return const CustomerHomeScreen();
      default:
        return const LoginScreen();
    }
  }

  // ==========================================================================
  // Reset State
  // ==========================================================================

  void resetState() {
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// Auth Providers
// ============================================================================

/// Main auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider to get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider to check if user is admin
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});

/// Provider to check if user is artist
final isArtistProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isArtist;
});

/// Provider to check if user is customer
final isCustomerProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isCustomer;
});

/// Provider to get user's role
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authProvider).user?.role;
});

/// Provider to get user's name
final userNameProvider = Provider<String>((ref) {
  return ref.watch(authProvider).user?.name ?? 'User';
});

/// Provider to get user's email
final userEmailProvider = Provider<String>((ref) {
  return ref.watch(authProvider).user?.email ?? 'No Email';
});

/// Provider to get user's initial
final userInitialProvider = Provider<String>((ref) {
  final user = ref.watch(authProvider).user;
  if (user?.name.isNotEmpty == true) {
    return user!.name[0].toUpperCase();
  }
  return 'U';
});

/// Provider for auth loading state
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Provider for auth error
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

/// Provider for email verification status
final emailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isEmailVerified;
});

/// Provider to check if user has specific role
final hasRoleProvider = Provider.family<bool, UserRole>((ref, role) {
  return ref.watch(authProvider).user?.role == role;
});

/// Provider to check if user has any of the allowed roles
final hasAnyRoleProvider = Provider.family<bool, List<UserRole>>((ref, roles) {
  final userRole = ref.watch(authProvider).user?.role;
  return roles.contains(userRole);
});