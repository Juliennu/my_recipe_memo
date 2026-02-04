import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_recipe_memo/features/auth/data/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_providers.g.dart';

@riverpod
Stream<User?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
}

@riverpod
String? currentUserId(Ref ref) {
  return ref.watch(authStateProvider).value?.uid;
}

@riverpod
String? currentUserEmail(Ref ref) {
  return ref.watch(authStateProvider).value?.email;
}

@riverpod
bool isAnonymousUser(Ref ref) {
  return ref.watch(authStateProvider).value?.isAnonymous ?? false;
}
