package com.example.r_upgrade.method;


import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public interface IRUpgradeMethodHandler {

    void handler(MethodCall call, MethodChannel.Result result);

}
