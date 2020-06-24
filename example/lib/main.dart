import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

//import 'package:permission_handler/permission_handler.dart';
import 'package:r_upgrade/r_upgrade.dart';

const version = 1;

void main() => runApp(MyApp());

enum UpgradeMethod {
  all,
  hot,
  increment,
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int id;
  bool isAutoRequestInstall = false;

  UpgradeMethod upgradeMethod;

  GlobalKey<ScaffoldState> _state = GlobalKey();

  String iosVersion = "";

  @override
  void initState() {
    super.initState();
    RUpgrade.setDebug(true);
  }

  Widget _buildMultiPlatformWidget() {
    if (Platform.isAndroid) {
      return _buildAndroidPlatformWidget();
    } else if (Platform.isIOS) {
      return _buildIOSPlatformWidget();
    } else {
      return Container(
        child: Text('Sorry, your platform is not support'),
      );
    }
  }

  Widget _buildIOSPlatformWidget() => ListView(
        children: <Widget>[
          ListTile(
            title: Text('Go to url(WeChat)'),
            onTap: () async {
              RUpgrade.upgradeFromUrl(
                'https://apps.apple.com/cn/app/wechat/id414478124?l=en',
              );
            },
          ),
          ListTile(
            title: Text('Go to appStore from appId(WeChat)'),
            onTap: () async {
              RUpgrade.upgradeFromAppStore(
                '414478124',
              );
            },
          ),
          ListTile(
            title: Text('get version from app store(WeChat)'),
            trailing: iosVersion != null
                ? Text(iosVersion,
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Colors.grey,
                        ))
                : null,
            onTap: () async {
              String versionName =
                  await RUpgrade.getVersionFromAppStore('414478124');
              setState(() {
                iosVersion = versionName;
              });
            },
          ),
        ],
      );

  Widget _buildAndroidPlatformWidget() => ListView(
        children: <Widget>[
          _buildDownloadWindow(),
          Divider(),
          ListTile(
            title: Text(
              '更新相关',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text('跳转到应用商店'),
            onTap: () async {
              bool isSuccess =
                  await RUpgrade.upgradeFromAndroidStore(AndroidStore.BAIDU);
              print('${isSuccess ? '跳转成功' : '跳转失败'}');
            },
          ),
          ListTile(
            title: Text('跳转到链接更新'),
            onTap: () async {
              bool isSuccess = await RUpgrade.upgradeFromUrl(
                'https://www.baidu.com',
              );
              print(isSuccess);
            },
          ),
          ListTile(
            title: Text('开始全量更新'),
            onTap: () async {
              if (upgradeMethod != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }

//              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
//                "http://192.168.1.105:8888/files/static/kuan.apk",
//                  'http://dl-cdn.coolapkmarket.com/down/apk_file/2020/0308/Coolapk-v10.0.3-2003081-coolapk-app-release.apk?_upt=b210caeb1585012557',
                  'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.apk',
                  fileName: 'r_upgrade.apk',
                  isAutoRequestInstall: isAutoRequestInstall,
                  notificationStyle: NotificationStyle.speechAndPlanTime,
                  useDownloadManager: false);
              upgradeMethod = UpgradeMethod.all;
              setState(() {});
            },
          ),
          ListTile(
            title: Text('安装全量更新'),
            onTap: () async {
              if (upgradeMethod != UpgradeMethod.all && upgradeMethod != null) {
                _state.currentState.showSnackBar(
                    SnackBar(content: Text('请进行${getUpgradeMethodName()}')));
                return;
              }
              if (id == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('当前没有ID可安装')));
                return;
              }
              final status = await RUpgrade.getDownloadStatus(id);

              if (status == DownloadStatus.STATUS_SUCCESSFUL) {
                bool isSuccess = await RUpgrade.install(id);
                if (isSuccess) {
                  _state.currentState
                      .showSnackBar(SnackBar(content: Text('请求成功')));
                }
              } else {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('当前ID未完成下载')));
              }
            },
          ),
          CheckboxListTile(
            value: isAutoRequestInstall,
            onChanged: (bool value) {
              setState(() {
                isAutoRequestInstall = value;
              });
            },
            title: Text('下载完进行安装'),
          ),
          ListTile(
            title: Text('继续更新'),
            onTap: () async {
              if (id == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('当前没有ID可升级')));
                return;
              }
              if (upgradeMethod != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
              await RUpgrade.upgradeWithId(id);
              setState(() {});
            },
          ),
          ListTile(
            title: Text('暂停更新'),
            onTap: () async {
              bool isSuccess = await RUpgrade.pause(id);
              if (isSuccess) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('暂停成功')));
                setState(() {});
              }
              print('cancel');
            },
          ),
          ListTile(
            title: Text('取消更新'),
            onTap: () async {
              bool isSuccess = await RUpgrade.cancel(id);
              if (isSuccess) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('取消成功')));
                id = null;
                upgradeMethod = null;
                setState(() {});
              }
              print('cancel');
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              '热更新相关',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text('开始下载热更新'),
            onTap: () async {
              if (upgradeMethod != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
//              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
                  'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.zip',
                  fileName: 'r_upgrade.zip',
                  useDownloadManager: false,
                  isAutoRequestInstall: false,
                  upgradeFlavor: RUpgradeFlavor.hotUpgrade);
              upgradeMethod = UpgradeMethod.hot;
              setState(() {});
            },
          ),
          ListTile(
            title: Text('进行热更新'),
            onTap: () async {
//              if (!await canReadStorage()) return;
              if (upgradeMethod != UpgradeMethod.hot && upgradeMethod != null) {
                _state.currentState.showSnackBar(
                    SnackBar(content: Text('请进行${getUpgradeMethodName()}')));
                return;
              }
              if (id == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请点击开始热更新')));
                return;
              }
//              bool isSuccess = await RUpgrade.hotUpgrade(id);
              final status = await RUpgrade.getDownloadStatus(id);

              if (status == DownloadStatus.STATUS_SUCCESSFUL) {
                bool isSuccess = await RUpgrade.install(id);
                if (isSuccess) {
                  _state.currentState.showSnackBar(
                      SnackBar(content: Text('热更新成功，3s后退出应用，请重新进入')));
                  Future.delayed(Duration(seconds: 3)).then((_) {
                    SystemNavigator.pop(animated: true);
                  });
                } else {
                  _state.currentState.showSnackBar(
                      SnackBar(content: Text('热更新失败，请等待更新包下载完成')));
                }
              } else {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('当前ID未完成下载')));
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              '增量更新',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text('开始下载增量更新'),
            onTap: () async {
              if (upgradeMethod != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
//              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
                'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.patch',
                fileName: 'r_upgrade.patch',
                useDownloadManager: false,
                isAutoRequestInstall: false,
                upgradeFlavor: RUpgradeFlavor.incrementUpgrade,
              );
              upgradeMethod = UpgradeMethod.increment;
              setState(() {});
            },
          ),
          ListTile(
            title: Text('进行增量更新'),
            onTap: () async {
//              if (!await canReadStorage()) return;
              if (upgradeMethod != UpgradeMethod.increment &&
                  upgradeMethod != null) {
                _state.currentState.showSnackBar(
                    SnackBar(content: Text('请进行${getUpgradeMethodName()}}')));
                return;
              }
              if (id == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请点击开始增量更新')));
                return;
              }
              try {
                final status = await RUpgrade.getDownloadStatus(id);
                if (status == DownloadStatus.STATUS_SUCCESSFUL) {
                  await RUpgrade.install(id);
                } else {
                  _state.currentState
                      .showSnackBar(SnackBar(content: Text('当前ID未完成下载')));
                }
              } catch (e) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('增量更新失败!')));
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              '历史相关',
              style: Theme.of(context).textTheme.title.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text('获取最后一次下载的ID'),
            trailing: lastId != null
                ? Text(
                    lastId.toString(),
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Colors.grey,
                        ),
                  )
                : null,
            onTap: () async {
              lastId = await RUpgrade.getLastUpgradedId();
              if (lastId == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('没有最后一次下载的ID')));
                return;
              }
              setState(() {});
            },
          ),
          ListTile(
            title: Text('根据最后一次ID升级应用'),
            onTap: () async {
              if (lastId == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('当前没有ID可升级')));
                return;
              }
              await RUpgrade.upgradeWithId(lastId);
              setState(() {});
            },
          ),
          ListTile(
            title: Text(
              '查看最后一次ID的下载状态',
            ),
            trailing: lastStatus != null
                ? Text(getStatus(lastStatus),
                    style: Theme.of(context).textTheme.subtitle2.copyWith(
                          color: Colors.grey,
                        ))
                : null,
            onTap: () async {
              if (lastId == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('当前没有ID可查')));
                return;
              }
              lastStatus = await RUpgrade.getDownloadStatus(lastId);
              setState(() {});
            },
          ),
          Divider(),
        ],
      );

  int lastId;

  DownloadStatus lastStatus;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _state,
        appBar: AppBar(
          backgroundColor: getVersionColor(),
          title: Text(_getAppBarText()),
        ),
        body: _buildMultiPlatformWidget(),
      ),
    );
  }

  Color getVersionColor() {
    switch (version) {
      case 1:
        return Theme.of(context).primaryColor;
      case 2:
        return Colors.black;
      case 3:
        return Colors.red;
      case 4:
        return Colors.orange;
    }
    return Theme.of(context).primaryColor;
  }

  String _getAppBarText() {
    switch (version) {
      case 1:
        return 'Normal version = $version ${id != null ? 'id = $id' : ''}';
      case 2:
        return 'hot upgrade version = $version ${id != null ? 'id = $id' : ''}';
      case 3:
        return 'all upgrade version = $version ${id != null ? 'id = $id' : ''}';
      case 4:
        return 'plus upgrade version = $version ${id != null ? 'id = $id' : ''}';
    }
    return 'unknow version  = $version ${id != null ? 'id = $id' : ''}';
  }

  Widget _buildDownloadWindow() => Container(
        height: 250,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: id != null
            ? StreamBuilder(
                stream: RUpgrade.stream,
                builder: (BuildContext context,
                    AsyncSnapshot<DownloadInfo> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 150,
                          width: 150,
                          child: CircleDownloadWidget(
                            backgroundColor: snapshot.data.status ==
                                    DownloadStatus.STATUS_SUCCESSFUL
                                ? Colors.green
                                : null,
                            progress: snapshot.data.percent / 100,
                            child: Center(
                              child: Text(
                                snapshot.data.status ==
                                        DownloadStatus.STATUS_RUNNING
                                    ? getSpeech(snapshot.data.speed)
                                    : getStatus(snapshot.data.status),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                            '${snapshot.data.planTime.toStringAsFixed(0)}s后完成'),
                      ],
                    );
                  } else {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    );
                  }
                },
              )
            : Text('等待下载'),
      );

  String getStatus(DownloadStatus status) {
    if (status == DownloadStatus.STATUS_FAILED) {
      id = null;
      upgradeMethod = null;
      return "下载失败";
    } else if (status == DownloadStatus.STATUS_PAUSED) {
      return "下载暂停";
    } else if (status == DownloadStatus.STATUS_PENDING) {
      return "获取资源中";
    } else if (status == DownloadStatus.STATUS_RUNNING) {
      return "下载中";
    } else if (status == DownloadStatus.STATUS_SUCCESSFUL) {
      return "下载成功";
    } else if (status == DownloadStatus.STATUS_CANCEL) {
      id = null;
      upgradeMethod = null;
      return "下载取消";
    } else {
      id = null;
      upgradeMethod = null;
      return "未知";
    }
  }

  String getUpgradeMethod() {
    switch (upgradeMethod) {
      case UpgradeMethod.all:
        return '已经开始全量更新';
        break;
      case UpgradeMethod.hot:
        return '已经开始热更新';
        break;
      case UpgradeMethod.increment:
        return '已经开始增量更新';
        break;
    }
    return '';
  }

  String getUpgradeMethodName() {
    switch (upgradeMethod) {
      case UpgradeMethod.all:
        return '全量更新';
        break;
      case UpgradeMethod.hot:
        return '热更新';
        break;
      case UpgradeMethod.increment:
        return '增量更新';
        break;
    }
    return '';
  }
//  Future<bool> canReadStorage() async {
//    if (Platform.isIOS) return true;
//    var status = await PermissionHandler()
//        .checkPermissionStatus(PermissionGroup.storage);
//    if (status != PermissionStatus.granted) {
//      var future = await PermissionHandler()
//          .requestPermissions([PermissionGroup.storage]);
//      for (final item in future.entries) {
//        if (item.value != PermissionStatus.granted) {
//          return false;
//        }
//      }
//    } else {
//      return true;
//    }
//    return true;
//  }

  String getSpeech(double speech) {
    String unit = 'kb/s';
    String result = speech.toStringAsFixed(2);
    if (speech > 1024 * 1024) {
      unit = 'gb/s';
      result = (speech / (1024 * 1024)).toStringAsFixed(2);
    } else if (speech > 1024) {
      unit = 'mb/s';
      result = (speech / 1024).toStringAsFixed(2);
    }
    return '$result$unit';
  }
}

class CircleDownloadWidget extends StatelessWidget {
  final double progress;
  final Widget child;
  final Color backgroundColor;

  const CircleDownloadWidget(
      {Key key, this.progress, this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CircleDownloadCustomPainter(
          backgroundColor ?? Colors.grey[400],
          Theme.of(context).primaryColor,
          progress,
        ),
        child: child,
      ),
    );
  }
}

class CircleDownloadCustomPainter extends CustomPainter {
  final Color backgroundColor;
  final Color color;
  final double progress;

  Paint mPaint;

  CircleDownloadCustomPainter(this.backgroundColor, this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (mPaint == null) mPaint = Paint();
    double width = size.width;
    double height = size.height;

    Rect progressRect =
        Rect.fromLTRB(0, height * (1 - progress), width, height);
    Rect widgetRect = Rect.fromLTWH(0, 0, width, height);
    canvas.clipPath(Path()..addOval(widgetRect));

    canvas.drawRect(widgetRect, mPaint..color = backgroundColor);
    canvas.drawRect(progressRect, mPaint..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
