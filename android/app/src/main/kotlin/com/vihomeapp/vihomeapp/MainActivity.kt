package com.vihomeapp.vihomeapp

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Dibuja detrás de las barras del sistema también en Android < 15.
        // Equivalente a enableEdgeToEdge() de androidx.activity, que no aplica
        // aquí porque FlutterActivity extiende Activity y no ComponentActivity.
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
    }
}
