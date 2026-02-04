import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
}

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInAnonymously() async {
    return _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // アカウント連携（匿名 -> 永久）
  Future<UserCredential> linkWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is null');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    return user.linkWithCredential(credential);
  }

  // ログイン（既存アカウントへの切り替え）
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // 新規登録（いきなりメールで作る場合）
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
