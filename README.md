# My Recipe Memo

自分だけのレシピを記録・管理するためのFlutterアプリケーションです。

## 🚀 環境 (Environment)

開発環境の統一に **FVM (Flutter Version Management)** を利用しています。

- **Flutter SDK**: `3.38.9` (FVM)
- **Dart SDK**: FVMに準拠
- **Xcode**: `26.2`

### 最低サポートバージョン

- **iOS**: `17.0` 以上
- **Android**: `API 29` (Android 10) 以上

### 前提条件 (Prerequisites)

- [FVM](https://fvm.app/) のインストール

  ```bash
  dart pub global activate fvm
  ```

- VS Code (推奨)
  - Dart / Flutter 拡張機能
  - 設定ファイル (`.vscode/settings.json`) はリポジトリに含まれており、FVMのSDKを自動認識するように設定されています。

## 🛠️ セットアップ (Setup)

1. **リポジトリのクローン**

   ```bash
   git clone <repository-url>
   cd my_recipe_memo
   ```

2. **Flutter SDKのインストール (FVM)**

   プロジェクトルートで以下のコマンドを実行し、設定されたバージョンのFlutter SDKをインストールします。

   ```bash
   fvm install
   ```

3. **依存パッケージのインストール**

   ```bash
   fvm flutter pub get
   ```

4. **Firebase設定ファイルの生成**

   ⚠️ **重要**: Firebase設定ファイルはセキュリティ上の理由でGitリポジトリに含まれていません。以下の手順で生成してください。

   a. Firebase CLI にログイン:

   ```bash
   firebase login
   ```

   b. FlutterFire CLI をインストール (初回のみ):

   ```bash
   dart pub global activate flutterfire_cli
   ```

   c. Firebase設定ファイルを生成:

   ```bash
   dart pub global run flutterfire_cli:flutterfire configure --project=my-recipe-memo
   ```

   このコマンドで以下のファイルが生成されます:
   - `lib/firebase_options.dart`
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

5. **コード生成 (build_runner)**

   Riverpod, Freezed, GoRouterなどのコード生成を行います。

   ```bash
   fvm dart run build_runner build -d
   ```

## 📱 実行方法 (Running the App)

### VS Code から実行する場合 (推奨)

1. コマンドパレット (`Cmd+Shift+P`) から `Flutter: Select Device` を選択し、シミュレーターまたは実機を選択します。
2. `F5` キーを押すか、"Run and Debug" サイドバーから実行します。

※ VS Codeの設定でFVMのパスを読み込むようになっているため、通常の操作でFVM指定のバージョンが使用されます。

### ターミナルから実行する場合

```bash
fvm flutter run
```

## 🏗️ 技術スタック (Tech Stack)

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: [Riverpod](https://riverpod.dev/) (Hooks, Generator)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Code Generation**: [Freezed](https://pub.dev/packages/freezed), [Riverpod Generator](https://pub.dev/packages/riverpod_generator)
- **Backend**: Firebase (Auth, Firestore)
- **Linting**: flutter_lints, custom_lint, riverpod_lint

