package com.example.r_upgrade.method;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import static com.example.r_upgrade.common.HotUpgradeManager.hotManager;
import static com.example.r_upgrade.common.UpgradeManager.upgradeManager;

public enum RUpgradeMethodEnum implements IRUpgradeMethodHandler {
    upgrade {
        @Override
        public void handler(MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.upgrade((String) call.argument("url"),
                    (Map<String, String>) call.argument("header"),
                    (String) call.argument("apkName"),
                    (Integer) call.argument("notificationVisibility"),
                    (Boolean) call.argument("isAutoRequestInstall")));
        }
    },
    cancel {
        @Override
        public void handler(MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.cancel((Integer) call.argument("id")));

        }
    },
    install {
        @Override
        public void handler(MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.installApkById((int) call.argument("id")));

        }
    },

    hotUpgrade {
        @Override
        public void handler(MethodCall call, MethodChannel.Result result) {
            result.success(hotManager.hotUpgrade((int)call.argument("id")));

        }
    }

}
