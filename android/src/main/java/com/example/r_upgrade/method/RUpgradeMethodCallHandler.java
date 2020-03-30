package com.example.r_upgrade.method;

import androidx.annotation.NonNull;

import com.example.r_upgrade.common.HotUpgradeManager;
import com.example.r_upgrade.common.UpgradeManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class RUpgradeMethodCallHandler implements MethodChannel.MethodCallHandler {
    private UpgradeManager upgradeManager;
    private HotUpgradeManager hotUpgradeManager;

    public RUpgradeMethodCallHandler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager) {
        this.upgradeManager = upgradeManager;
        this.hotUpgradeManager = hotUpgradeManager;
    }

    @Override
    public void onMethodCall(MethodCall call, @NonNull MethodChannel.Result result) {
        RUpgradeMethodEnum methodEnum = RUpgradeMethodEnum.valueOf(call.method);
        methodEnum.handler(upgradeManager,hotUpgradeManager,call, result);
    }
}
