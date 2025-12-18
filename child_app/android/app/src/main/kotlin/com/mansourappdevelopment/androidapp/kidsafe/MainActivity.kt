package com.mansourappdevelopment.androidapp.kidsafe

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import com.mansourappdevelopment.androidapp.kidsafe.services.MainForegroundService

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        startService()
    }

    private fun startService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(Intent(this, MainForegroundService::class.java))
        } else {
            startService(Intent(this, MainForegroundService::class.java))
        }
    }
}
