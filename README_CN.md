# r_upgrade
[![pub package](https://img.shields.io/pub/v/r_upgrade.svg)](https://pub.dartlang.org/packages/r_upgrade)

Android和IOS的升级应用插件==Flutter应用升级插件

## 开始吧
- 使用插件:

在`pubspec.yaml`文件添加下面代码
```yaml
dependencies:
  r_upgrade: last version
```
- 添加升级监听
```dart
RUpgrade.stream.listen((info){
  ///...
});
```
info 里面包含的信息如下:

`total` 应用总大小,bytes值

`status` 应用的下载状态：

    `STATUS_PAUSED`下载被暂停
    
    `STATUS_PENDING`等待下载
    
    `STATUS_RUNNING`下载中
    
    `STATUS_SUCCESSFUL`下载成功
    
    `STATUS_FAILED`下载失败
    
`progress` 已下载的大小bytes值

`planTime` 计划下载完成所需时间/秒

`address` 下载到本地的地址路径

`percent` 下载进度 范围`0-100`

`id` 当前下载任务的id

`speed` 当前下载速度kb/s

-  立即升级你的应用
```dart
    void upgrade() async {
      int id = await RUpgrade.upgrade(
                 'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
                 apkName: 'app-release.apk');
    }
```
- 你可以使用升级返回的`id`进行取消下载
```dart
    void cancel() async {
      bool isSuccess=await RUpgrade.cancel(id);
    }
```
- 你可以使用升级返回的`id`进行安装
```dart
    void install() async {
      bool isSuccess=await RUpgrade.install(id);
    }
```
- 如果你的应用为IOS，使用此方法跳转到appStore进行下载更新
```dart
    void iosUpgrade(String url)async{
      RUpgrade.appStore(url);
    }
```
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

