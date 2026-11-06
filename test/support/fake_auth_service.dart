import 'dart:async';

import 'package:weld_consumable_calculator/services/auth_service.dart';

AuthUser fakeUser({
  String uid = 'uid-1',
  String? email = 'user@example.com',
  String? displayName,
  bool emailVerified = true,
}) => AuthUser(
  uid: uid,
  email: email,
  displayName: displayName,
  emailVerified: emailVerified,
);

class FakeAuthService implements AuthService {
  FakeAuthService({this.user});

  AuthUser? user;
  final _changes = StreamController<AuthUser?>.broadcast();

  /// Set to make the next call of that kind throw.
  AuthException? failNext;

  /// What [reload] reports after the user taps the mail link.
  bool verifiedAfterReload = false;
  bool deleteNeedsReauth = false;

  final signUps = <({String firstName, String lastName, String email})>[];
  final signIns = <String>[];
  final resetRequests = <String>[];
  var verificationMailsSent = 0;
  var signOuts = 0;
  var deletes = 0;
  var reauths = 0;

  @override
  bool get available => true;

  @override
  AuthUser? get currentUser => user;

  @override
  Stream<AuthUser?> get userChanges => _changes.stream;

  void _maybeFail() {
    final error = failNext;
    if (error != null) {
      failNext = null;
      throw error;
    }
  }

  @override
  Future<AuthUser> signUpWithEmail({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _maybeFail();
    signUps.add((firstName: firstName, lastName: lastName, email: email));
    verificationMailsSent++;
    return user = fakeUser(
      uid: 'uid-new',
      email: email.toLowerCase(),
      displayName: '$firstName $lastName',
      emailVerified: false,
    );
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _maybeFail();
    signIns.add(email);
    return user ??= fakeUser(email: email.toLowerCase());
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final current = user;
    return current == null ? null : 'token-${current.uid}';
  }

  @override
  Future<void> sendVerificationEmail() async {
    _maybeFail();
    verificationMailsSent++;
  }

  @override
  Future<AuthUser?> reload() async {
    _maybeFail();
    final current = user;
    if (current != null && verifiedAfterReload && !current.emailVerified) {
      user = fakeUser(
        uid: current.uid,
        email: current.email,
        displayName: current.displayName,
      );
    }
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    _maybeFail();
    resetRequests.add(email);
  }

  @override
  Future<void> signOut() async {
    signOuts++;
    user = null;
  }

  @override
  Future<void> deleteUser() async {
    if (deleteNeedsReauth && reauths == 0) {
      throw const AuthException(AuthErrorCode.requiresRecentLogin);
    }
    _maybeFail();
    deletes++;
    user = null;
  }

  @override
  Future<void> reauthenticate({required String password}) async {
    reauths++;
  }
}
