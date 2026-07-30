package com.example.news_app_frontend

import android.content.Context
import com.ryanheise.audioservice.AudioServicePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        // This connects your UI to the background audio engine!
        return AudioServicePlugin.getFlutterEngine(context)
    }
}