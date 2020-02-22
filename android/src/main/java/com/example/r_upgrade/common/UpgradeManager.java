package com.example.r_upgrade.common;

import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.ContextWrapper;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.util.Log;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import io.flutter.plugin.common.EventChannel;

public class UpgradeManager extends ContextWrapper {
    private static final String TAG = "UpgradeManager";
    //广播的action
    public static final String DOWNLOAD_STATUS = "com.example.r_upgrade.DOWNLOAD_STATUS";
    //速度
    private double lastProgress = 0;
    //最后更新的时间
    private long lastTime = 0;

    private Timer timer;

    private boolean isAutoRequestInstall;
    public static UpgradeManager upgradeManager;

    public static void init(Context context) {
        upgradeManager = new UpgradeManager(context);
    }
    public static void dispose(){
        upgradeManager = null;
    }

    public UpgradeManager(Context base) {
        super(base);
    }

    public long upgrade(String url, Map<String, String> header, String apkName, Integer notificationVisibility, Boolean isAutoRequestInstall) {
        this.isAutoRequestInstall = Boolean.TRUE == isAutoRequestInstall;

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
        final long id = manager.enqueue(request);
        if (timer != null) {
            timer.cancel();
        }
        timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                queryTask(id);
            }
        }, 0, 500);
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
            int status = cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_STATUS));
            Intent intent = new Intent();
            switch (status) {
                case DownloadManager.STATUS_PAUSED:
//                    Log.d(TAG, "queryTask: 下载被暂停");
                    intent.setAction(DOWNLOAD_STATUS);
                    intent.putExtra("status", DownloadStatus.STATUS_PAUSED.getValue());
                    intent.putExtra("id", id);
                    sendBroadcast(intent);
                    break;
                case DownloadManager.STATUS_PENDING:
//                    Log.d(TAG, "queryTask: 下载延迟==========>总大小:");
                    intent.setAction(DOWNLOAD_STATUS);
                    intent.putExtra("status", DownloadStatus.STATUS_PENDING.getValue());
                    intent.putExtra("id", id);
                    sendBroadcast(intent);
                    break;
                case DownloadManager.STATUS_RUNNING:
                    //已经下载的字节数
                    int progress = cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR));
                    if (lastProgress == 0) {
                        lastProgress = progress;
                        lastTime = System.currentTimeMillis();
                    }
                    //下载的文件到本地的目录
                    String address = cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_LOCAL_URI));
                    //总需下载的字节数
                    int total = cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_TOTAL_SIZE_BYTES));
                    //下载速度
                    double speed = ((progress - lastProgress) * 1000f / (System.currentTimeMillis() - lastTime)) / 1024;
                    //下载文件的URL链接
                    String url = cursor.getString(cursor.getColumnIndex(DownloadManager.COLUMN_URI));

                    //计划完成时间
                    double planTime = (total - progress) / (speed * 1024f);
                    //当前进度
                    double percent = new BigDecimal((progress * 1.0f / total) * 100).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
                    if (progress - lastProgress > 0) {
//                        Log.d(TAG, "queryTask: 下载中\n" +
//                                "url: " +
//                                url +
//                                "\n============>" +
//                                "total:" +
//                                total +
//                                "，" +
//                                "progress:" +
//                                progress +
//                                "，" +
//                                String.format("%.2f", percent) +
//                                "% , " +
//                                String.format("%.2f", speed) +
//                                "kb/s , " +
//                                "预计：" +
//                                String.format("%.0f", planTime) +
//                                "s");
                        intent.setAction(DOWNLOAD_STATUS);
                        intent.putExtra("progress", progress);
                        intent.putExtra("status", DownloadStatus.STATUS_RUNNING.getValue());
                        intent.putExtra("percent", percent);
                        intent.putExtra("total", total);
                        intent.putExtra("speed", speed);
                        intent.putExtra("planTime", planTime);
                        intent.putExtra("address", address);
                        intent.putExtra("id", id);
                        sendBroadcast(intent);
                        lastProgress = progress;
                        lastTime = System.currentTimeMillis();
                    }
                    break;
                case DownloadManager.STATUS_SUCCESSFUL:
//                    Log.d(TAG, "queryTask: 下载成功");
                    if (isAutoRequestInstall) {
                        installApk(manager.getUriForDownloadedFile(id));
                    }
                    intent.setAction(DOWNLOAD_STATUS);
                    intent.putExtra("status", DownloadStatus.STATUS_SUCCESSFUL.getValue());
                    intent.putExtra("id", id);
                    sendBroadcast(intent);
                    lastProgress = 0;
                    break;
                case DownloadManager.STATUS_FAILED:
//                    Log.d(TAG, "queryTask: 下载失败");
                    intent.setAction(DOWNLOAD_STATUS);
                    intent.putExtra("status", DownloadStatus.STATUS_FAILED.getValue());
                    intent.putExtra("id", id);
                    sendBroadcast(intent);
                    lastProgress = 0;
                    break;
            }
        }
        if (cursor != null) {
            cursor.close();
        }
    }

    //安装apk
    public boolean installApk(Uri uri) {
        Intent install = new Intent(Intent.ACTION_VIEW);
        if (uri != null) {
            Log.d(TAG, uri.toString());
            install.setDataAndType(uri, "application/vnd.android.package-archive");
            install.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
            startActivity(install);
            return true;
        } else {
            return false;
        }
    }

    public boolean installApkById(int id) {
        DownloadManager manager = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
        return installApk(manager.getUriForDownloadedFile(id));
    }

    public BroadcastReceiver createBroadcastReceiver(final EventChannel.EventSink eventSink) {
        return new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                if (intent != null && intent.getAction() != null && intent.getAction().equals(DownloadManager.ACTION_DOWNLOAD_COMPLETE)) {
                    timer.cancel();
                    timer = null;
                    long id = intent.getLongExtra("extra_download_id", 0);
                    queryTask(id);
                } else if (intent != null && intent.getAction() != null && intent.getAction().equals(UpgradeManager.DOWNLOAD_STATUS)) {

                    int progress = intent.getIntExtra("progress", 0);
                    int total = intent.getIntExtra("total", 0);
                    double percent = intent.getDoubleExtra("percent", 0);

                    double speed = intent.getDoubleExtra("speed", 0);

                    double planTime = intent.getDoubleExtra("planTime", 0);

                    int status = intent.getIntExtra("status", 1);

                    String address = intent.getStringExtra("address");
                    long id = intent.getLongExtra("id", 0);
                    eventSink.success(ResultMap.getInstance()
                            .pubClear("progress", progress)
                            .put("id", id)
                            .put("percent", percent)
                            .put("planTime", planTime)
                            .put("status", status)
                            .put("speed", speed)
                            .put("total", total)
                            .put("address", address)
                            .getMap());
                }
            }
        };
    }
}
