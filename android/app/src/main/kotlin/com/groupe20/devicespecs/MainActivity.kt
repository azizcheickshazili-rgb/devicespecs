package com.groupe20.devicespecs

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.StatFs
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Doit être identique au nom du channel utilisé côté Dart (main.dart)
    private val CHANNEL = "com.groupe20.devicespecs/system"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceInfo") {
                try {
                    result.success(getDeviceInfo())
                } catch (e: Exception) {
                    result.error("NATIVE_ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * Récupère les infos système via les API Android natives.
     * Chaque valeur mémoire/stockage est renvoyée en Mo (MB).
     */
    private fun getDeviceInfo(): Map<String, Any> {
        val info = HashMap<String, Any>()

        // --- Infos appareil ---
        info["brand"] = Build.BRAND
        info["model"] = Build.MODEL
        info["manufacturer"] = Build.MANUFACTURER
        info["androidVersion"] = Build.VERSION.RELEASE
        info["sdkInt"] = Build.VERSION.SDK_INT

        // --- RAM ---
        val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        actManager.getMemoryInfo(memInfo)
        info["totalRam"] = memInfo.totalMem / (1024 * 1024)
        info["availableRam"] = memInfo.availMem / (1024 * 1024)

        // --- Stockage interne ---
        val stat = StatFs(applicationContext.filesDir.path)
        val totalBytes = stat.blockCountLong * stat.blockSizeLong
        val availableBytes = stat.availableBlocksLong * stat.blockSizeLong
        info["totalStorage"] = totalBytes / (1024 * 1024)
        info["availableStorage"] = availableBytes / (1024 * 1024)

        // --- Batterie ---
        val batteryStatus = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val batteryPct = if (level >= 0 && scale > 0) (level * 100 / scale) else -1
        info["batteryLevel"] = batteryPct

        return info
    }
}
