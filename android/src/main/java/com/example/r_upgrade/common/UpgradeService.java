package com.example.r_upgrade.common;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;


import androidx.core.net.ConnectivityManagerCompat;

import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import static com.example.r_upgrade.common.UpgradeManager.DOWNLOAD_STATUS;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_APK_NAME;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_CURRENT_LENGTH;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_ID;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_MAX_LENGTH;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_PATH;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_PERCENT;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_PLAN_TIME;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_SPEED;
import static com.example.r_upgrade.common.UpgradeManager.PARAMS_STATUS;

public class UpgradeService extends Service {
    public static final String DOWNLOAD_ID = "download_id";
    public static final String DOWNLOAD_URL = "download_url";
    public static final String DOWNLOAD_Header = "download_header";
    public static final String DOWNLOAD_APK_NAME = "download_apkName";
    public static final String DOWNLOAD_RESTART = "download_restart";


    private static final String TAG = "UpgradeService";
    private Executor mExecutor = Executors.newSingleThreadExecutor();
    private UpgradeSQLite sqLite;
    private UpgradeRunnable runnable;
    private UpgradeService service;
    private boolean isFirst = true;

    private BroadcastReceiver actionReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent != null && intent.getAction() != null && intent.getAction().equals(RECEIVER_CANCEL)) {
                int id = intent.getIntExtra(PARAMS_ID, 0);
                runnable.cancel(id);
            } else if (intent != null && intent.getAction() != null && intent.getAction().equals(RECEIVER_PAUSE)) {
                int id = intent.getIntExtra(PARAMS_ID, 0);
                runnable.pause(id);
            } else if (intent != null && intent.getAction() != null && intent.getAction().equals(RECEIVER_RESTART)) {
                int id = intent.getIntExtra(PARAMS_ID, 0);
                runnable = new UpgradeRunnable(true, (long) id, null, null, null, service, sqLite);
                mExecutor.execute(runnable);
            } else if (intent != null && intent.getAction() != null && intent.getAction().equals(ConnectivityManager.CONNECTIVITY_ACTION)) {
                ConnectivityManager conMgr = (ConnectivityManager) context.getSystemService(CONNECTIVITY_SERVICE);
                NetworkInfo info = ConnectivityManagerCompat.getNetworkInfoFromBroadcast(conMgr, intent);
                if (info != null && info.isConnected()) {
                    Log.d(TAG, "onReceive: 当前网络正在连接");
                    if (isFirst) {
                        isFirst = false;
                        return;
                    }
                    long id = runnable.id;
                    runnable = new UpgradeRunnable(true, (long) id, runnable.url, runnable.header, runnable.apkName, service, sqLite);
                    mExecutor.execute(runnable);
                } else {
                    if (isFirst) {
                        isFirst = false;
                        return;
                    }
                    runnable.pause(-1);
                    isFirst = false;
                    Log.d(TAG, "onReceive: 当前网络已断开");
                }
            }
        }
    };
    public static final String RECEIVER_CANCEL = "com.example.r_upgrade.RECEIVER_CANCEL";
    public static final String RECEIVER_PAUSE = "com.example.r_upgrade.RECEIVER_PAUSE";
    public static final String RECEIVER_RESTART = "com.example.r_upgrade.RECEIVER_RESTART";

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        service = this;
        sqLite = UpgradeSQLite.getInstance(this);
        IntentFilter filter = new IntentFilter();
        filter.addAction(RECEIVER_CANCEL);
        filter.addAction(RECEIVER_RESTART);
        filter.addAction(RECEIVER_PAUSE);
        filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
        registerReceiver(actionReceiver, filter);

    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        Bundle bundle = intent.getExtras();
        assert (bundle != null);
        String url = bundle.getString(DOWNLOAD_URL);
        int id = bundle.getInt(DOWNLOAD_ID);

        Map<String, Object> header = null;
        if (bundle.getString(DOWNLOAD_Header) != null) {
            getMapForJson(bundle.getString(DOWNLOAD_Header));
        } else {
            header = (Map<String, Object>) bundle.getSerializable(DOWNLOAD_Header);
        }
        String apkName = bundle.getString(DOWNLOAD_APK_NAME);
        boolean isReStart = bundle.getBoolean(DOWNLOAD_RESTART);

        runnable = new UpgradeRunnable(
                isReStart,
                (long) id,
                url,
                header,
                apkName, service, sqLite);

        mExecutor.execute(runnable);

        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public void onDestroy() {
        unregisterReceiver(actionReceiver);
        runnable.handlerDownloadPause();
        super.onDestroy();
    }

    private static class UpgradeRunnable implements Runnable {
        private String url;
        private Long id = null;
        private Map<String, Object> header;
        private String apkName;
        private UpgradeService upgradeService;

        private int maxLength = 0;
        private int currentLength = 0;
        private int lastCurrentLength = 0;
        private long lastTime = System.currentTimeMillis();
        private File downloadFile = null;
        private UpgradeSQLite sqLite;
        private HttpURLConnection httpURLConnection;
        private HttpsURLConnection httpsURLConnection;

        private Timer timer;
        private boolean isRunning = true;
        private boolean isReStart;

        private boolean isNewDownload;

        UpgradeRunnable(boolean isReStart, Long id, String url, Map<String, Object> header, String apkName, UpgradeService upgradeService, UpgradeSQLite sqLite) {
            this.id = id;
            this.url = url;
            this.header = header;
            this.apkName = apkName == null ? "release.apk" : apkName;
            this.upgradeService = upgradeService;
            this.sqLite = sqLite;
            this.isReStart = isReStart;
        }


        private void cancel(int id) {
            if (this.id == id) {
                timer.cancel();
                if (httpsURLConnection != null) {
                    httpsURLConnection.disconnect();
                }
                if (httpURLConnection != null) {
                    httpURLConnection.disconnect();
                }
                isRunning = false;
                handlerDownloadCancel();
                downloadFile.delete();
            }
        }

        private void pause(int id) {
            if (id == -1 || this.id == id) {
                if (httpsURLConnection != null) {
                    httpsURLConnection.disconnect();
                }
                if (httpURLConnection != null) {
                    httpURLConnection.disconnect();
                }
                isRunning = false;
                handlerDownloadPause();
            }
        }

        private boolean handlerDownloadPending() {
            if (isReStart) {
                SQLiteDatabase readableDatabase = sqLite.getReadableDatabase();
                Cursor cursor = readableDatabase.rawQuery("select * from " + UpgradeSQLite.VERSION_MANAGER + " where " + UpgradeSQLite.ID + "=?", new String[]{String.valueOf(id)});
                boolean canMove = cursor.moveToNext();
                if (!canMove) {
                    // 重新下载
                    File parentFile = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                    downloadFile = new File(parentFile.getPath(), apkName);
                    JSONObject object = null;
                    if (header != null) {
                        object = new JSONObject(header);
                    }
                    //更新一条SQL
                    sqLite.update(id, url, downloadFile.getPath(), apkName, object == null ? "" : object.toString(), currentLength, maxLength, DownloadStatus.STATUS_PENDING.getValue());
                    cursor.close();
                    return true;
                } else {
                    boolean isNewDownload = false;

                    //续传
                    String path = cursor.getString(cursor.getColumnIndex(UpgradeSQLite.PATH));
                    downloadFile = new File(path);
                    //下载的文件已被删除
                    if (!downloadFile.exists()) {
                        try {
                            downloadFile.createNewFile();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                        currentLength = 0;
                        lastCurrentLength = currentLength;
                        isNewDownload = true;
                    } else {
                        currentLength = cursor.getInt(cursor.getColumnIndex(UpgradeSQLite.CURRENT_LENGTH));
                        lastCurrentLength = currentLength;
                        maxLength = cursor.getInt(cursor.getColumnIndex(UpgradeSQLite.MAX_LENGTH));
                    }
                    apkName = cursor.getString(cursor.getColumnIndex(UpgradeSQLite.APK_NAME));
                    url = cursor.getString(cursor.getColumnIndex(UpgradeSQLite.URL));
                    String header = cursor.getString(cursor.getColumnIndex(UpgradeSQLite.HEADER));
                    this.header = getMapForJson(header);
                    cursor.close();
                    //更新一条SQL
                    sqLite.update(id, currentLength, maxLength, DownloadStatus.STATUS_PENDING.getValue());

                    return isNewDownload;
                }
            } else {
                // 重新下载
                File parentFile = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS);
                downloadFile = new File(parentFile.getPath(), apkName);
                JSONObject object = null;
                if (header != null) {
                    object = new JSONObject(header);
                }
                //更新一条SQL
                sqLite.update(id, url, downloadFile.getPath(), apkName, object == null ? "" : object.toString(), currentLength, maxLength, DownloadStatus.STATUS_PENDING.getValue());
                return true;
            }
        }

        private void handlerDownloadRunning() {
            if (currentLength - lastCurrentLength > 0) {
                double percent = new BigDecimal((currentLength * 1.0f / maxLength) * 100).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
                double speed = ((currentLength - lastCurrentLength) * 1000f / (System.currentTimeMillis() - lastTime)) / 1024;
                //计划完成时间
                double planTime = (maxLength - currentLength) / (speed * 1024f);
                Intent intent = new Intent();
                intent.setAction(DOWNLOAD_STATUS);
                intent.putExtra(PARAMS_CURRENT_LENGTH, currentLength);
                intent.putExtra(PARAMS_STATUS, DownloadStatus.STATUS_RUNNING.getValue());
                intent.putExtra(PARAMS_PERCENT, percent);
                intent.putExtra(PARAMS_MAX_LENGTH, maxLength);
                intent.putExtra(PARAMS_SPEED, speed);
                intent.putExtra(PARAMS_PLAN_TIME, planTime);
                intent.putExtra(PARAMS_PATH, downloadFile.getPath());
                intent.putExtra(PARAMS_ID, id);
                intent.putExtra(PARAMS_APK_NAME, apkName);
                upgradeService.sendBroadcast(intent);
                sqLite.update(id, currentLength, maxLength, DownloadStatus.STATUS_RUNNING.getValue());
//                Log.d(TAG, "handlerDownloadRunning: running queryTask: 下载中\n" +
//                        "url: " +
//                        url +
//                        "\n============>" +
//                        "total:" +
//                        maxLength +
//                        "，" +
//                        "progress:" +
//                        currentLength +
//                        "，" +
//                        String.format("%.2f", percent) +
//                        "% , " +
//                        String.format("%.2f", speed) +
//                        "kb/s , " +
//                        "预计：" +
//                        String.format("%.0f", planTime) +
//                        "s");
                lastCurrentLength = currentLength;
                lastTime = System.currentTimeMillis();
            }
        }

        private void handlerDownloadCancel() {
//            Log.d(TAG, "handlerDownloadCancel: ");
            timer.cancel();
            Intent intent = new Intent();
            intent.setAction(DOWNLOAD_STATUS);
            intent.putExtra(PARAMS_ID, id);
            intent.putExtra(PARAMS_APK_NAME, apkName);
            intent.putExtra(PARAMS_PATH, downloadFile.getPath());
            intent.putExtra(PARAMS_STATUS, DownloadStatus.STATUS_CANCEL.getValue());
            upgradeService.sendBroadcast(intent);
            sqLite.delete(id);
        }

        private void handlerDownloadPause() {
            Log.d(TAG, "handlerDownloadPause: downloadFile:" + downloadFile);
            if (timer != null) {
                timer.cancel();
            }
            Intent intent = new Intent();
            intent.setAction(DOWNLOAD_STATUS);
            intent.putExtra(PARAMS_ID, id);
            intent.putExtra(PARAMS_APK_NAME, apkName);
            intent.putExtra(PARAMS_PATH, downloadFile.getPath());
            intent.putExtra(PARAMS_STATUS, DownloadStatus.STATUS_PAUSED.getValue());
            upgradeService.sendBroadcast(intent);
            sqLite.update(id, currentLength, maxLength, DownloadStatus.STATUS_PAUSED.getValue());
        }

        private void handlerDownloadFinish() {
//            Log.d(TAG, "handlerDownloadFinish: finish");
            timer.cancel();
            Intent intent = new Intent();
            intent.setAction(DOWNLOAD_STATUS);
            intent.putExtra(PARAMS_ID, id);
            intent.putExtra(PARAMS_APK_NAME, apkName);
            intent.putExtra(PARAMS_PATH, downloadFile.getPath());
            intent.putExtra(PARAMS_STATUS, DownloadStatus.STATUS_SUCCESSFUL.getValue());
            upgradeService.sendBroadcast(intent);
            sqLite.update(id, null, null, DownloadStatus.STATUS_SUCCESSFUL.getValue());
            lastCurrentLength = 0;
        }

        private void handlerDownloadFailure() {
//            Log.d(TAG, "handlerDownloadFailure: failure");
            Intent intent = new Intent(DOWNLOAD_STATUS);
            intent.putExtra(PARAMS_ID, id);
            intent.putExtra(PARAMS_APK_NAME, apkName);
            intent.putExtra(PARAMS_PATH, downloadFile.getPath());
            intent.putExtra(PARAMS_STATUS, DownloadStatus.STATUS_FAILED.getValue());
            sqLite.update(id, null, null, DownloadStatus.STATUS_FAILED.getValue());
            try {
                Thread.sleep(500);
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }
            upgradeService.sendBroadcast(intent);
        }

        @Override
        public void run() {
            isNewDownload = handlerDownloadPending();
            //下载文件不存在，但是需要续下载？
            if (!downloadFile.exists() && !isNewDownload) {
                isNewDownload = true;
                currentLength = 0;

            }
            timer = new Timer();
            timer.schedule(new TimerTask() {
                @Override
                public void run() {
                    handlerDownloadRunning();
                }
            }, 500, 500);

            InputStream is = null;
            FileOutputStream fos = null;
            RandomAccessFile raf = null;

            try {
                if (isNewDownload) {
                    fos = new FileOutputStream(downloadFile);
                    if (!downloadFile.exists()) {
                        downloadFile.createNewFile();
                    }
                } else {
                    raf = new RandomAccessFile(downloadFile, "rwd");
                    raf.seek(currentLength);
                }

                URL url = new URL(this.url);
                if (this.url.startsWith("https")) {
                    HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
                    connection.setRequestMethod("GET");
                    connection.setReadTimeout(6 * 60 * 1000);
                    connection.setConnectTimeout(6 * 60 * 1000);
                    if (header != null && !header.isEmpty()) {
                        for (Map.Entry<String, Object> entry : header.entrySet()) {
                            connection.setRequestProperty(entry.getKey(), (String) entry.getValue());
                        }
                    }
                    if (!isNewDownload) {
                        connection.setRequestProperty("range", "bytes=" + currentLength + "-");
                    }
                    TrustManager[] tm = {new MyX509TrustManager()};
                    SSLContext sslContext = SSLContext.getInstance("TLS");
                    sslContext.init(null, tm, new java.security.SecureRandom());
                    // 从上述SSLContext对象中得到SSLSocketFactory对象
                    SSLSocketFactory ssf = sslContext.getSocketFactory();
                    connection.setSSLSocketFactory(ssf);
                    connection.setDoInput(true);
                    int code = connection.getResponseCode();
                    Log.d(TAG, "run: code=" + code);
                    connection.connect();
                    is = connection.getInputStream();
                    if (isNewDownload) {
                        maxLength = connection.getContentLength();
                    }
                } else {
                    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
                    connection.setRequestMethod("GET");
                    connection.setConnectTimeout(6 * 60 * 1000);
                    connection.setReadTimeout(6 * 60 * 1000);
                    if (header != null && !header.isEmpty()) {
                        for (Map.Entry<String, Object> entry : header.entrySet()) {
                            connection.setRequestProperty(entry.getKey(), (String) entry.getValue());
                        }
                    }
                    if (!isNewDownload) {
                        connection.setRequestProperty("range", "bytes=" + currentLength + "-");
                    }
                    connection.setDoInput(true);
                    int code = connection.getResponseCode();
                    Log.d(TAG, "run: code=" + code);
                    connection.connect();
                    is = connection.getInputStream();
                    if (isNewDownload) {
                        maxLength = connection.getContentLength();
                    }
                }
                assert (is != null);
                Log.d(TAG, "run: maxLength:" + maxLength);

                byte[] buff = new byte[1024];

                int len = 0;
                while ((len = is.read(buff)) != -1) {
                    if (!isRunning) {
                        break;
                    }
                    if (isNewDownload) {
                        assert (fos != null);
                        fos.write(buff, 0, len);
                    } else {
                        assert (raf != null);
                        raf.write(buff, 0, len);
                    }
                    currentLength += len;
                }
                if (isNewDownload) {
                    assert (fos != null);
                    fos.flush();
                    fos.close();
                } else {
                    assert (raf != null);
                    raf.close();
                }
                is.close();
                if (isRunning) {
                    handlerDownloadFinish();
                }
            } catch (Exception e) {
                timer.cancel();
                e.printStackTrace();
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException ex) {
                        ex.printStackTrace();
                    }
                }
                if (fos != null) {
                    try {
                        fos.close();
                    } catch (IOException ex) {
                        ex.printStackTrace();
                    }
                }
                if (raf != null) {
                    try {
                        raf.close();
                    } catch (IOException ex) {
                        ex.printStackTrace();
                    }
                }
                if (isRunning) {
                    handlerDownloadFailure();
                }
            }
        }

        private Map<String, Object> getMapForJson(String jsonStr) {
            if (jsonStr == null || jsonStr.isEmpty()) return null;

            JSONObject jsonObject;
            try {
                jsonObject = new JSONObject(jsonStr);

                Iterator<String> keyIter = jsonObject.keys();
                String key;
                Object value;
                Map<String, Object> valueMap = new HashMap<String, Object>();
                while (keyIter.hasNext()) {
                    key = keyIter.next();
                    value = jsonObject.get(key);
                    valueMap.put(key, value);
                }
                return valueMap;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return new HashMap<String, Object>();
        }

    }

    private Map<String, Object> getMapForJson(String jsonStr) {
        if (jsonStr == null || jsonStr.isEmpty()) return null;

        JSONObject jsonObject;
        try {
            jsonObject = new JSONObject(jsonStr);

            Iterator<String> keyIter = jsonObject.keys();
            String key;
            Object value;
            Map<String, Object> valueMap = new HashMap<String, Object>();
            while (keyIter.hasNext()) {
                key = keyIter.next();
                value = jsonObject.get(key);
                valueMap.put(key, value);
            }
            return valueMap;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return new HashMap<String, Object>();
    }


    private static class MyX509TrustManager implements X509TrustManager {

        // 检查客户端证书
        public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        }

        // 检查服务器端证书
        public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
        }

        // 返回受信任的X509证书数组
        public X509Certificate[] getAcceptedIssuers() {
            return null;
        }
    }
}

