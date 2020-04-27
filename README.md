# r_upgrade
[![pub package](https://img.shields.io/pub/v/r_upgrade.svg)](https://pub.dartlang.org/packages/r_upgrade)

![](screen/r_upgrade.png)

Android and IOS upgrade plugin.

## [中文点此](README_CN.md)

## Getting Started

### 1. Use Plugin:
add this code in `pubspec.yaml`

```yaml
dependencies:
  r_upgrade: last version
```

### 2. Upgrade from your website ( Android or IOS )
```dart
    void upgradeFromUrl()async{
        bool isSuccess =await RUpgrade.upgradeFromUrl(
                    'https://www.google.com',
                  );
        print(isSuccess);
    }
```

## Android Platform

### 1. App upgrade from store.
```dart
    void upgradeFromAndroidStore(){
       bool isSuccess = await RUpgrade.upgradeFromAndroidStore(AndroidStore.GOOGLE_PLAY);
       print('${isSuccess?'jump success':'jump error'}');
    }
```

### 2. App upgrade from download link.

#### 1. Add Upgrade Download Listener
```dart
RUpgrade.stream.listen((DownloadInfo info){
  ///...
});
```
info:

| param | desc |
| - | - |
| (int) id | download id |
| (int) max_length<br> ( total Deprecated ) | download max bytes length (bytes) |
| (int) current_length <br> ( progress Deprecated ) | download current bytes length (bytes) |
| (double) percent | download percent 0-100 |
| (double) planTime | download plan time /s (X.toStringAsFixed(0)) |
| (String) path <br> ( address Deprecated ) | download file path |
| (double) speed | download speed kb/s |
| (DownloadStatus) status | download status <br> `STATUS_PAUSED` <br> `STATUS_PENDING` <br> `STATUS_RUNNING` <br> `STATUS_SUCCESSFUL` <br> `STATUS_FAILED` <br> `STATUS_CANCEL`|

#### 2. Upgrade your application
This upgrade have two part.
`useDownloadManager`:
- `true`: Use system `DownloadManager`to download
    - advantage：Simple, use system.
    - Inferiority：can not use http download , can not click the notification pause downloading, can not pause and continue download by network status etc...
- `false`: Use `Service` download（default use）
    - advantage：Power, support http/https download, support auto pause and continue download by network status etc..
    - Inferiority：No bugs found yet. If you find a bug, you are welcome to issue
```dart
    // [isAutoRequestInstall] downloaded finish will auto request install apk.
    // [apkName] apk name (such as `release.apk`)
    // [notificationVisibility] notification visibility.
    // [notificationStyle] download notification show style about content text, only support [useDownloadManager]==false.
    // [useDownloadManager] look up at
    void upgrade() async {
      int id = await RUpgrade.upgrade(
                 'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
                 apkName: 'app-release.apk',isAutoRequestInstall: true);
    }
```
#### 3. Cancel Download
`useDownloadManager`:
- `false`: use `upgrade`or `getLastUpgradedId` method will return .
- `true` : use `upgrade` method will return .
```dart
    void cancel() async {
      bool isSuccess=await RUpgrade.cancel(id);
    }
```

#### 4. Install Apk
`useDownloadManager`:
- `false`: use `upgrade`or `getLastUpgradedId` method will return .
- `true` : use `upgrade` method will return .
```dart
    void install() async {
      bool isSuccess=await RUpgrade.install(id);
    }
```

#### 5. Pause Download(`Service`)
`useDownloadManager`:
- `false`: use `upgrade`or `getLastUpgradedId` method will return .
```dart
    void pause() async {
      bool isSuccess=await RUpgrade.pause(id);
    }
```

#### 6. Continue Download(`Service`)
`useDownloadManager`:
- `false`: use `upgrade`or `getLastUpgradedId` method will return .
```dart
    void pause() async {
      bool isSuccess=await RUpgrade.upgradeWithId(id);
      /// return true.
      /// * if download status is [STATUS_PAUSED] or [STATUS_FAILED] or [STATUS_CANCEL], will restart running.
      /// * if download status is [STATUS_RUNNING] or [STATUS_PENDING], nothing happened.
      /// * if download status is [STATUS_SUCCESSFUL] , will install apk.
      ///
      /// return false.
      /// * if not found the id , will return [false].
    }
```

#### 7. Get the last upgrade id(`Service`)
this method will find id by your application version name and version code.
```dart
    void getLastUpgradeId() async {
     int id = await RUpgrade.getLastUpgradedId();
    }
```

#### 8. Get the download status from id(`Service`)
`useDownloadManager`:
- `false`: use `upgrade`or `getLastUpgradedId` method will return .
```dart
    void getDownloadStatus()async{
    DownloadStatus status = await RUpgrade.getDownloadStatus(id);
   }
```

#### 9. Hot Upgrade ( use DownloadManager )
- you can use this id to hot upgrade,but download file is zip. include three file [isolate_snapshot_data]、[kernel_blob.bin]、[vm_snapshot_data].Your can use `flutter build bundle` generate.
```
 flutter build bundle
```

generate file path form ./build/flutter_assets and packaged into zip.

```
|- AssetManifest.json
|- FontManifest.json
|- fonts
    |- ...
|- isolate_snapshot_data *
|- kernel-blob.bin       *
|- LICENSE
|- packages
    |- ...
|- vm_snapshot_data      *
```
download complete you can use download `id` to hot upgrade
```dart
           bool isSuccess = await RUpgrade.hotUpgrade(id);
           if (isSuccess) {
              _state.currentState
                    .showSnackBar(SnackBar(content: Text('热更新成功，3s后退出应用，请重新进入')));
                Future.delayed(Duration(seconds: 3)).then((_){
                  SystemNavigator.pop(animated: true);
                });
           }else{
              _state.currentState
                    .showSnackBar(SnackBar(content: Text('热更新失败，请等待更新包下载完成')));
              }
```

> if your application is **Android**,make sure your application had this permission and request dynamic permission.

```xml
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

> At present, the hot update is still in the testing stage, only supporting the change of the flutter code, not supporting the resource file, etc. the author of the plug-in is not responsible for all the consequences caused by the hot update, and the user is responsible for it.

## Android Platform Notification Bar
If you want to customize the content displayed in the download notification bar, you can do so, modify or add files `project/android/app/main/res/r_upgrade_value.xml`，add the following code
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="r_upgrade_download_speech">%.0f kb/s</string>
    <string name="r_upgrade_download_planTime">%.0fs left</string>
    <string name="r_upgrade_download_finish">Download finished</string>
    <string name="r_upgrade_download_paused">Download paused</string>
    <string name="r_upgrade_download_failed">Download failed</string>
</resources>
```
And then.When you use `upgrade` method,you should set the `notificationStyle` param.
```dart
/// Notification show style about content text
enum NotificationStyle {
  speechAndPlanTime, // 100kb/s 1s left
  planTimeAndSpeech, // 1s left 100kb/s
  speech,// 100kb/s
  planTime, // 1s left
  none, //
}
```

## IOS Platform

### 1.Go to the AppStore Upgrade
```dart
    void upgradeFromAppStore() async {
        bool isSuccess =await RUpgrade.upgradeFromAppStore(
                 'your AppId',//such as:WeChat AppId:414478124
              );
        print(isSuccess);
    }
```

### 2.Get the last version form AppStore
```dart
    void getVersionFromAppStore() async {
        String versionName = await RUpgrade.getVersionFromAppStore(
                'your AppId',//such as:WeChat AppId:414478124
               );
        print(versionName);
    }
```