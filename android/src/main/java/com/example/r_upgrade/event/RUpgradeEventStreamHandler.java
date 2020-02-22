package com.example.r_upgrade.event;

import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;

import com.example.r_upgrade.common.UpgradeManager;

import io.flutter.plugin.common.EventChannel;

public class RUpgradeEventStreamHandler implements EventChannel.StreamHandler {
    private BroadcastReceiver downloadReceiver;

    @Override
    public void onListen(Object arguments, EventChannel.EventSink eventSink) {
        IntentFilter filter = new IntentFilter();
        filter.addAction(DownloadManager.ACTION_DOWNLOAD_COMPLETE);
        filter.addAction(UpgradeManager.DOWNLOAD_STATUS);
        downloadReceiver = UpgradeManager.upgradeManager.createBroadcastReceiver(eventSink);
        UpgradeManager.upgradeManager.registerReceiver(downloadReceiver, filter);
    }

    @Override
    public void onCancel(Object arguments) {
        UpgradeManager.upgradeManager.unregisterReceiver(downloadReceiver);

    }
}
