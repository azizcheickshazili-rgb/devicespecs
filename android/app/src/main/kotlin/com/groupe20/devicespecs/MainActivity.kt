package com.groupe20.devicespecs

import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.Sensor
import android.hardware.SensorManager
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.os.StatFs
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.net.InetSocketAddress
import java.net.Socket

class MainActivity : FlutterActivity() {

    // Doit être identique au nom du channel utilisé côté Dart (main.dart)
    private val CHANNEL = "com.groupe20.devicespecs/system"

    // Pour le calcul de la charge CPU (delta entre deux lectures de /proc/stat)
    private var lastCpuTotal: Long = -1
    private var lastCpuIdle: Long = -1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    try {
                        result.success(getDeviceInfo())
                    } catch (e: Exception) {
                        result.error("NATIVE_ERROR", e.message, null)
                    }
                }
                "getCpuLoad" -> {
                    try {
                        result.success(readCpuLoadPercent())
                    } catch (e: Exception) {
                        result.error("NATIVE_ERROR", e.message, null)
                    }
                }
                "getSensorsList" -> {
                    try {
                        result.success(getSensorsList())
                    } catch (e: Exception) {
                        result.error("NATIVE_ERROR", e.message, null)
                    }
                }
                "getNetworkInfo" -> {
                    // Ouvre un socket TCP (mesure de latence) : on l'exécute
                    // hors du thread principal pour éviter tout risque d'ANR.
                    Thread {
                        try {
                            val info = getNetworkInfo()
                            runOnUiThread { result.success(info) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("NATIVE_ERROR", e.message, null) }
                        }
                    }.start()
                }
                else -> result.notImplemented()
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
        info["deviceCodeName"] = Build.DEVICE
        info["buildId"] = Build.DISPLAY

        // --- RAM ---
        val actManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val memInfo = ActivityManager.MemoryInfo()
        actManager.getMemoryInfo(memInfo)
        info["totalRam"] = memInfo.totalMem / (1024 * 1024)
        info["availableRam"] = memInfo.availMem / (1024 * 1024)
        info["usedRam"] = (memInfo.totalMem - memInfo.availMem) / (1024 * 1024)

        val (swapTotalKb, swapFreeKb) = readSwapInfoKb()
        if (swapTotalKb >= 0 && swapFreeKb >= 0) {
            info["swapTotal"] = swapTotalKb / 1024
            info["swapUsed"] = (swapTotalKb - swapFreeKb) / 1024
        } else {
            info["swapTotal"] = -1
            info["swapUsed"] = -1
        }

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
        info["batteryPercent"] = batteryPct

        val status = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val plugged = batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
        info["isCharging"] = status == BatteryManager.BATTERY_STATUS_CHARGING ||
            status == BatteryManager.BATTERY_STATUS_FULL
        info["chargeState"] = when {
            status == BatteryManager.BATTERY_STATUS_FULL -> "Chargée"
            plugged == BatteryManager.BATTERY_PLUGGED_USB -> "Charge USB"
            plugged == BatteryManager.BATTERY_PLUGGED_AC -> "Charge rapide"
            plugged == BatteryManager.BATTERY_PLUGGED_WIRELESS -> "Charge sans fil"
            else -> "Non branché"
        }
        val health = batteryStatus?.getIntExtra(BatteryManager.EXTRA_HEALTH, -1) ?: -1
        info["cellHealth"] = when (health) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "Normale"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Surchauffe"
            BatteryManager.BATTERY_HEALTH_DEAD -> "Défaillante"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Survoltage"
            BatteryManager.BATTERY_HEALTH_COLD -> "Trop froide"
            else -> "Inconnue"
        }
        val tempTenths = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1) ?: -1
        info["temperatureCelsius"] = if (tempTenths >= 0) tempTenths / 10.0 else -1.0

        // --- CPU ---
        info["cpuCores"] = Runtime.getRuntime().availableProcessors()
        info["cpuArchitecture"] = Build.SUPPORTED_ABIS?.firstOrNull() ?: "Indisponible"
        info["cpuFrequenciesGHz"] = readClusterFrequenciesGHz()

        return info
    }

    /** Liste réelle des capteurs matériels détectés (SensorManager), triée. */
    private fun getSensorsList(): List<String> {
        return try {
            val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
            sensorManager.getSensorList(Sensor.TYPE_ALL)
                .map { it.name }
                .distinct()
                .sorted()
        } catch (e: Exception) {
            emptyList()
        }
    }

    /** Lit /proc/stat et calcule le delta d'activité CPU depuis le dernier appel. */
    private fun readCpuLoadPercent(): Double {
        return try {
            val line = File("/proc/stat").bufferedReader().use { it.readLine() }
            val parts = line.trim().split(Regex("\\s+")).drop(1).map { it.toLong() }
            if (parts.size < 4) return -1.0

            val idle = parts[3] + (parts.getOrNull(4) ?: 0L)
            val total = parts.sum()

            if (lastCpuTotal < 0) {
                lastCpuTotal = total
                lastCpuIdle = idle
                return -1.0 // premier échantillon : pas encore de delta
            }

            val totalDelta = total - lastCpuTotal
            val idleDelta = idle - lastCpuIdle
            lastCpuTotal = total
            lastCpuIdle = idle

            if (totalDelta <= 0) return -1.0
            (1.0 - (idleDelta.toDouble() / totalDelta.toDouble())) * 100.0
        } catch (e: Exception) {
            -1.0
        }.let { if (it < 0) it else it.coerceIn(0.0, 100.0) }
    }

    /**
     * Lit la fréquence courante de chaque cœur via
     * /sys/devices/system/cpu/cpuN/cpufreq/scaling_cur_freq (kHz), regroupe
     * les valeurs distinctes par ordre décroissant (heuristique de cluster
     * big.LITTLE) et renvoie jusqu'à 3 fréquences en GHz. Liste vide si le
     * sysfs n'est pas lisible sur l'appareil.
     */
    private fun readClusterFrequenciesGHz(): List<Double> {
        return try {
            val cpuDir = File("/sys/devices/system/cpu")
            val coreDirs = cpuDir.listFiles { f -> f.name.matches(Regex("cpu\\d+")) }
                ?: return emptyList()

            val freqsKHz = coreDirs.mapNotNull { dir ->
                val freqFile = File(dir, "cpufreq/scaling_cur_freq")
                if (freqFile.canRead()) freqFile.readText().trim().toLongOrNull() else null
            }
            if (freqsKHz.isEmpty()) return emptyList()

            freqsKHz.toSortedSet(compareByDescending { it }).map { it / 1_000_000.0 }.take(3)
        } catch (e: Exception) {
            emptyList()
        }
    }

    /** Lit SwapTotal / SwapFree (en kB dans /proc/meminfo). */
    private fun readSwapInfoKb(): Pair<Long, Long> {
        return try {
            var swapTotalKb = -1L
            var swapFreeKb = -1L
            File("/proc/meminfo").forEachLine { line ->
                when {
                    line.startsWith("SwapTotal:") ->
                        swapTotalKb = line.filter { it.isDigit() }.toLongOrNull() ?: -1L
                    line.startsWith("SwapFree:") ->
                        swapFreeKb = line.filter { it.isDigit() }.toLongOrNull() ?: -1L
                }
            }
            swapTotalKb to swapFreeKb
        } catch (e: Exception) {
            -1L to -1L
        }
    }

    /** Wi-Fi réel (WifiManager) + latence mesurée par un handshake TCP vers la passerelle. */
    private fun getNetworkInfo(): Map<String, Any> {
        return try {
            val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
            val connectionInfo = wifiManager.connectionInfo
            val dhcpInfo = wifiManager.dhcpInfo

            val isConnected = connectionInfo != null && connectionInfo.networkId != -1
            val ssid = (connectionInfo?.ssid ?: "Indisponible").removeSurrounding("\"")
            val linkSpeed = connectionInfo?.linkSpeed ?: -1

            val ipAddress = if (dhcpInfo != null && dhcpInfo.ipAddress != 0) {
                intToIp(dhcpInfo.ipAddress)
            } else "Indisponible"

            val gatewayAddress = if (dhcpInfo != null && dhcpInfo.gateway != 0) {
                intToIp(dhcpInfo.gateway)
            } else null

            val latencyMs = if (isConnected && gatewayAddress != null) {
                measureTcpLatencyMs(gatewayAddress)
            } else -1

            mapOf(
                "ssid" to ssid,
                "isConnected" to isConnected,
                "linkSpeedMbps" to linkSpeed,
                "ipAddress" to ipAddress,
                "latencyMs" to latencyMs
            )
        } catch (e: Exception) {
            mapOf(
                "ssid" to "Indisponible",
                "isConnected" to false,
                "linkSpeedMbps" to -1,
                "ipAddress" to "Indisponible",
                "latencyMs" to -1
            )
        }
    }

    private fun intToIp(ip: Int): String {
        return "${ip and 0xFF}.${ip shr 8 and 0xFF}.${ip shr 16 and 0xFF}.${ip shr 24 and 0xFF}"
    }

    private fun measureTcpLatencyMs(host: String): Int {
        return try {
            val start = System.currentTimeMillis()
            Socket().use { socket -> socket.connect(InetSocketAddress(host, 80), 800) }
            (System.currentTimeMillis() - start).toInt()
        } catch (e: Exception) {
            -1
        }
    }
}
