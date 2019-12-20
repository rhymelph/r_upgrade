# r_upgrade
[![pub package](https://img.shields.io/pub/v/r_upgrade.svg)](https://pub.dartlang.org/packages/r_upgrade)

Android and IOS upgrade plugin.

## [中文点此](README_CN.md)
## Getting Started
- use plugin:
add this code in `pubspec.yaml`
```yaml
dependencies:
  r_upgrade: last version
```
- add listener
```dart
RUpgrade.stream.listen((info){
  ///...
});
```
- just upgrade your android application
```dart
    void upgrade() async {
      int id = await RUpgrade.upgrade(
                 'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
                 apkName: 'app-release.apk');
    }
```
- you can use this id to cancel download
```dart
    void cancel() async {
      bool isSuccess=await RUpgrade.cancel(id);
    }
```
- you can use this id to install apk
```dart
    void install() async {
      bool isSuccess=await RUpgrade.install(id);
    }
```
- your application is ios.You can use this.
```dart
    void iosUpgrade(String url)async{
      RUpgrade.appStore(url);
    }
```

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