package com.example.r_upgrade;

import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;

import com.example.r_upgrade.common.HotUpgradeManager;
import com.example.r_upgrade.common.UpgradeManager;
import com.example.r_upgrade.common.UpgradeService;
import com.example.r_upgrade.method.RUpgradeMethodCallHandler;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RUpgradePlugin
 */
public class RUpgradePlugin implements FlutterPlugin {
    private static final String PLUGIN_METHOD_NAME = "com.rhyme/r_upgrade_method";

    private MethodChannel _channel;
    private UpgradeManager upgradeManager;
    private HotUpgradeManager hotUpgradeManager;

    public RUpgradePlugin() {

    }

    private RUpgradePlugin(Context context, BinaryMessenger messenger) {
        _channel = new MethodChannel(messenger, PLUGIN_METHOD_NAME);
        hotUpgradeManager = new HotUpgradeManager(context);
        upgradeManager = new UpgradeManager(context, _channel);
        _channel.setMethodCallHandler(new RUpgradeMethodCallHandler(upgradeManager, hotUpgradeManager));
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        new RUpgradePlugin(registrar.context(), registrar.messenger());
    }


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        new RUpgradePlugin(binding.getApplicationContext(), binding.getBinaryMessenger());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Intent intent = new Intent(binding.getApplicationContext(), UpgradeService.class);
        binding.getApplicationContext().stopService(intent);
        if (upgradeManager != null) {
            upgradeManager.dispose();
        }
        if (hotUpgradeManager != null) {
            hotUpgradeManager.dispose();
        }
        if (_channel != null) {
            _channel.setMethodCallHandler(null);
            _channel = null;
        }
    }


}
