package com.example.lovio

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val SHARE_CHANNEL = "app.lovio/native_share"
    private val DEEP_LINK_CHANNEL = "app.lovio/deep_link"

    private var deepLinkChannel: MethodChannel? = null
    private var initialDeepLink: String? = null
    private var pendingDeepLink: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Capture cold-start intent link if available
        if (initialDeepLink == null) {
            initialDeepLink = intent?.dataString
        }

        // 2. Setup Deep Link Channel
        deepLinkChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEEP_LINK_CHANNEL)
        deepLinkChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialDeepLink" -> {
                    val link = initialDeepLink ?: pendingDeepLink
                    // Clear after consumption so it doesn't trigger repeatedly on re-configuration
                    initialDeepLink = null
                    pendingDeepLink = null
                    result.success(link)
                }
                "getPendingDeepLink" -> {
                    val link = pendingDeepLink
                    pendingDeepLink = null
                    result.success(link)
                }
                else -> result.notImplemented()
            }
        }

        // 3. Setup Native Share Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHARE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareText" -> {
                    val text = call.argument<String>("text") ?: ""
                    val title = call.argument<String>("title") ?: "Share via"
                    val shareIntent = Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, text)
                    }
                    val chooser = Intent.createChooser(shareIntent, title)
                    startActivity(chooser)
                    result.success(true)
                }
                "shareWhatsApp" -> {
                    val text = call.argument<String>("text") ?: ""
                    try {
                        val waIntent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            `package` = "com.whatsapp"
                            putExtra(Intent.EXTRA_TEXT, text)
                        }
                        startActivity(waIntent)
                        result.success(true)
                    } catch (e: Exception) {
                        val fallbackIntent = Intent(Intent.ACTION_SEND).apply {
                            type = "text/plain"
                            putExtra(Intent.EXTRA_TEXT, text)
                        }
                        startActivity(Intent.createChooser(fallbackIntent, "Share Card"))
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Forward any pending deep link that arrived before the channel was ready
        pendingDeepLink?.let { link ->
            deepLinkChannel?.invokeMethod("onDeepLink", link)
        }
    }

    // 4. Capture warm-start deep links when app is already open / running
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val link = intent.dataString
        if (!link.isNullOrEmpty()) {
            pendingDeepLink = link
            // Forward immediately to Flutter via channel
            deepLinkChannel?.invokeMethod("onDeepLink", link)
        }
    }

    override fun onResume() {
        super.onResume()
        // If an intent arrived while transitioning, ensure it is forwarded
        val link = intent?.dataString
        if (!link.isNullOrEmpty() && link != initialDeepLink) {
            pendingDeepLink = link
            deepLinkChannel?.invokeMethod("onDeepLink", link)
        }
    }
}
