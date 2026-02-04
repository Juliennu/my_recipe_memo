import 'package:my_recipe_memo/features/auth/data/auth_repository.dart';
import 'package:my_recipe_memo/features/recipe/data/recipe_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() async {
    // 状態管理のみを行うため、初期化処理は不要
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInAnonymously();
    });
  }

  Future<void> linkAccount(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .linkWithEmailAndPassword(email, password);
    });
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final currentUser = authRepository.currentUser;

      // 匿名ユーザーの場合はアカウントとデータを削除してからログインする
      if (currentUser != null && currentUser.isAnonymous) {
        await ref.read(recipeRepositoryProvider).deleteAllUserRecipes();
        await authRepository.deleteAccount();
      }

      await authRepository.signInWithEmailAndPassword(email, password);
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);

      // 1. Google認証情報を取得（ユーザーキャンセル時はnull）
      final credential = await authRepository.getGoogleCredential();
      if (credential == null) {
        // キャンセルの場合は何もしない
        return;
      }

      final currentUser = authRepository.currentUser;

      // 2. 匿名ユーザーの場合はアカウントとデータを削除
      if (currentUser != null && currentUser.isAnonymous) {
        await ref.read(recipeRepositoryProvider).deleteAllUserRecipes();
        await authRepository.deleteAccount();
      }

      // 3. 取得したクレデンシャルでサインイン
      await authRepository.signInWithCredential(credential);
    });
  }

  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    try {
      await authRepository.signOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAccount() async {
    final link = ref.keepAlive();
    state = const AsyncLoading();
    try {
      // 1. レシピデータの削除
      // Note: 本来はCloud Functionsなどでやるべきだが、簡易的にクライアントサイドで実装
      await ref.read(recipeRepositoryProvider).deleteAllUserRecipes();

      // 2. Authアカウントの削除
      await ref.read(authRepositoryProvider).deleteAccount();

      // 成功時はstateを更新しない（アカウント削除によりプロバイダーが破棄されている可能性があるため）
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    } finally {
      link.close();
    }
  }
}
