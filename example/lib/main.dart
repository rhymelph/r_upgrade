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
  bool isAutoRequestInstall = true;

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
                'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
              );
            },
          ),
        ],
      );

  Widget _buildAndroidPlatformWidget() => ListView(
        children: <Widget>[
          _buildDownloadWindow(),
          ListTile(
            title: Text('开始全量更新'),
            onTap: () async {
              if(isClickHotUpgrade != null){
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('已开始下载')));
                return;
              }
              isClickHotUpgrade = false;

              if (!await canReadStorage()) return;

              id = await RUpgrade.upgrade(
                  'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.zip',
                  apkName: 'patch.zip',
                  isAutoRequestInstall: isAutoRequestInstall);
              setState(() {});
            },
          ),
          ListTile(
            title: Text('安装apk'),
            onTap: () async {
              if(isClickHotUpgrade = true){
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
          Divider(),
          ListTile(
            title: Text('开始热更新'),
            onTap: () async {
              if(isClickHotUpgrade != null){
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('已开始下载')));
                return;
              }
              isClickHotUpgrade = true;

              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
                  'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/patch.zip',
                  apkName: 'patch.zip',
                  isAutoRequestInstall: isAutoRequestInstall);
              setState(() {});
            },
          ),
          ListTile(
            title: Text('进行热更新'),
            onTap: () async {
              if(isClickHotUpgrade == false){
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请进行安装应用')));
                return;
              }
              if( id == null){
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('请点击开始热更新')));
                return;
              }
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
            },
          ),
          Divider(),
          ListTile(
            title: Text('取消更新'),
            onTap: () async {
              bool isSuccess = await RUpgrade.cancel(id);
              if (isSuccess) {
                _state.currentState
                    .showSnackBar(SnackBar(content: Text('取消成功')));
                id = null;
                setState(() {});
              }
              print('cancel');
            },
          ),
          Divider(),

        ],
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _state,
        appBar: AppBar(
          title: const Text('upgrade version = $version'),
        ),
        body: _buildMultiPlatformWidget(),
      ),
    );
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
                        Text('${snapshot.data.planTime.toStringAsFixed(0)}s后完成'),
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
      return "下载失败";
    } else if (status == DownloadStatus.STATUS_PAUSED) {
      return "下载暂停";
    } else if (status == DownloadStatus.STATUS_PENDING) {
      return "获取资源中";
    } else if (status == DownloadStatus.STATUS_RUNNING) {
      return "下载中";
    } else if (status == DownloadStatus.STATUS_SUCCESSFUL) {
      return "下载成功";
    } else {
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


  String getSpeech(double speech){
    String unit = 'kb/s';
    String result = speech.toStringAsFixed(2);
    if(speech > 1024*1024){
      unit ='gb/s';
      result = (speech / (1024*1024)).toStringAsFixed(2);
    }else if(speech>1024){
       unit = 'mb/s';
       result= (speech/1024).toStringAsFixed(2);

    }
    return '$result$unit';
  }
}

class CircleDownloadWidget extends StatelessWidget {
  final double progress;
  final Widget child;

  const CircleDownloadWidget({Key key, this.progress, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: CircleDownloadCustomPainter(
          Colors.grey[400],
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
