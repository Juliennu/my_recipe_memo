import 'package:url_launcher/url_launcher.dart';

/// Returns true when the URI uses http/https with a host.
bool isWebScheme(Uri uri) {
  return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
}

/// Normalizes common SNS deep links into web URLs suitable for WebView.
Uri? normalizeToWebUrl(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null) {
    return null;
  }

  if (isWebScheme(uri)) {
    return uri;
  }

  if (uri.scheme == 'instagram') {
    final shortcode =
        uri.queryParameters['shortcode'] ??
        (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null);
    if (shortcode != null && shortcode.isNotEmpty) {
      return Uri.https('www.instagram.com', '/reel/$shortcode');
    }
  }

  if (uri.scheme == 'vnd.youtube' || uri.scheme == 'youtube') {
    final id =
        uri.queryParameters['v'] ??
        (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null);
    if (id != null && id.isNotEmpty) {
      return Uri.https('www.youtube.com', '/watch', {'v': id});
    }
  }

  if (uri.scheme.contains('tiktok') || uri.host.contains('tiktok')) {
    if (uri.pathSegments.isNotEmpty) {
      return Uri.https('www.tiktok.com', '/${uri.pathSegments.join('/')}');
    }
  }

  if (uri.scheme == 'lemon8' || uri.host.contains('lemon8')) {
    final id =
        uri.queryParameters['id'] ??
        (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null);
    if (id != null && id.isNotEmpty) {
      return Uri.https('www.lemon8-app.com', '/post/$id');
    }
  }

  if (uri.scheme == 'twitter' || uri.scheme == 'x') {
    final statusId =
        uri.queryParameters['id'] ??
        uri.queryParameters['status_id'] ??
        (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null);
    if (statusId != null && statusId.isNotEmpty) {
      return Uri.https('x.com', '/i/status/$statusId');
    }

    final screenName = uri.queryParameters['screen_name'];
    if (screenName != null && screenName.isNotEmpty) {
      return Uri.https('x.com', '/$screenName');
    }
  }

  if (uri.host.contains('x.com') || uri.host.contains('twitter.com')) {
    return Uri.https(
      'x.com',
      '/${uri.pathSegments.join('/')}',
      uri.queryParameters.isEmpty ? null : uri.queryParameters,
    );
  }

  if (uri.host.isNotEmpty) {
    return Uri.https(
      uri.host,
      '/${uri.pathSegments.join('/')}',
      uri.queryParameters.isEmpty ? null : uri.queryParameters,
    );
  }

  return null;
}

/// Attempts to launch external apps; used as a fallback when WebView can't load.
Future<void> launchExternalIfPossible(String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
