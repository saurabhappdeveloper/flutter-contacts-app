package com.itl.flutter_contacts_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "com.itl.flutter_contacts_app/phone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                if (call.method == "directCall") {
                    val number = call.argument<String>("number") ?: ""
                    try {
                        val intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$number"))
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("CALL_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
