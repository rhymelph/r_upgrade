# r_upgrade
[![pub package](https://img.shields.io/pub/v/r_upgrade.svg)](https://pub.dartlang.org/packages/r_upgrade)

![](screen/r_upgrade.png)

Android和IOS的升级应用插件==Flutter应用升级插件

- [✔] 跳转链接方式升级
- [✔] 跳转到应用商店升级
- [✔] `Android`使用下载链接下载APK
    - [✔] 监听下载信息
    - [✔] 取消/暂停/继续下载
    - [✔] 根据ID安装应用
    - [✔] 根据ID获取下载状态
    - [✔] 获取最后一次下载ID（根据版本名和版本号）
    - [✔] 修改通知栏显示的信息
- [✔] `Android`热更新
- [✔] `Android`增量升级
- [✔] `IOS`根据APPID跳转AppStore升级
- [✔] `IOS`根据APPID获取AppStore当前上架版本

## 开始吧

### 1.使用插件:

在`pubspec.yaml`文件添加下面代码
```yaml
dependencies:
  r_upgrade: last version
```

### 2.使用打开链接的方式进行更新（`Android`和`IOS`通用）
```dart
    void upgradeFromUrl()async{
        bool isSuccess =await RUpgrade.upgradeFromUrl(
                    'https://www.baidu.com',
                  );
        print(isSuccess);
    }
```

## Android平台

### 1.跳转到应用商店升级
```dart
    void upgradeFromAndroidStore(){
       bool isSuccess = await RUpgrade.upgradeFromAndroidStore(AndroidStore.BAIDU);
       print('${isSuccess?'跳转成功':'跳转失败'}');
    }
```
### 2.通过下载链接进行apk下载

> 注意，在Android应用中，请确保`AndroidManifest.xml`中声明以下权限，并在6.0系统上进行动态授权，不然会调用升级方法将抛出权限异常
```xml
    <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

#### 1.添加升级下载进度监听
```dart
RUpgrade.stream.listen((DownloadInfo info){
  ///...
});
```
info 里包含的信息如下:

| 字段 | 含义 |
| - | - |
| (int) id | 当前下载任务的id |
| (int) max_length | 所需下载的总大小 (bytes) |
| (int) current_length | 当前已下载的大小 (bytes) |
| (double) percent | 当前下载进度(0-100) |
| (double) planTime | 计划下载完成所需时间/秒 (需要.toStringAsFixed(0)) |
| (String) path | 当前下载的文件路径 |
| (double) speed | 当前下载的速度kb/s |
| (DownloadStatus) status | 当前下载状态 <br> `STATUS_PAUSED` 下载已暂停 <br> `STATUS_PENDING`等待下载 <br> `STATUS_RUNNING`下载中 <br> `STATUS_SUCCESSFUL`下载成功 <br> `STATUS_FAILED`下载失败 <br> `STATUS_CANCEL`下载取消|

注意： 部分http下载链接可能返回 `max_length = -1`，请自行判断

#### 2.立即升级你的应用
目前分为两部分
`useDownloadManager`:
- `true`: 调用系统的`DownloadManager`进行下载
    - 优势：接入简单，无需担心操作，下载全由系统管理
    - 劣势：无法使用http方式进行下载，无法在下载过程中点击通知栏进行暂停，无法根据有无网络进行暂停和继续下载，适配机型问题等
    - 支持的方法：`RUpgrade.stream`、`install`、`cancel`
- `false`: 调用`Service`进行下载（默认使用）
    - 优势：功能较全，支持http/https下载，支持网络断开后自动暂停下载，连接上后继续下载，支持断点续传，支持查询最后一次下载等
    - 劣势：暂无发现，如果发现bug欢迎提issue.
    - 支持的方法：默认全部
```dart
    // [isAutoRequestInstall] 下载完成后自动弹出安装
    // [apkName] 安装包的名字（需要包含.apk）
    // [notificationVisibility] 通知栏显示方式
    // [useDownloadManager] 是否使用DownloadManager，默认不使用（DownloadManager不支持http下载，下载手动暂停，断点续传等，不建议使用）
    // [upgradeFlavor] 升级的口味，默认全量升级（默认）
    void upgrade() async {
      int id = await RUpgrade.upgrade(
                 'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
                 apkName: 'app-release.apk',isAutoRequestInstall: true);
    }
```
新增升级的口味：(不支持使用DownloadManager下载)
```dart
enum RUpgradeFlavor {
  normal, // 全量升级
  hotUpgrade, // 热更新
  incrementUpgrade, // 增量升级
}
```

#### 3. 取消下载
```dart
    void cancel() async {
      bool isSuccess=await RUpgrade.cancel(id);
    }
```

#### 4. 安装应用
```dart
    void install() async {
      bool isSuccess=await RUpgrade.install(id);
    }
```

#### 5. 暂停下载
```dart
    void pause() async {
      bool isSuccess=await RUpgrade.pause(id);
    }
```

#### 6. 继续下载
```dart
    void pause() async {
      bool isSuccess=await RUpgrade.upgradeWithId(id);
      // 返回 false 即表示从来不存在此ID
      // 返回 true
      //    调用此方法前状态为 [STATUS_PAUSED]、[STATUS_FAILED]、[STATUS_CANCEL],将继续下载
      //    调用此方法前状态为 [STATUS_RUNNING]、[STATUS_PENDING]，不会发生任何变化
      //    调用此方法前状态为 [STATUS_SUCCESSFUL]，将会安装应用
      // 当文件被删除时，重新下载
    }
```

#### 7. 获取最后一次下载的ID
该方法只会寻找当前应用版本名和版本号下下载过的ID
```dart
    void getLastUpgradeId() async {
     int id = await RUpgrade.getLastUpgradedId();
    }
```

#### 8. 获取ID对应的下载状态
```dart
    void getDownloadStatus()async{
    DownloadStatus status = await RUpgrade.getDownloadStatus(id);
   }
```

#### 9. 增量升级
- 1.下载[bsdiff](https://github.com/rhymelph/r_upgrade/releases/download/v0.3.0/bsdiff)工具到本地
- 2.准备两个安装包，一个是即将需要升级的安装包(old.apk)、一个是你需要更新的安装包（new.apk）
- 3.在命令行切换到上面下载的`bsdiff`目录下，运行命令`./bsdiff old.apk new.apk increment.patch`
- 4.将上面生成的`increment.patch`上传到服务器
- 5.调用`RUpgrade.upgrade（...,upgradeFlavor:RUpgradeFlavor.incrementUpgrade）`方法进行下载，即可
- 6.调用`RUpgrade.install(id)`进行安装

代码如下：
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
                .showSnackBar(SnackBar(content: Text('增量更新失败!')));
        }
    }
```

#### 10. 热更新
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
    - 调用`RUpgrade.upgrade（...,upgradeFlavor:RUpgradeFlavor.hotUpgrade）`方法进行下载
    - 下载完成后，将上面获取到的id进行热更新,调用如下代码

```dart
           bool isSuccess = await RUpgrade.install(id);
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

> 注意：目前热更新尚处于测试阶段，只支持Flutter代码的变更，不支持资源文件等，热更新造成的一切的后果插件的作者概不负责，由使用者承担。


## 安卓平台通知栏

如果你想自定义通知栏显示的内容, 可以这样做, 修改或添加文件路径为`project/android/app/main/res/values/r_upgrade_value.xml`，添加下面代码
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="r_upgrade_download_speech">%.2fkb/s</string>
    <string name="r_upgrade_download_planTime">预计%.0f秒后完成</string>
    <string name="r_upgrade_download_finish">下载完成</string>
    <string name="r_upgrade_download_paused">下载被暂停</string>
    <string name="r_upgrade_download_failed">下载失败</string>
</resources>
```
然后.当你使用`upgrade`方法时,你应该设置参数`notificationStyle`，默认为显示预计完成时间.
```dart
/// Notification show style about content text
enum NotificationStyle {
  speechAndPlanTime, // 100kb/s 预计1秒后完成
  planTimeAndSpeech, // 预计1秒后完成 100kb/s
  speech,// 100kb/s
  planTime, // 预计1秒后完成
  none, //
}
```

## IOS平台

### 1.跳转到AppStore进行更新
```dart
    void upgradeFromAppStore() async {
        bool isSuccess =await RUpgrade.upgradeFromAppStore(
                '您的AppId',//例如:微信的AppId:414478124
              );
        print(isSuccess);
    }
```

### 2.获取AppStore中你的应用最后的版本名
```dart
    void getVersionFromAppStore() async {
        String versionName = await RUpgrade.getVersionFromAppStore(
                '您的AppId',//例如:微信的AppId:414478124
               );
        print(versionName);
    }
```
