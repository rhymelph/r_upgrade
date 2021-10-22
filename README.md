# r_upgrade
[![pub package](https://img.shields.io/pub/v/r_upgrade.svg)](https://pub.dartlang.org/packages/r_upgrade)

![](screen/r_upgrade.png)

## [中文点此](README_CN.md)

Android and IOS upgrade plugin.

- [✔] Jump link mode upgrade
- [✔] `Android` get android store
- [✔] `Android` get version from android stores（only support GoolePlay、XiaoMi、Tencent）
- [✔] `Android` Jump to store mode upgrade
- [✔] `Android` Download APK using download link
    - [✔] Monitor download information
    - [✔] cancel/pause/continue download
    - [✔] Get download status according to ID
    - [✔] Install app according to ID
    - [✔] Get the last download ID (based on the version name and version number)
    - [✔] Modify the information displayed in the notification bar
- [✔] `Android` hot upgrade
- [✔] `Android` increment upgrade
- [✔] `IOS` Jump to Appstore upgrade according to appid
- [✔] `IOS` Get the current online version of Appstore according to appid

> For the development of this plug-in, I haven't had a good meal for a long time. I hope you can click on the sponsor and give a little bit of money. Thank you!

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

### 1.Get android store list.
```dart
    void getAndroidStores() async {
       final stores = await RUpgrade.androidStores;
    }
```

### 2.Get version from android store.
```dart
    void getVersionName() async {
       final versionName = await RUpgrade.getVersionFromAndroidStore(AndroidStore.GOOGLE_PLAY);
    }
```

### 3. App upgrade from store.
```dart
    void upgradeFromAndroidStore(){
       bool isSuccess = await RUpgrade.upgradeFromAndroidStore(AndroidStore.GOOGLE_PLAY);
       print('${isSuccess?'jump success':'jump error'}');
    }
```

### 4. App upgrade from download link.

> make sure your application had this permission and request dynamic permission.

```xml
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

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
| (int) max_length | download max bytes length (bytes) |
| (int) current_length | download current bytes length (bytes) |
| (double) percent | download percent 0-100 |
| (double) planTime | download plan time /s (X.toStringAsFixed(0)) |
| (String) path | download file path |
| (double) speed | download speed kb/s |
| (DownloadStatus) status | download status <br> `STATUS_PAUSED` <br> `STATUS_PENDING` <br> `STATUS_RUNNING` <br> `STATUS_SUCCESSFUL` <br> `STATUS_FAILED` <br> `STATUS_CANCEL`|

#### 2. Upgrade your application
This upgrade have two part.
`useDownloadManager`:
- `true`: Use system `DownloadManager`to download
    - advantage：Simple, use system.
    - Inferiority：can not use http download , can not click the notification pause downloading, can not pause and continue download by network status etc...
    - support: `RUpgrade.stream`、`install`、`cancel`
- `false`: Use `Service` download（default use）
    - advantage：Power, support http/https download, support auto pause and continue download by network status etc..
    - Inferiority：No bugs found yet. If you find a bug, you are welcome to issue
    - support: `RUpgrade.stream`、`install`、`cancel`
```dart
    // [isAutoRequestInstall] downloaded finish will auto request install apk.
    // [apkName] apk name (such as `release.apk`)
    // [notificationVisibility] notification visibility.
    // [notificationStyle] download notification show style about content text, only support [useDownloadManager]==false.
    // [useDownloadManager] if true will use DownloadManager,false will use my service ,
    //         if true will no use [pause] , [upgradeWithId] , [getDownloadStatus] , [getLastUpgradedId] methods.
    // [upgradeFlavor] you can use [RUpgradeFlavor.normal] , [RUpgradeFlavor.hotUpgrade] , [RUpgradeFlavor.incrementUpgrade] flavor
    void upgrade() async {
      int id = await RUpgrade.upgrade(
                 'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
                 apkName: 'app-release.apk',isAutoRequestInstall: true);
    }
```
New upgraded flavor：(no support use DownloadManager)
```dart
enum RUpgradeFlavor {
  normal, // full upgrade
  hotUpgrade, // hot upgrade
  incrementUpgrade, // increment upgrade
}
```

#### 3. Cancel Download
```dart
    void cancel() async {
      bool isSuccess=await RUpgrade.cancel(id);
    }
```

#### 4. Install Apk
```dart
    void install() async {
      bool isSuccess=await RUpgrade.install(id);
    }
```

#### 5. Pause Download
```dart
    void pause() async {
      bool isSuccess=await RUpgrade.pause(id);
    }
```

#### 6. Continue Download
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

#### 7. Get the last upgrade id
```dart
    void getLastUpgradeId() async {
     int id = await RUpgrade.getLastUpgradedId();
    }
```

#### 8. Get the download status from id
```dart
    void getDownloadStatus()async{
    DownloadStatus status = await RUpgrade.getDownloadStatus(id);
   }
```
#### 9. Increment Upgrade
- 1.Download [bsdiff](https://github.com/rhymelph/r_upgrade/releases/download/v0.3.0/bsdiff) to local.
- 2.Prepare two installation packages, one is the one to be upgraded（ old.apk ）, an installation package that you need to update（ new.apk )
- 3.Switch to the 'bsdiff' directory downloaded above on the command line, and run the command`./bsdiff old.apk new.apk increment.patch`
- 4.Put the` increment.patch `Upload to server
- 5.use `RUpgrade.upgrade（...,upgradeFlavor:RUpgradeFlavor.incrementUpgrade）`download file
- 6.use `RUpgrade.install(id)` install apk.

The code is as follows：
```dart
    int id;
    void incrementUpgrade(){
        id = await RUpgrade.upgrade(
                'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.patch',
                fileName: 'r_upgrade.patch',
                useDownloadManager: false,
                isAutoRequestInstall: false,
                upgradeFlavor: RUpgradeFlavor.incrementUpgrade,
              );
    }

    void install(){
        try {
            await RUpgrade.install(id);
        } catch (e) {
            _state.currentState
                .showSnackBar(SnackBar(content: Text('failure!')));
        }
    }
```

#### 10. Hot Upgrade
- you can use this id to hot upgrade,but download file is zip. include three file [isolate_snapshot_data]、[kernel_blob.bin]、[vm_snapshot_data].Your can use `flutter build bundle` generate.
```
 flutter build bundle
```

- generate file path form ./build/flutter_assets and packaged into zip.

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

- use `RUpgrade.upgrade（...,upgradeFlavor:RUpgradeFlavor.hotUpgrade）`download file.
- download complete you can use download `id` to hot upgrade

```dart
           bool isSuccess = await RUpgrade.hotUpgrade(id);
           if (isSuccess) {
              _state.currentState
                    .showSnackBar(SnackBar(content: Text('Hot update succeeded, exit the application after 3S, please enter again')));
                Future.delayed(Duration(seconds: 3)).then((_){
                  SystemNavigator.pop(animated: true);
                });
           }else{
              _state.currentState
                    .showSnackBar(SnackBar(content: Text('Hot update failed, please wait for update package download to complete')));
              }
```
> At present, the hot update is still in the testing stage, only supporting the change of the flutter code, not supporting the resource file, etc. the author of the plug-in is not responsible for all the consequences caused by the hot update, and the user is responsible for it.

## Android Platform Notification Bar
If you want to customize the content displayed in the download notification bar, you can do so, modify or add files `project/android/app/main/res/values/r_upgrade_value.xml`，add the following code
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
                 false
              );
        print(isSuccess);
    }
```

### 2.Get the last version form AppStore
```dart
    void getVersionFromAppStore() async {
        String versionName = await RUpgrade.getVersionFromAppStore(
                'your AppId',//such as:WeChat AppId:414478124
                false
               );
        print(versionName);
    }
```
