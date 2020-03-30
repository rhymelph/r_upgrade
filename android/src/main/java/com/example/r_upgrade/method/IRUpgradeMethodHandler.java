package com.example.r_upgrade.method;


import com.example.r_upgrade.common.HotUpgradeManager;
import com.example.r_upgrade.common.UpgradeManager;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public interface IRUpgradeMethodHandler {

    void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result);

}
