package com.example.r_upgrade;

import android.content.Intent;

import androidx.annotation.NonNull;

import com.example.r_upgrade.common.DownloadPermissions;
import com.example.r_upgrade.common.manager.UpgradeManager;
import com.example.r_upgrade.common.UpgradeService;
import com.example.r_upgrade.method.RUpgradeMethodCallHandler;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;

/**
 * RUpgradePlugin
 */
public class RUpgradePlugin implements FlutterPlugin, ActivityAware {
    private static final String PLUGIN_METHOD_NAME = "com.rhyme/r_upgrade_method";

    private MethodChannel _channel;
    private UpgradeManager upgradeManager;
    private FlutterPluginBinding flutterPluginBinding;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.flutterPluginBinding = binding;
        _channel = new MethodChannel(binding.getBinaryMessenger(), PLUGIN_METHOD_NAME);
        upgradeManager = new UpgradeManager(
            binding.getApplicationContext(), _channel, new DownloadPermissions()
        );
        _channel.setMethodCallHandler(new RUpgradeMethodCallHandler(upgradeManager));
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        onDetachedFromActivity();
        flutterPluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull final ActivityPluginBinding binding) {
        if (upgradeManager != null) {
            upgradeManager.setActivity(binding.getActivity());
            upgradeManager.setPermissionsRegistry(binding::addRequestPermissionsResultListener);
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        onAttachedToActivity(binding);
    }

    @Override
    public void onDetachedFromActivity() {
        Intent intent = new Intent(flutterPluginBinding.getApplicationContext(), UpgradeService.class);
        flutterPluginBinding.getApplicationContext().stopService(intent);
        if (upgradeManager != null) {
            upgradeManager.dispose();
            upgradeManager = null;
        }
        if (_channel != null) {
            _channel.setMethodCallHandler(null);
            _channel = null;
        }
    }
}
