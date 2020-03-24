import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_upgrade/r_upgrade.dart';

const version = 1;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int id;
  bool isAutoRequestInstall = false;

  bool isClickHotUpgrade;

  GlobalKey<ScaffoldState> _state = GlobalKey();

  @override
  void initState() {
    super.initState();
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
            title: Text('Go to app store'),
            onTap: () async {
              RUpgrade.upgradeFromAppStore(
                'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.apk',
              );
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
            title: Text('开始全量更新'),
            onTap: () async {
              if (isClickHotUpgrade != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('已开始下载')));
                return;
              }
              isClickHotUpgrade = false;

              if (!await canReadStorage()) return;

              id = await RUpgrade.upgrade(
//                "http://192.168.1.105:8888/files/static/kuan.apk",
//                  'http://dl-cdn.coolapkmarket.com/down/apk_file/2020/0308/Coolapk-v10.0.3-2003081-coolapk-app-release.apk?_upt=b210caeb1585012557',
                  'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.apk',
                  apkName: 'r_upgrade.apk',
                  isAutoRequestInstall: isAutoRequestInstall,
                  useDownloadManager: false);
              setState(() {});
            },
          ),
          ListTile(
            title: Text('安装apk'),
            onTap: () async {
              if (isClickHotUpgrade == true) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请进行热更新')));
                return;
              }
              bool isSuccess = await RUpgrade.install(id);
              if (isSuccess) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请求成功')));
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
                isClickHotUpgrade = null;
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
            title: Text('开始热更新'),
            onTap: () async {
              if (isClickHotUpgrade != null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('已开始下载')));
                return;
              }
              isClickHotUpgrade = true;

              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
                  'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.zip',
                  apkName: 'r_upgrade.zip',
                  isAutoRequestInstall: isAutoRequestInstall);
              setState(() {});
            },
          ),
          ListTile(
            title: Text('进行热更新'),
            onTap: () async {
              if (isClickHotUpgrade == false) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请进行安装应用')));
                return;
              }
              if (id == null) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请点击开始热更新')));
                return;
              }
              bool isSuccess = await RUpgrade.hotUpgrade(id);
              if (isSuccess) {
                _state.currentState.showSnackBar(
                    SnackBar(content: Text('热更新成功，3s后退出应用，请重新进入')));
                Future.delayed(Duration(seconds: 3)).then((_) {
                  SystemNavigator.pop(animated: true);
                });
              } else {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('热更新失败，请等待更新包下载完成')));
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
                    style: Theme.of(context).textTheme.subtitle.copyWith(
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
                    style: Theme.of(context).textTheme.subtitle.copyWith(
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
          backgroundColor:
              version != 1 ? Colors.black : Theme.of(context).primaryColor,
          title: Text(_getAppBarText()),
        ),
        body: _buildMultiPlatformWidget(),
      ),
    );
  }

  String _getAppBarText() {
    switch (version) {
      case 1:
        return 'Normal version = $version ${id != null ? 'id = $id' : ''}';
      case 2:
        return 'hot upgrade version = $version ${id != null ? 'id = $id' : ''}';
      case 3:
        return 'all upgrade version = $version ${id != null ? 'id = $id' : ''}';
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
      isClickHotUpgrade = null;
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
      isClickHotUpgrade = null;
      return "下载取消";
    } else {
      id = null;
      isClickHotUpgrade = null;
      return "未知";
    }
  }

  Future<bool> canReadStorage() async {
    if (Platform.isIOS) return true;
    var status = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage);
    if (status != PermissionStatus.granted) {
      var future = await PermissionHandler()
          .requestPermissions([PermissionGroup.storage]);
      for (final item in future.entries) {
        if (item.value != PermissionStatus.granted) {
          return false;
        }
      }
    } else {
      return true;
    }
    return true;
  }

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
