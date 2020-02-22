package com.example.r_upgrade.method;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class RUpgradeMethodCallHandler implements MethodChannel.MethodCallHandler {

    @Override
    public void onMethodCall(MethodCall call,@NonNull MethodChannel.Result result) {
        RUpgradeMethodEnum methodEnum = RUpgradeMethodEnum.valueOf(call.method);
        methodEnum.handler(call, result);
    }
}
