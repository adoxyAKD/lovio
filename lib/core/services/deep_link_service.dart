import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../app/router/app_router.dart';

/// Central Deep Link Handling Service for Lovio
/// Supports both Cold-Start (App closed) and Warm-Start (App running in background)
/// Automatically handles app lifecycle and dismisses any active bottom sheets or modal dialogs
class DeepLinkService extends ChangeNotifier with WidgetsBindingObserver {
  static const _channel = MethodChannel('app.lovio/deep_link');
  static final DeepLinkService instance = DeepLinkService._internal();

  DeepLinkService._internal();

  bool _isInitialized = false;
  String? _pendingToken;

  /// Unconsumed pending token waiting for GoRouter navigation
  String? get pendingToken => _pendingToken;

  /// Retrieves and clears the pending deep link token atomically
  String? consumePendingToken() {
    final token = _pendingToken;
    _pendingToken = null;
    return token;
  }

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);

    // 1. Listen for warm-start deep links while app is running
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final link = call.arguments as String?;
        if (link != null && link.isNotEmpty) {
          debugPrint('Warm-start deep link received: $link');
          handleDeepLink(link);
        }
      }
    });

    // 2. Query initial cold-start deep link
    _checkInitialDeepLink();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed: checking for pending background deep links');
      _checkPendingWarmDeepLink();
    }
  }

  Future<void> _checkPendingWarmDeepLink() async {
    try {
      final pendingLink =
          await _channel.invokeMethod<String>('getPendingDeepLink');
      if (pendingLink != null && pendingLink.isNotEmpty) {
        debugPrint('Found pending warm-start deep link on resume: $pendingLink');
        handleDeepLink(pendingLink);
      }
    } catch (e) {
      debugPrint('Error checking pending deep link on resume: $e');
    }
  }

  /// Dismiss all active bottom sheets, modal dialogs, drawers, and popups
  /// Ensures incoming card deep links are never blocked by previously opened sheets
  void dismissAllModals() {
    try {
      final nav = rootNavigatorKey.currentState;
      if (nav != null) {
        // Pop until only non-popup page routes remain
        nav.popUntil((route) => route is! PopupRoute);
      }
    } catch (e) {
      debugPrint('Error dismissing modal overlays on deep link: $e');
    }
  }

  Future<void> _checkInitialDeepLink() async {
    try {
      final initialLink =
          await _channel.invokeMethod<String>('getInitialDeepLink');
      if (initialLink != null && initialLink.isNotEmpty) {
        debugPrint('Cold-start deep link captured: $initialLink');
        final token = extractToken(initialLink);
        if (token != null && token.isNotEmpty) {
          _pendingToken = token;
          notifyListeners();

          // Also attempt direct navigation once the widget tree is ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tryDirectNavigate(token);
          });
        }
      }
    } catch (e) {
      debugPrint('Error querying initial deep link: $e');
    }
  }

  /// Parse token from any incoming URL format
  String? extractToken(String rawUrl) {
    if (rawUrl.isEmpty) return null;

    final trimmed = rawUrl.trim();

    // 1. Check custom scheme: lovio://p/<token>, lovio://card/<token>, lovio://page/<token>, lovio://<token>
    if (trimmed.startsWith('lovio://')) {
      final withoutScheme = trimmed.substring('lovio://'.length);
      final parts =
          withoutScheme.split('/').where((s) => s.isNotEmpty).toList();
      if (parts.length >= 2 &&
          (parts[0] == 'p' || parts[0] == 'card' || parts[0] == 'page')) {
        return parts[1];
      } else if (parts.isNotEmpty &&
          parts[0] != 'home' &&
          parts[0] != 'sign-in' &&
          parts[0] != 'sign-up') {
        return parts[0];
      }
    }

    // 2. Parse standard web URL e.g. https://lovio-e5990.web.app/p/<token>
    try {
      final uri = Uri.parse(trimmed);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length >= 2 &&
          (segments[0] == 'p' ||
              segments[0] == 'card' ||
              segments[0] == 'page')) {
        return segments[1];
      }

      // Check query params ?token= or ?p= or ?card=
      final paramToken = uri.queryParameters['token'] ??
          uri.queryParameters['p'] ??
          uri.queryParameters['card'] ??
          uri.queryParameters['id'];
      if (paramToken != null && paramToken.isNotEmpty) {
        return paramToken;
      }

      // If host is explicitly a Lovio domain and segment is a token code
      final host = uri.host.toLowerCase();
      if ((host.contains('lovio') || host.contains('web.app')) &&
          segments.length == 1 &&
          RegExp(r'^[a-zA-Z0-9_-]{6,32}$').hasMatch(segments[0])) {
        return segments[0];
      }
    } catch (e) {
      debugPrint('Error parsing URL $trimmed: $e');
    }

    // 3. Regex Fallback for any /p/<token> or /card/<token> or /page/<token>
    final regex = RegExp(r'(?:p|card|page)/([a-zA-Z0-9_-]+)');
    final match = regex.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  /// Navigate directly to the Shared Card Viewer
  void handleDeepLink(String rawUrl) {
    final token = extractToken(rawUrl);
    if (token == null || token.isEmpty) {
      debugPrint('Could not extract token from deep link: $rawUrl');
      return;
    }

    debugPrint('Setting pending deep link token: $token');
    _pendingToken = token;
    notifyListeners();

    _tryDirectNavigate(token);
  }

  void _tryDirectNavigate(String token) {
    // 1. Immediately dismiss any active bottom sheets, modal dialogs, or popups
    dismissAllModals();

    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      try {
        debugPrint('Directly navigating GoRouter to: /p/$token');
        GoRouter.of(context).go('/p/$token');
        _pendingToken = null;
      } catch (e) {
        debugPrint('GoRouter direct navigation error: $e');
      }
    }

    // 2. Post-frame cleanup: ensure any active popping animations settle and target page is open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dismissAllModals();
      final delayedContext = rootNavigatorKey.currentContext;
      if (delayedContext != null) {
        try {
          debugPrint('PostFrame navigating GoRouter to: /p/$token');
          GoRouter.of(delayedContext).go('/p/$token');
          _pendingToken = null;
        } catch (e) {
          debugPrint('PostFrame GoRouter direct navigation error: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
