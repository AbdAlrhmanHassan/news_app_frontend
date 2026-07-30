import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/entities/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit(this._authRepo) : super(AuthInitial());

  // ===========================================================================
  // 🚀 SMART APP START (Auto Login)
  // ===========================================================================
  Future<void> appStarted() async {
    final cachedUser = _authRepo.getCurrentUser();

    if (cachedUser != null) {
      final verificationResult = await _authRepo.checkVerificationStatus();

      verificationResult.fold(
        (failure) {
          emit(AuthVerificationNeeded());
        },
        (isVerified) {
          if (!isVerified && !cachedUser.isGuest) {
            // Note: Guests don't need verification
            emit(AuthVerificationNeeded());
          } else {
            emit(AuthAuthenticated(user: cachedUser));
          }
        },
      );
    } else {
      emit(Unauthenticated());
    }
  }

  // ===========================================================================
  // 🚀 NEW: GUEST LOGIN
  // ===========================================================================
  Future<void> signInAsGuest() async {
    emit(AuthLoading());
    final result = await _authRepo.signInAnonymously();

    result.fold((failure) {
      log("Guest Sign-In failed: ${failure.message}");
      emit(AuthError(message: failure.message));
    }, (user) => emit(AuthAuthenticated(user: user)));
  }

  // ===========================================================================
  // EXISTING AUTH METHODS
  // ===========================================================================

  UserEntity? getCurrentUser() {
    return _authRepo.getCurrentUser();
  }

  // ✅ Cancel Registration / Auto-Cleanup
  Future<void> cancelRegistration() async {
    emit(AuthLoading());
    final result = await _authRepo.deleteAccount();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  // ✅ Google Sign In
  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await _authRepo.loginWithGoogle();
    result.fold(
      (failure) {
        log("Google Sign-In failed: ${failure.message}");
        emit(AuthError(message: failure.message));
      },
      (user) {
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  // ✅ Apple Sign In
  Future<void> signInWithApple() async {
    emit(AuthLoading());
    final result = await _authRepo.loginWithApple();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  // ✅ Email Login
  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthLoading());
    final result = await _authRepo.loginWithEmail(email, password);
    result.fold(
      (failure) {
        if (failure.message.contains('email-not-verified')) {
          emit(AuthVerificationNeeded());
        } else {
          emit(AuthError(message: failure.message));
        }
      },
      (user) {
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  // ✅ Register
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String username,
    String? country, // 🚀 NEW
    String? region, // 🚀 NEW
  }) async {
    emit(AuthLoading());
    // Note: You will need to update AuthRepo and AuthRepoImpl to pass these down to Firebase!
    final result = await _authRepo.registerWithEmail(
      email,
      password,
      username,
      country,
      region,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthVerificationNeeded()),
    );
  }

  // ✅ Check Verification Status
  Future<void> checkVerificationStatus({bool silent = false}) async {
    if (!silent) emit(AuthLoading());

    final result = await _authRepo.checkVerificationStatus();

    result.fold(
      (failure) {
        if (!silent) emit(AuthError(message: failure.message));
        emit(AuthVerificationNeeded());
      },
      (isVerified) {
        if (isVerified) {
          final user = _authRepo.getCurrentUser();
          if (user != null) {
            emit(AuthAuthenticated(user: user));
          }
        } else {
          if (!silent) emit(AuthError(message: "Email still not verified."));
          emit(AuthVerificationNeeded());
        }
      },
    );
  }

  // ✅ Resend Verification
  Future<void> resendVerificationEmail() async {
    final result = await _authRepo.resendVerificationEmail();
    result.fold((failure) => emit(AuthError(message: failure.message)), (_) {
      log("Verification email resent");
    });
  }

  // ✅ Logout
  Future<void> logout() async {
    await _authRepo.signOut();
    emit(Unauthenticated());
  }

  // ✅ Delete Account
  Future<void> deleteAccount({required String password}) async {
    emit(AuthLoading());
    final result = await _authRepo.deleteAccount(password: password);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> deleteAccountSocial() async {
    emit(AuthLoading());
    final result = await _authRepo.deleteAccountSocial();
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  // ✅ Reset Password
  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      emit(AuthError(message: "Please enter your email"));
      return;
    }

    emit(AuthLoading());
    final result = await _authRepo.sendPasswordResetEmail(email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(AuthPasswordResetSent()),
    );
  }

  // ✅ Sign Out
  Future<void> signOut() async {
    emit(AuthLoading()); // Optional: show loading while signing out
    await _authRepo.signOut();
    emit(Unauthenticated()); // Emits the exact state the UI is waiting for!
  }
}
