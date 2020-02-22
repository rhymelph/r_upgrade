package com.example.r_upgrade;

import androidx.annotation.NonNull;

import com.example.r_upgrade.common.HotUpgradeManager;
import com.example.r_upgrade.common.UpgradeManager;
import com.example.r_upgrade.event.RUpgradeEventStreamHandler;
import com.example.r_upgrade.method.RUpgradeMethodCallHandler;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RUpgradePlugin
 */
public class RUpgradePlugin implements FlutterPlugin {
    private static final String PLUGIN_METHOD_NAME = "com.rhyme/r_upgrade_method";
    private static final String PLUGIN_EVENT_NAME = "com.rhyme/r_upgrade_event";

    private MethodChannel _channel;
    private EventChannel _eventChannel;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        UpgradeManager.init(registrar.context());
        HotUpgradeManager.init(registrar.context());

        final MethodChannel channel = new MethodChannel(registrar.messenger(), PLUGIN_METHOD_NAME);
        channel.setMethodCallHandler(new RUpgradeMethodCallHandler());

        final EventChannel eventChannel = new EventChannel(registrar.messenger(), PLUGIN_EVENT_NAME);
        eventChannel.setStreamHandler(new RUpgradeEventStreamHandler());
    }


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        UpgradeManager.init(binding.getApplicationContext());
        HotUpgradeManager.init(binding.getApplicationContext());

        _channel = new MethodChannel(binding.getBinaryMessenger(), PLUGIN_METHOD_NAME);
        _channel.setMethodCallHandler(new RUpgradeMethodCallHandler());

        _eventChannel = new EventChannel(binding.getBinaryMessenger(), PLUGIN_EVENT_NAME);
        _eventChannel.setStreamHandler(new RUpgradeEventStreamHandler());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        UpgradeManager.dispose();
        HotUpgradeManager.dispose();
        _channel.setMethodCallHandler(null);
        _channel = null;
        _eventChannel.setStreamHandler(null);
        _eventChannel = null;
    }


}
