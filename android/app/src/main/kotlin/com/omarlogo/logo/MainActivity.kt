package com.omarlogo.logo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.ComponentName
import android.content.pm.PackageManager
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.dynamic_logo_app/icon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateAppIcon") {
                val iconName = call.argument<String>("iconName")
                if (iconName != null) {
                    updateAppIcon(iconName)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Icon name is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun updateAppIcon(iconName: String) {
        Log.d("IconUpdate", "Updating icon to: $iconName")
        val pm = packageManager
        val defaultComponent = ComponentName(this, "${packageName}.MainActivity")
        val christmasComponent = ComponentName(this, "${packageName}.MainActivity.ChristmasIcon")
        val summerComponent = ComponentName(this, "${packageName}.MainActivity.SummerIcon")

        // Disable all icons
        pm.setComponentEnabledSetting(defaultComponent, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        pm.setComponentEnabledSetting(christmasComponent, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)
        pm.setComponentEnabledSetting(summerComponent, PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP)

        // Enable the selected icon
        val selectedComponent = when (iconName) {
            "christmas" -> christmasComponent
            "summer" -> summerComponent
            else -> defaultComponent
        }
        pm.setComponentEnabledSetting(selectedComponent, PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP)
        Log.d("IconUpdate", "Icon update completed")
    }
}