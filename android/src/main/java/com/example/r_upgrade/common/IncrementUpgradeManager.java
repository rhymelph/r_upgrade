package com.example.r_upgrade.common;

import android.content.Context;
import android.content.ContextWrapper;
import android.os.Environment;
import android.util.Log;


import com.example.r_upgrade_lib.RUpgradeLib;

import java.io.File;

public class IncrementUpgradeManager extends ContextWrapper {
    private static final String TAG = "r_upgrade.Increment";
    private String oldApkPath;
    private RUpgradeLib rUpgradeLib;

    public IncrementUpgradeManager(Context base) {
        super(base);
        oldApkPath = base.getPackageResourcePath();
        rUpgradeLib = new RUpgradeLib();
    }

    public String mixinAndGetNewApk(String patchPath) {
        File parentFile = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
        File newApkFile = new File(parentFile, oldApkPath.substring(oldApkPath.lastIndexOf("/") + 1));
        try {
            if (newApkFile.exists()) {
                newApkFile.delete();
            }
            newApkFile.createNewFile();
            rUpgradeLib.mixinPatch(oldApkPath, patchPath, newApkFile.getPath());
            RUpgradeLogger.get().d(TAG, String.format("mixinAndGetNewApk: %s",newApkFile.getPath()));
            return newApkFile.getPath();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

}
