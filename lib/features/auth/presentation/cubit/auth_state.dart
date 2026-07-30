import 'package:equatable/equatable.dart';
import '../../../../core/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// Replaces AuthSuccess to match our UI
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

// Replaces AuthFailure to match our UI
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthVerificationNeeded extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthPasswordResetSent extends AuthState {}
