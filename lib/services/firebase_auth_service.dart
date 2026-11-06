import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'auth_service.dart';

/// Initialises Firebase and returns the real [AuthService], or the
/// unavailable one when the platform config file is not bundled yet
/// (ios/Runner/GoogleService-Info.plist) -- calling initializeApp without
/// it aborts the process natively, so check for the file first.
Future<AuthService> createAuthService() async {
  try {
    if (!kIsWeb && Platform.isIOS) {
      final plist = File(
        '${File(Platform.resolvedExecutable).parent.path}/GoogleService-Info.plist',
      );
      if (!plist.existsSync()) {
        debugPrint('GoogleService-Info.plist missing: auth disabled.');
        return const UnavailableAuthService();
      }
    }
    await Firebase.initializeApp();
    return FirebaseAuthService();
  } catch (error) {
    debugPrint('Firebase init failed, auth disabled: $error');
    return const UnavailableAuthService();
  }
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth})
    : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  @override
  bool get available => true;

  static AuthUser? _map(fb.User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email?.toLowerCase(),
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> get userChanges => _auth.userChanges().map(_map);

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_codeFor(e.code), e.message);
    }
  }

  static AuthErrorCode _codeFor(String code) => switch (code) {
    'email-already-in-use' => AuthErrorCode.emailInUse,
    'invalid-email' => AuthErrorCode.invalidEmail,
    'weak-password' => AuthErrorCode.weakPassword,
    'wrong-password' ||
    'invalid-credential' ||
    'invalid-login-credentials' => AuthErrorCode.wrongCredentials,
    'user-not-found' => AuthErrorCode.userNotFound,
    'network-request-failed' => AuthErrorCode.network,
    'too-many-requests' => AuthErrorCode.tooManyRequests,
    'user-disabled' => AuthErrorCode.wrongCredentials,
    'requires-recent-login' => AuthErrorCode.requiresRecentLogin,
    _ => AuthErrorCode.unknown,
  };

  @override
  Future<AuthUser> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName('${firstName.trim()} ${lastName.trim()}');
    await user.sendEmailVerification();
    await user.reload();
    return _map(_auth.currentUser)!;
  });

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) => _guard(() async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.reload();
    return _map(_auth.currentUser)!;
  });

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) =>
      _guard(() async => _auth.currentUser?.getIdToken(forceRefresh));

  @override
  Future<void> sendVerificationEmail() =>
      _guard(() async => _auth.currentUser?.sendEmailVerification());

  @override
  Future<AuthUser?> reload() => _guard(() async {
    await _auth.currentUser?.reload();
    return _map(_auth.currentUser);
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> deleteUser() => _guard(() async => _auth.currentUser?.delete());

  @override
  Future<void> reauthenticate({required String password}) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reauthenticateWithCredential(
      fb.EmailAuthProvider.credential(
        email: user.email ?? '',
        password: password,
      ),
    );
  });
}
