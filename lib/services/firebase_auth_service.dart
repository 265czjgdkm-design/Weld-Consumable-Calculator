import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
      isApple: user.providerData.any((p) => p.providerId == 'apple.com'),
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
    } on SignInWithAppleAuthorizationException catch (e) {
      throw AuthException(
        e.code == AuthorizationErrorCode.canceled
            ? AuthErrorCode.cancelled
            : AuthErrorCode.unknown,
        e.message,
      );
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
    'requires-recent-login' => AuthErrorCode.requiresRecentLogin,
    'canceled' || 'popup-closed-by-user' => AuthErrorCode.cancelled,
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

  static String _nonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  Future<fb.OAuthCredential> _appleCredential() async {
    final rawNonce = _nonce();
    final apple = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: _sha256(rawNonce),
    );
    final credential = fb.OAuthProvider('apple.com').credential(
      idToken: apple.identityToken,
      rawNonce: rawNonce,
      accessToken: apple.authorizationCode,
    );
    _lastAppleName = [
      apple.givenName,
      apple.familyName,
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    return credential;
  }

  String _lastAppleName = '';

  @override
  Future<AppleSignInResult> signInWithApple() => _guard(() async {
    final credential = await _appleCredential();
    final result = await _auth.signInWithCredential(credential);
    final user = result.user!;
    // Apple sends the name only on the very first authorization.
    if ((user.displayName ?? '').isEmpty && _lastAppleName.isNotEmpty) {
      await user.updateDisplayName(_lastAppleName);
      await user.reload();
    }
    return AppleSignInResult(
      user: _map(_auth.currentUser)!,
      isNewUser: result.additionalUserInfo?.isNewUser ?? false,
    );
  });

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
  Future<void> reauthenticate({String? password}) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (user.providerData.any((p) => p.providerId == 'apple.com')) {
      await user.reauthenticateWithCredential(await _appleCredential());
    } else {
      await user.reauthenticateWithCredential(
        fb.EmailAuthProvider.credential(
          email: user.email ?? '',
          password: password ?? '',
        ),
      );
    }
  });
}
