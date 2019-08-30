package com.example.r_upgrade;

import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;

import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * RUpgradePlugin
 */
public class RUpgradePlugin implements MethodCallHandler,EventChannel.StreamHandler {
    private static UpgradeManager manager;
    private BroadcastReceiver downloadReceiver;
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "r_upgrade");
        manager = new UpgradeManager(registrar.context());
        channel.setMethodCallHandler(new RUpgradePlugin());
        final EventChannel eventChannel=new EventChannel(registrar.messenger(),"r_upgrade/e");
        eventChannel.setStreamHandler(new RUpgradePlugin());
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("upgrade")) {
            result.success(manager.upgrade((String) call.argument("url"),
                    (Map<String, String>) call.argument("header"),
                    (String) call.argument("apkName"), (Integer) call.argument("notificationVisibility")));
        } else if (call.method.equals("cancel")) {
            result.success(manager.cancel((Integer) call.argument("id")));
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        int id= (int) o;
        IntentFilter filter=new IntentFilter();
        filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
        filter.addAction(UpgradeManager.DOWNLOAD_STATUS);
        downloadReceiver=manager.createBroadcastReceiver(eventSink);
        manager.registerReceiver(downloadReceiver,filter);
    }

    @Override
    public void onCancel(Object o) {
        manager.unregisterReceiver(downloadReceiver);
    }
}
