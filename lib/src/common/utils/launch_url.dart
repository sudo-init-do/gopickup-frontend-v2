import 'package:url_launcher/url_launcher.dart';

/// Opens an external URL robustly across web and mobile.
///
/// Intentionally does NOT call `canLaunchUrl` first: on Flutter web it often
/// returns false, and on Android (API 30+) it returns false unless the target
/// scheme is declared in `<queries>` — both cause buttons to silently do
/// nothing. We just attempt the launch and report success/failure.
Future<bool> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  try {
    return await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (_) {
    // Some platforms reject externalApplication for https; retry with default.
    try {
      return await launchUrl(uri, webOnlyWindowName: '_blank');
    } catch (_) {
      return false;
    }
  }
}
