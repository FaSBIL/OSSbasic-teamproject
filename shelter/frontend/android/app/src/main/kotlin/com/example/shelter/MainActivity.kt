package com.example.shelter

import io.flutter.embedding.android.FlutterActivity
import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "device_audio_status"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "getRingerMode") {
                val audioManager = getSystemService(AUDIO_SERVICE) as AudioManager
                val mode = when (audioManager.ringerMode) {
                    AudioManager.RINGER_MODE_NORMAL -> "normal"
                    AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
                    AudioManager.RINGER_MODE_SILENT -> "silent"
                    else -> "unknown"
                }
                result.success(mode)
            } else {
                result.notImplemented()
            }
        }
    }
}