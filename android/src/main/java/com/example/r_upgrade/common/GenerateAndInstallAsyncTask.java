package com.example.r_upgrade.common;

import android.app.DownloadManager;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;

import com.example.r_upgrade.RUpgradeFileProvider;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

import static android.content.Context.DOWNLOAD_SERVICE;

class GenerateAndInstallAsyncTask extends AsyncTask<Integer, Integer, Uri> {
    private static final String TAG = "r_upgrade.AsyncTask";
    final WeakReference<Context> contextWrapper;
    boolean isUserDownloadManager;
    MethodChannel.Result result;

    GenerateAndInstallAsyncTask(Context context, boolean isUserDownloadManager, MethodChannel.Result result) {
        this.contextWrapper = new WeakReference<Context>(context);
        this.isUserDownloadManager = isUserDownloadManager;
        this.result = result;
    }

    @Override
    protected Uri doInBackground(Integer... integers) {
        Uri uri = null;
        try {
            int id = integers[0];
            if (this.isUserDownloadManager) {
                DownloadManager manager = (DownloadManager) contextWrapper.get().getSystemService(DOWNLOAD_SERVICE);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    uri = manager.getUriForDownloadedFile(id);
                } else {
                    DownloadManager.Query query = new DownloadManager.Query();
                    Cursor cursor = manager.query(query.setFilterById(id));
                    cursor.moveToNext();
                    String address = cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI));
                    uri = Uri.parse(address);
                    cursor.close();
                }
            } else {
                Map<String, Object> map = UpgradeSQLite.getInstance(contextWrapper.get()).queryById(id);
                if (map == null) return null;
                int upgradeFlavor = (int) map.get(UpgradeSQLite.UPGRADE_FLAVOR);
                String path = (String) map.get(UpgradeSQLite.PATH);
                File file = new File(path);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    uri = RUpgradeFileProvider.getUriForFile(contextWrapper.get(), contextWrapper.get().getApplicationInfo().packageName + ".fileProvider", file);
                } else {
                    uri = Uri.fromFile(file);
                }
                if (upgradeFlavor == UpgradeSQLite.UPGRADE_FLAVOR_INCREMENT) {
                    String newPath = new IncrementUpgradeManager(contextWrapper.get()).mixinAndGetNewApk(path);
                    RUpgradeLogger.get().d(TAG,"合成成功，新的安装包路径："+newPath);
                    if (newPath == null) return null;
                    file = new File(newPath);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        uri = RUpgradeFileProvider.getUriForFile(contextWrapper.get(), contextWrapper.get().getApplicationInfo().packageName + ".fileProvider", file);
                    } else {
                        uri = Uri.fromFile(file);
                    }
                } else if (upgradeFlavor == UpgradeSQLite.UPGRADE_FLAVOR_HOT_UPDATE) {
                    boolean isSuccess = new HotUpgradeManager(contextWrapper.get()).hotUpgrade(uri);
                    if (isSuccess) {
                        return Uri.parse("");
                    } else {
                        return null;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return uri;
    }

    @Override
    protected void onPostExecute(Uri uri) {
        super.onPostExecute(uri);
        try {
            if (uri != null) {
                if (uri.toString().isEmpty()) {
                    //热更新实现
                    postResult(true);
                } else {
                    postResult(installApk(uri));
                }
            } else {
                postResult(false);
            }
        } catch (Exception e) {
            e.printStackTrace();
            postResult(false);

        }
    }

    private void postResult(boolean isSuccess) {
        if (result != null) {
            result.success(isSuccess);
        }
    }

    //安装apk
    private boolean installApk(Uri uri) {
        Intent install = new Intent(Intent.ACTION_VIEW);
        if (uri != null) {
            RUpgradeLogger.get().d(TAG, uri.toString());
            install.setDataAndType(uri, "application/vnd.android.package-archive");
            install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            } else {
                install.addCategory(Intent.CATEGORY_DEFAULT);
            }
            contextWrapper.get().startActivity(install);
            return true;
        } else {
            return false;
        }
    }
}
