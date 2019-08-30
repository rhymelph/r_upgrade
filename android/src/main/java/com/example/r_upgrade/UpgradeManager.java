package com.example.r_upgrade;

import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.util.Log;

import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.plugin.common.EventChannel;

public class UpgradeManager extends ContextWrapper {
    private static final String TAG = "UpgradeManager";
    public static final String DOWNLOAD_STATUS = "com.example.r_upgrade.DOWNLOAD_STATUS";
    private long id;

    private Timer timer;

    public UpgradeManager(Context base) {
        super(base);
    }

    public long upgrade(String url, Map<String, String> header, String apkName, Integer notificationVisibility) {
        DownloadManager manager = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
        DownloadManager.Request request = new DownloadManager.Request(Uri.parse(url));
        if (header != null) {
            for (Map.Entry<String, String> entry : header.entrySet()) {
                request.addRequestHeader(entry.getKey(), entry.getValue());
            }
        }
        if (notificationVisibility != null) {
            request.setNotificationVisibility(notificationVisibility);
        } else {
            request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
        }
        request.setMimeType("application/vnd.android.package-archive");

        request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, apkName == null ? "upgradePackage.apk" : apkName);

        request.setTitle(apkName == null ? "upgradePackage.apk" : apkName);
        id = manager.enqueue(request);
        if (timer != null) {
            timer.cancel();
        }
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                queryTask(id);
            }
        }, 500);
        Log.d(TAG, "upgrade: " + id);
        return id;
    }

    //取消下载
    public boolean cancel(Integer id) {
        if (id == null) return false;
        DownloadManager manager = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
        return manager.remove(id) == 1;
    }

    //查询进度
    public void queryTask(long id) {
        DownloadManager manager = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
        DownloadManager.Query query = new DownloadManager.Query();
        Cursor cursor = manager.query(query.setFilterById(id));
        if (cursor != null && cursor.moveToFirst()) {
            //下载的文件到本地的目录
            String address = cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI));
            //已经下载的字节数
            int bytes_downloaded = cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR));
            //总需下载的字节数
            int bytes_total = cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES));
//            //Notification 标题
//            String title =cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_TITLE));
//            //描述
//            String description =cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_DESCRIPTION));
//            //下载对应id
            long ids = cursor.getLong(cursor.getColumnIndex(DownloadManager.COLUMN_ID));
//            //下载文件名称
//            String filename = cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_LOCAL_FILENAME));
//            //下载文件的URL链接
//            String url =cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_URI));
            Intent intent = new Intent();
            intent.setAction(DOWNLOAD_STATUS);
            intent.putExtra("bytes_downloaded", bytes_downloaded);
            intent.putExtra("bytes_total", bytes_total);
            intent.putExtra("address", address);
            intent.putExtra("id", ids);
            sendBroadcast(intent);
        }
    }

    //安装apk
    public boolean installApk(long id) {
        DownloadManager manager = (DownloadManager) getSystemService(Context.DOWNLOAD_SERVICE);
        Intent install = new Intent(Intent.ACTION_VIEW);
        Uri downloadFileUri = manager.getUriForDownloadedFile(id);
        if (downloadFileUri != null) {
            Log.d(TAG, downloadFileUri.toString());
            install.setDataAndType(downloadFileUri, "application/vnd.android.package-archive");
            install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(install);
            return true;
        } else {
            return false;
        }
    }

    public BroadcastReceiver createBroadcastReceiver(EventChannel.EventSink eventSink) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (intent != null && intent.getAction() != null && intent.getAction().equals(DownloadManager.ACTION_DOWNLOAD_COMPLETE)) {
                    timer.cancel();
                    timer = null;
                    installApk(id);
                } else if (intent != null && intent.getAction() != null && intent.getAction().equals(UpgradeManager.DOWNLOAD_STATUS)) {
                    int bytes_downloaded = intent.getIntExtra("bytes_downloaded", 0);
                    int bytes_total = intent.getIntExtra("bytes_total", 0);
                    String address = intent.getStringExtra("address");
                    long ids = intent.getLongExtra("id", 0);
                    Log.d(TAG, "onReceive: bytes_downloaded: bytes_downloaded：" + bytes_downloaded +
                            "\n bytes_total: " + bytes_total +
                            "\n address" + address);
                }
            }
        };
    }
}
