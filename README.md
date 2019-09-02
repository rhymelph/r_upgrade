# r_upgrade

Android apk upgrade plugin.

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
      id = await RUpgrade.upgrade(
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