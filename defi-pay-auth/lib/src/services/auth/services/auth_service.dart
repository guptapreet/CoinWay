import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/user.dart';

abstract class AuthService {
  factory AuthService() => _FirebaseAuthService();
  Future<void> signInWithGoogle();

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String name = '',
  });

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  Future<void> signOut();

  Future<bool> get isSignedIn;

  UserModel? get currentUser;
}

class _MockService implements AuthService {
  _MockService() : _isSignedIn = false;
  bool _isSignedIn;
  UserModel? _user;

  @override
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      _isSignedIn = true;
      _user = UserModel(email: 'dummy@dummy.com', id: 'dummy123');
    });
  }

  @override
  Future<void> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      String name = ''}) async {
    await Future.delayed(const Duration(milliseconds: 3000), () {
      _isSignedIn = true;
      _user = UserModel(email: email, id: password);
    });
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      _isSignedIn = true;
      _user = UserModel(email: email, id: password);
    });
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500), () {});
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500), () {
      _isSignedIn = false;
      _user = null;
    });
  }

  @override
  Future<bool> get isSignedIn async {
    await Future.delayed(const Duration(milliseconds: 500), () {});
    return _isSignedIn;
  }

  @override
  UserModel? get currentUser {
    return _user;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException({
    required this.message,
  });

  @override
  String toString() => message;
}

class _FirebaseAuthService implements AuthService {
  final auth = FirebaseAuth.instance;
  @override
  Future<void> createUserWithEmailAndPassword(
      {required String email,
      required String password,
      String name = ''}) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException(message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException(
            message: 'The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        throw AuthException(message: 'The email provided is invalid.');
      } else if (e.code == 'operation-not-allowed') {
        throw AuthException(message: 'Unsupported Operation');
      }
      rethrow;
    }
  }

  @override
  UserModel? get currentUser {
    return UserModel.fromMap(
        {'email': auth.currentUser!.email, 'id': auth.currentUser!.uid});
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      if (e.code == 'invalid-email') {
        throw AuthException(message: 'The email provided is Invalid.');
      } else if (e.code == 'missing-android-pkg-name') {
        print('e.code : ${e.message}');
        throw AuthException(message: 'Something went wrong');
      } else if (e.code == 'missing-continue-uri') {
        print('e.code : ${e.message}');
        throw AuthException(message: 'Something went wrong');
      } else if (e.code == 'missing-ios-bundle-id') {
        print('e.code : ${e.message}');
        throw AuthException(message: 'Something went wrong');
      } else if (e.code == 'invalid-continue-uri') {
        print('e.code : ${e.message}');
        throw AuthException(message: 'Something went wrong');
      } else if (e.code == 'unauthorized-continue-uri') {
        print('e.code : ${e.message}');
        throw AuthException(message: 'Something went wrong');
      } else if (e.code == 'user-not-found') {
        throw AuthException(message: 'No user associated with provided email.');
      }
      rethrow;
    }
  }

  @override
  Future<bool> get isSignedIn {
    return Future.value(auth.currentUser != null);
  }

  @override
  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw AuthException(message: 'Wrong Password.');
      } else if (e.code == 'user-not-found') {
        throw AuthException(message: 'No user associated with provided email');
      } else if (e.code == 'user-disabled') {
        throw AuthException(message: 'The account is disabled.');
      } else if (e.code == 'invalid-email') {
        throw AuthException(message: 'The email provided is invalid.');
      }
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();
  }
}
