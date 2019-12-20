package com.example.r_upgrade;

import android.app.DownloadManager;
import android.content.Context;
import android.content.ContextWrapper;
import android.net.Uri;
import android.os.ParcelFileDescriptor;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileDescriptor;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.PluginRegistry;

public class HotUpgradeManager extends ContextWrapper {
    final PluginRegistry.Registrar _register;
    private static final String TAG = "HotUpgradeManager";
    private static final String FLUTTER_ASSETS="flutter_assets";
    private static final String APP_FLUTTER = "app_flutter";

    public HotUpgradeManager(Context base, PluginRegistry.Registrar registrar) {
        super(base);
        this._register = registrar;
    }

    private File getFlutterAssets() {
        File file = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            file = new File(getDataDir(), APP_FLUTTER);
        }
        return file;
    }

    private File getHotAssets() {
        File file = null;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            file = new File(getFlutterAssets(), System.currentTimeMillis() + ".zip");
            if (!file.exists()) {
                try {
                    boolean isSuccess = file.createNewFile();
                    return isSuccess ? file : null;
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return file;
    }

    private boolean deleteFlutterAssets(){
        File file = new File(getFlutterAssets(),FLUTTER_ASSETS);
        if(file.exists()){
            if(file.isDirectory()){
                for (File item : file.listFiles()){
                    if(item.exists()){
                        item.delete();
                    }
                }
            }
            file.delete();
        }else {
            return false;
        }
        return  true;
    }

    public Boolean hotUpgrade(int id) {
        File file = getFlutterAssets();
        if (file == null) return false;
        DownloadManager manager = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);
        Uri uri = manager.getUriForDownloadedFile(id);
        //获取文件流
        try {
            //复制下载的文件到资源文件中
            ParcelFileDescriptor descriptor = getContentResolver().openFileDescriptor(uri, "r");
            FileDescriptor fileDescriptor = descriptor.getFileDescriptor();
            if (fileDescriptor == null) return false;
            FileInputStream stream = new FileInputStream(fileDescriptor);
//                File file = new File();
            File zipFile = getHotAssets();
            FileOutputStream outputStream = new FileOutputStream(zipFile);
            byte[] buffer = new byte[1024];
            int byteRead;
            while (-1 != (byteRead = stream.read(buffer))) {
                outputStream.write(buffer, 0, byteRead);
            }
            stream.close();
            outputStream.flush();
            outputStream.close();

            deleteFlutterAssets();
            unZipFile(zipFile.getPath(),getFlutterAssets().getPath()+File.separator+FLUTTER_ASSETS,true);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     *
     * @param archive 解压文件得路径
     * @param decompressDir 解压文件目标路径
     * @param isDeleteZip  解压完毕是否删除解压文件
     * @throws IOException
     */
    public static void unZipFile(String archive, String decompressDir, boolean isDeleteZip) throws IOException {
        BufferedInputStream bi;
        ZipFile zf = new ZipFile(archive);
        Enumeration e = zf.entries();
        while (e.hasMoreElements()) {
            ZipEntry ze2 = (ZipEntry) e.nextElement();
            String entryName = ze2.getName();
            String path = decompressDir + "/" + entryName;
            if (ze2.isDirectory()) {
                File decompressDirFile = new File(path);
                if (!decompressDirFile.exists()) {
                    decompressDirFile.mkdirs();
                }
            } else {
                String fileDir = path.substring(0, path.lastIndexOf("/"));
                if (decompressDir.endsWith(".zip")) {
                    decompressDir = decompressDir.substring(0, decompressDir.lastIndexOf(".zip"));
                }
                File fileDirFile = new File(decompressDir);
                if (!fileDirFile.exists()) {
                    fileDirFile.mkdirs();
                }
                String substring = entryName.substring(entryName.lastIndexOf("/") + 1, entryName.length());
                BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(decompressDir + "/" + substring));
                bi = new BufferedInputStream(zf.getInputStream(ze2));
                byte[] readContent = new byte[1024];
                int readCount = bi.read(readContent);
                while (readCount != -1) {
                    bos.write(readContent, 0, readCount);
                    readCount = bi.read(readContent);
                }
                bos.close();
            }
        }
        zf.close();
        if (isDeleteZip) {
            File zipFile = new File(archive);
            if (zipFile.exists() && zipFile.getName().endsWith(".zip")) {
                zipFile.delete();
            }
        }
    }
}
