# r_upgrade
[![pub package](https://img.shields.io/pub/v/r_upgrade.svg)](https://pub.dartlang.org/packages/r_upgrade)

Android和IOS的升级应用插件==Flutter应用升级插件

## 开始吧

### 1.使用插件:

在`pubspec.yaml`文件添加下面代码
```yaml
dependencies:
  r_upgrade: last version
```

### 2.添加升级下载进度监听
```dart
RUpgrade.stream.listen((DownloadInfo info){
  ///...
});
```
info 里包含的信息如下:

| 字段 | 含义 |
| - | - |
| (int) id | 当前下载任务的id |
| (int) max_length(total已弃用) | 所需下载的总大小 (bytes) |
| (int) current_length(progress已弃用) | 当前已下载的大小 (bytes) |
| (double) percent | 当前下载进度(0-100) |
| (double) planTime | 计划下载完成所需时间/秒 (需要.toStringAsFixed(0)) |
| (String) path(address已弃用) | 当前下载的文件路径 |
| (double) speed | 当前下载的速度kb/s |
| (DownloadStatus) status | 当前下载状态 \n`STATUS_PAUSED` 下载已暂停 \n `STATUS_PENDING`等待下载 \n `STATUS_RUNNING`下载中 \n `STATUS_SUCCESSFUL`下载成功 \n `STATUS_FAILED`下载失败 \n `STATUS_CANCEL`下载取消|

### 3.立即升级你的应用
目前分为两部分
`useDownloadManager`:
- `true`: 调用系统的`DownloadManager`进行下载
- `false`: 调用`Service`进行下载
```dart
    // [isAutoRequestInstall] 下载完成后自动弹出安装
    // [apkName] 安装包的名字（需要包含.apk）
    // [notificationVisibility] 通知栏显示方式
    // [useDownloadManager] 是否使用DownloadManager，默认不使用（DownloadManager不支持https下载，下载手动暂停，断点续传等，不建议使用）
    void upgrade() async {
      int id = await RUpgrade.upgrade(
                 'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
                 apkName: 'app-release.apk',isAutoRequestInstall: true);
    }
```
### 4. 取消下载
`useDownloadManager`:
- `false`: id由调用[upgrade]或调用[getLastUpgradedId]后返回
- `true` : id由调用[upgrade]后返回
```dart
    void cancel() async {
      bool isSuccess=await RUpgrade.cancel(id);
    }
```

### 5. 安装应用
`useDownloadManager`:
- `false`: id由调用[upgrade]或调用[getLastUpgradedId]后返回
- `true` : id由调用[upgrade]后返回
```dart
    void install() async {
      bool isSuccess=await RUpgrade.install(id);
    }
```

### 6. 暂停下载(`Service`)
`useDownloadManager`:
- `false`: id由调用[upgrade]或调用[getLastUpgradedId]后返回
```dart
    void pause() async {
      bool isSuccess=await RUpgrade.pause(id);
    }
```

### 7. 继续下载(`Service`)
`useDownloadManager`:
- `false`: id由调用[upgrade]或调用[getLastUpgradedId]后返回
```dart
    void pause() async {
      bool isSuccess=await RUpgrade.upgradeWithId(id);
      // 返回 false 即表示从来不存在此ID
      // 返回 true
      //    调用此方法前状态为 [STATUS_PAUSED]、[STATUS_FAILED]、[STATUS_CANCEL],将继续下载
      //    调用此方法前状态为 [STATUS_RUNNING]、[STATUS_PENDING]，不会发生任何变化
      //    调用此方法前状态为 [STATUS_SUCCESSFUL]，将会安装应用
    }
```

### 8. 获取最后一次下载的ID(`Service`)
该方法只会寻找当前应用版本名和版本号下下载过的ID
```dart
    void getLastUpgradeId() async {
     int id = await RUpgrade.getLastUpgradedId();
    }
```

### 9. 获取ID对应的下载状态(`Service`)
`useDownloadManager`:
- `false`: id由调用[upgrade]或调用[getLastUpgradedId]后返回
```dart
    void getDownloadStatus()async{
    DownloadStatus status = await RUpgrade.getDownloadStatus(id);
   }
```

### 10.如果你的应用为IOS，使用此方法跳转到appStore进行下载更新
```dart
    void iosUpgrade(String url)async{
      RUpgrade.appStore(url);
    }
```

### 11.热更新
- 你可以使用升级返回的`id`进行热更新，下载的文件需要将新版本生成的`isolate_snapshot_data`、`kernel_blob.bin`、`vm_snapshot_data`打进zip文件中下载
步骤：
    - 运行 `flutter clean` 清理build文件
    - 运行 `flutter build bundle` 生成需要的产物，下面标记星号为必须文件
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
    - 将标记星号的文件打包成zip文件，上传到服务器
    - 调用`RUpgrade.upgrade（...）`方法进行下载
    - 下载完成后，将上面获取到的id进行热更新,调用如下代码

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
    - 重启应用即可

> 注意，在Android应用中，请确保`AndroidManifest.xml`中声明以下权限，并在6.0系统上进行动态授权，不然会调用升级方法将抛出权限异常

```xml
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

> 注意：目前热更新尚处于测试阶段，只支持Flutter代码的变更，不支持资源文件等，热更新造成的一切的后果插件的作者概不负责，由使用者承担。

