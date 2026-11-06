import 'dart:async';

/// Snapshot of the signed-in Firebase user, kept free of Firebase types so
/// UI and tests never import the SDK.
class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.emailVerified,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  /// Only verified users may reach cloud presets or a RevenueCat identity.
  bool get isVerified => emailVerified;

  /// RevenueCat app user id, or null while this user must stay anonymous.
  String? get revenueCatUserId => isVerified ? uid : null;

  String get firstName => _splitName().$1;
  String get lastName => _splitName().$2;

  (String, String) _splitName() {
    final name = (displayName ?? '').trim();
    final space = name.indexOf(' ');
    if (space < 0) return (name, '');
    return (name.substring(0, space), name.substring(space + 1).trim());
  }
}

enum AuthErrorCode {
  emailInUse,
  invalidEmail,
  weakPassword,
  wrongCredentials,
  userNotFound,
  network,
  tooManyRequests,
  requiresRecentLogin,
  unavailable,
  unknown,
}

class AuthException implements Exception {
  const AuthException(this.code, [this.message]);

  final AuthErrorCode code;
  final String? message;

  @override
  String toString() =>
      'AuthException($code${message == null ? '' : ': $message'})';
}

/// The server refused a cloud call because there is no verified sign-in
/// (or an old client without a token): the user must sign in.
class SignInRequiredException implements Exception {
  const SignInRequiredException();

  @override
  String toString() => 'SignInRequiredException';
}

abstract class AuthService {
  /// False when no auth backend is configured (e.g. the Firebase config file
  /// is missing); the app then behaves as guest-only.
  bool get available;

  AuthUser? get currentUser;

  Stream<AuthUser?> get userChanges;

  Future<AuthUser> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Firebase ID token of the signed-in user (null when signed out). The
  /// preset backend verifies it server-side; it never trusts a bare email.
  Future<String?> getIdToken({bool forceRefresh = false});

  Future<void> sendVerificationEmail();

  /// Reloads the user from the server (picks up a verification done in the
  /// mail app) and returns the fresh snapshot.
  Future<AuthUser?> reload();

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  /// Deletes the Firebase user. Throws [AuthException] with
  /// [AuthErrorCode.requiresRecentLogin] when a fresh login is needed; call
  /// [reauthenticate] and retry.
  Future<void> deleteUser();

  /// Re-proves identity with the account password.
  Future<void> reauthenticate({required String password});
}

/// Process-wide access point; `main` swaps in the Firebase implementation,
/// tests swap in a fake.
class AuthServices {
  AuthServices._();

  static AuthService instance = const UnavailableAuthService();
}

class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  bool get available => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get userChanges => const Stream.empty();

  Never _fail() => throw const AuthException(AuthErrorCode.unavailable);

  @override
  Future<AuthUser> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async => _fail();

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async => _fail();

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> sendVerificationEmail() async => _fail();

  @override
  Future<AuthUser?> reload() async => null;

  @override
  Future<void> sendPasswordReset(String email) async => _fail();

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteUser() async {}

  @override
  Future<void> reauthenticate({required String password}) async => _fail();
}

/// ID token for a cloud call, or [SignInRequiredException] when signed out.
Future<String> requireIdToken({bool forceRefresh = false}) async {
  final token = await AuthServices.instance.getIdToken(
    forceRefresh: forceRefresh,
  );
  if (token == null || token.isEmpty) throw const SignInRequiredException();
  return token;
}

/// The server could not check the token right now (Google 429/5xx): a
/// "try again later" case, not a sign-in problem.
class CloudUnavailableException implements Exception {
  const CloudUnavailableException();

  @override
  String toString() => 'CloudUnavailableException';
}

/// Server-side auth rejections from the Apps Script backend.
void throwIfSignInRequired(Map<dynamic, dynamic> body) {
  const codes = {
    'update_required',
    'auth_required',
    'invalid_token',
    'email_not_verified',
  };
  if (body['ok'] == true) return;
  if (body['error'] == 'auth_unavailable') {
    throw const CloudUnavailableException();
  }
  if (codes.contains(body['error'])) throw const SignInRequiredException();
}
