import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import 'api_client.dart';

import '../state/auth_provider.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    baseUrl: AppConfig.baseUrl,
    onUnauthorized: () => ref.read(authProvider.notifier).logout(),
  );
});
