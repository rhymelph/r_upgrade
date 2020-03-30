package com.example.r_upgrade.method;

import com.example.r_upgrade.common.HotUpgradeManager;
import com.example.r_upgrade.common.UpgradeManager;

import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;


public enum RUpgradeMethodEnum implements IRUpgradeMethodHandler {
    upgrade {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.upgrade((String) call.argument("url"),
                    (Map<String, String>) call.argument("header"),
                    (String) call.argument("apkName"),
                    (Integer) call.argument("notificationVisibility"),
                    (Boolean) call.argument("isAutoRequestInstall"),
                    (Boolean) call.argument("useDownloadManager")));
        }
    },
    cancel {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.cancel((Integer) call.argument("id")));

        }
    },
    install {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.installApkById((Integer) call.argument("id")));

        }
    },

    hotUpgrade {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(hotUpgradeManager.hotUpgrade((int) call.argument("id")));

        }
    },
    pause {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.pause((Integer) call.argument("id")));
        }
    },
    upgradeWithId {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.upgradeWithId((Integer) call.argument("id"), (Integer) call.argument("notificationVisibility"),
                    (Boolean) call.argument("isAutoRequestInstall")));
        }
    },
    getDownloadStatus {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.getDownloadStatus((Integer) call.argument("id")));

        }
    },
    getLastUpgradedId {
        @Override
        public void handler(UpgradeManager upgradeManager, HotUpgradeManager hotUpgradeManager, MethodCall call, MethodChannel.Result result) {
            result.success(upgradeManager.getLastUpgradedId());
        }
    },


}
