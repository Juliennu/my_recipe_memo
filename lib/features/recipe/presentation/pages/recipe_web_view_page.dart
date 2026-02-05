import 'package:flutter/material.dart';
import 'package:my_recipe_memo/core/theme/app_colors.dart';
import 'package:my_recipe_memo/core/theme/app_text_styles.dart';
import 'package:my_recipe_memo/core/utils/url_utils.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecipeWebViewPage extends StatefulWidget {
  const RecipeWebViewPage({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<RecipeWebViewPage> createState() => _RecipeWebViewPageState();
}

class _RecipeWebViewPageState extends State<RecipeWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _lastLoadedUrl;

  @override
  void initState() {
    super.initState();
    // 画面常時点灯を有効化
    WakelockPlus.enable();

    final initialUri = normalizeToWebUrl(widget.url);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // エラーハンドリングが必要ならここに記述
          },
          onNavigationRequest: (NavigationRequest request) async {
            final normalized = normalizeToWebUrl(request.url);
            if (normalized != null &&
                normalized.toString() != request.url &&
                normalized.toString() != _lastLoadedUrl) {
              _lastLoadedUrl = normalized.toString();
              await _controller.loadRequest(normalized);
              return NavigationDecision.prevent;
            }

            if (isWebScheme(Uri.parse(request.url))) {
              _lastLoadedUrl = request.url;
              return NavigationDecision.navigate;
            }

            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(initialUri ?? Uri.parse('about:blank'));
    _lastLoadedUrl = (initialUri ?? Uri.parse('about:blank')).toString();

    if (initialUri == null) {
      Future<void>.microtask(() async {
        final external = Uri.tryParse(widget.url);
        await launchExternalIfPossible(widget.url);
        if (mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  @override
  void dispose() {
    // 画面常時点灯を無効化（画面を離れるとき）
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text),
        titleTextStyle: AppTextStyles.size16Bold(),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}
