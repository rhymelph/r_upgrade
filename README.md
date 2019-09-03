# r_upgrade
[![pub package](https://img.shields.io/pub/v/r_upgrade.svg)](https://pub.dartlang.org/packages/r_upgrade)

Android and IOS upgrade plugin.

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

> if your application is **Android**,make sure your application had this permission and request dynamic permission.

```xml
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```