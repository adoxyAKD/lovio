import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/deep_link_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_notifier.dart';

/// Root Lovio Application Widget with dynamic theme, appearance & deep link support
class LovioApp extends ConsumerStatefulWidget {
  const LovioApp({super.key});

  @override
  ConsumerState<LovioApp> createState() => _LovioAppState();
}

class _LovioAppState extends ConsumerState<LovioApp> {
  @override
  void initState() {
    super.initState();
    // Initialize active deep link listener for cold-start and warm-start links
    DeepLinkService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Lovio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(themeState.currentPreset),
      darkTheme: AppTheme.buildDarkTheme(themeState.currentPreset),
      themeMode: themeState.themeMode,
      routerConfig: router,
    );
  }
}
