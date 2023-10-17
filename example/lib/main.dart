import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:r_upgrade/r_upgrade.dart';
import 'generated/l10n.dart';

const version = 1;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Application());
}

enum UpgradeMethod {
  all,
  hot,
  increment,
}

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: getVersionColor(),
          title: Text(_getAppBarText()),
        ),
        body: MyApp(),
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
        return 'Normal version = $version ';
      case 2:
        return 'hot upgrade version = $version';
      case 3:
        return 'all upgrade version = $version';
      case 4:
        return 'plus upgrade version = $version ';
    }
    return 'unknow version  = $version';
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? id;
  RUpgradeInstallType installType = RUpgradeInstallType.normal;
  NotificationVisibility notificationVisibility =
      NotificationVisibility.VISIBILITY_VISIBLE;
  NotificationStyle notificationStyle = NotificationStyle.planTime;
  UpgradeMethod? upgradeMethod;

  String? iosVersion = "";
  String? androidVersion = "";

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
                ? Text(iosVersion!,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.grey,
                        ))
                : null,
            onTap: () async {
              String? versionName =
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
              S.of(context).Notification_Related,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text(
              S.of(context).Notification_Visibility,
            ),
            trailing: DropdownButton<NotificationVisibility>(
              items: [
                DropdownMenuItem(
                  child: Text(S.of(context).Notification_Visibility_Visible),
                  value: NotificationVisibility.VISIBILITY_VISIBLE,
                ),
                DropdownMenuItem(
                  child: Text(S
                      .of(context)
                      .Notification_Visibility_Visible_Notify_Completed),
                  value: NotificationVisibility
                      .VISIBILITY_VISIBLE_NOTIFY_COMPLETED,
                ),
                DropdownMenuItem(
                  child: Text(S.of(context).Notification_Visibility_Hidden),
                  value: NotificationVisibility.VISIBILITY_HIDDEN,
                ),
                DropdownMenuItem(
                  child: Text(S
                      .of(context)
                      .Notification_Visibility_Visible_Notify_Only_Completion),
                  value: NotificationVisibility
                      .VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION,
                ),
              ],
              value: notificationVisibility,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  notificationVisibility = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text(
              S.of(context).Notification_Style,
            ),
            trailing: DropdownButton<NotificationStyle>(
              items: [
                DropdownMenuItem(
                  child: Text(S.of(context).Notification_Style_PlanTime),
                  value: NotificationStyle.planTime,
                ),
                DropdownMenuItem(
                  child: Text(S.of(context).Notification_Style_PlanTime_Speech),
                  value: NotificationStyle.planTimeAndSpeech,
                ),
                DropdownMenuItem(
                  child: Text(S.of(context).Notification_Style_Speech_PlanTime),
                  value: NotificationStyle.speechAndPlanTime,
                ),
                DropdownMenuItem(
                  child: Text(S.of(context).Notification_Style_Speech),
                  value: NotificationStyle.speech,
                ),
                DropdownMenuItem(
                  child: Text(S.of(context).Notification_Style_None),
                  value: NotificationStyle.none,
                ),
              ],
              value: notificationStyle,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  notificationStyle = value;
                });
              },
            ),
          ),
          ListTile(
            title: Text(
              S.of(context).Install_Related,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text(
              S.of(context).Install_Type,
            ),
            trailing: DropdownButton<RUpgradeInstallType>(
              items: [
                DropdownMenuItem(
                  child: Text(S.of(context).Install_Type_Normal),
                  value: RUpgradeInstallType.normal,
                ),
                DropdownMenuItem(
                  child: Text(S.of(context).Install_Type_Silent),
                  value: RUpgradeInstallType.silent,
                ),
                DropdownMenuItem(
                  child: Text(S.of(context).Install_Type_None),
                  value: RUpgradeInstallType.none,
                ),
              ],
              value: installType,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  installType = value;
                });
              },
            ),
          ),
          if (installType == RUpgradeInstallType.silent)
            ListTile(
              title: Text(
                S.of(context).Install_Type_Silent_Tip,
                style: Theme.of(context).textTheme.subtitle2?.copyWith(
                      color: Theme.of(context).errorColor,
                    ),
              ),
            ),
          ListTile(
            title: Text(
              S.of(context).Update_the_related,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text(S.of(context).Jump_to_the_app_store),
            onTap: () async {
              bool? isSuccess =
                  await RUpgrade.upgradeFromAndroidStore(AndroidStore.BAIDU);
              print('${(isSuccess != null && isSuccess) ? '跳转成功' : '跳转失败'}');
            },
          ),
          ListTile(
            title: Text(S.of(context).getAndroidStore),
            onTap: () async {
              final stores = await RUpgrade.androidStores;
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("获取成功，请查看控制台")));
              print(stores.toString());
            },
          ),
          ListTile(
            title: Text(S.of(context).getVersionFromAndroidStore),
            onTap: () async {
              setState(() {
                androidVersion = "获取中...";
              });
              String? versionName;
              try {
                versionName = await RUpgrade.getVersionFromAndroidStore(
                    AndroidStore.TENCENT);
              } catch (e) {
                print(e);
              }
              setState(() {
                if (versionName == null || versionName.isEmpty) {
                  androidVersion = "获取失败";
                } else {
                  androidVersion = versionName;
                }
              });
              print('store version:$versionName');
            },
            trailing: androidVersion != null
                ? Text(androidVersion!,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.grey,
                        ))
                : null,
          ),
          ListTile(
            title: Text(S.of(context).Jump_to_the_link_updated),
            onTap: () async {
              bool? isSuccess = await RUpgrade.upgradeFromUrl(
                'https://www.baidu.com',
              );
              print(isSuccess);
            },
          ),
          ListTile(
            title: Text(S.of(context).Starting_to_all_updates),
            onTap: () async {
              if (upgradeMethod != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
//              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
//                "http://192.168.1.105:8888/files/static/kuan.apk",
//                  'http://dl-cdn.coolapkmarket.com/down/apk_file/2020/0308/Coolapk-v10.0.3-2003081-coolapk-app-release.apk?_upt=b210caeb1585012557',
                  'https://dl.coolapk.com/down?pn=com.coolapk.market&id=NDU5OQ&h=46bb9d98&from=from-web',
                  fileName: 'r_upgrade.apk',
                  installType: installType,
                  notificationStyle: notificationStyle,
                  notificationVisibility: notificationVisibility,
                  useDownloadManager: false);
              upgradeMethod = UpgradeMethod.all;
              setState(() {});
            },
          ),
          ListTile(
            title: Text(S.of(context).Install_all_updates),
            onTap: () async {
              if (upgradeMethod != UpgradeMethod.all && upgradeMethod != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S
                        .of(context)
                        .Please_make_('${getUpgradeMethodName()}'))));
                return;
              }
              if (id == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S
                        .of(context)
                        .Currently_there_is_no_ID_can_be_installed)));
                return;
              }
              final status = await RUpgrade.getDownloadStatus(id!);

              if (status == DownloadStatus.STATUS_SUCCESSFUL) {
                bool? isSuccess =
                    await RUpgrade.install(id!, installType: installType);
                if (isSuccess != null && isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S.of(context).The_request_is_successful)));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.of(context).The_current_ID_not_download)));
              }
            },
          ),
          ListTile(
            title: Text(S.of(context).Continue_to_update),
            onTap: () async {
              if (id == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S
                        .of(context)
                        .Currently_there_is_no_ID_can_be_upgraded)));
                return;
              }
              if (upgradeMethod != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
              await RUpgrade.upgradeWithId(id!);
              setState(() {});
            },
          ),
          ListTile(
            title: Text(S.of(context).updated),
            onTap: () async {
              bool? isSuccess = await RUpgrade.pause(id!);
              if (isSuccess != null && isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.of(context).Suspension_of_success)));
                setState(() {});
              }
              print('cancel');
            },
          ),
          ListTile(
            title: Text(S.of(context).Cancel_the_update),
            onTap: () async {
              bool? isSuccess = await RUpgrade.cancel(id!);
              if (isSuccess != null && isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).Cancel_the_success)));
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
              S.of(context).Hot_update_related,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text(S.of(context).Start_download_hot_update),
            onTap: () async {
              if (upgradeMethod != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
//              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
                  'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.zip',
                  fileName: 'r_upgrade.zip',
                  useDownloadManager: false,
                  installType: installType,
                  upgradeFlavor: RUpgradeFlavor.hotUpgrade,
                  notificationStyle: notificationStyle,
                  notificationVisibility: notificationVisibility);
              upgradeMethod = UpgradeMethod.hot;
              setState(() {});
            },
          ),
          ListTile(
            title: Text(S.of(context).For_hot_update),
            onTap: () async {
//              if (!await canReadStorage()) return;
              if (upgradeMethod != UpgradeMethod.hot && upgradeMethod != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S
                        .of(context)
                        .Please_make_('${getUpgradeMethodName()}'))));
                return;
              }
              if (id == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(S.of(context).Please_click_on_start_hot_update)));
                return;
              }
//              bool isSuccess = await RUpgrade.hotUpgrade(id);
              final status = await RUpgrade.getDownloadStatus(id!);

              if (status == DownloadStatus.STATUS_SUCCESSFUL) {
                bool? isSuccess =
                    await RUpgrade.install(id!, installType: installType);
                if (isSuccess != null && isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S
                          .of(context)
                          .Hot_update_is_successful_exit_the_application_after_3_s_please_re_enter)));
                  Future.delayed(Duration(seconds: 3)).then((_) {
                    SystemNavigator.pop(animated: true);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(S
                          .of(context)
                          .Hot_update_failed_please_wait_for_update_the_download_is_complete)));
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.of(context).The_current_ID_not_download)));
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              S.of(context).Incremental_updating,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title:
                Text(S.of(context).Began_to_download_the_incremental_updating),
            onTap: () async {
              if (upgradeMethod != null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(getUpgradeMethod())));
                return;
              }
//              if (!await canReadStorage()) return;
              id = await RUpgrade.upgrade(
                'https://mydata-1252536312.cos.ap-guangzhou.myqcloud.com/r_upgrade.patch',
                fileName: 'r_upgrade.patch',
                useDownloadManager: false,
                installType: installType,
                notificationVisibility: notificationVisibility,
                notificationStyle: notificationStyle,
                upgradeFlavor: RUpgradeFlavor.incrementUpgrade,
              );
              upgradeMethod = UpgradeMethod.increment;
              setState(() {});
            },
          ),
          ListTile(
            title: Text(S.of(context).Incremental_updating),
            onTap: () async {
//              if (!await canReadStorage()) return;
              if (upgradeMethod != UpgradeMethod.increment &&
                  upgradeMethod != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S
                        .of(context)
                        .Please_make_('${getUpgradeMethodName()}'))));
                return;
              }
              if (id == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S
                        .of(context)
                        .Please_click_on_start_incremental_updates)));
                return;
              }
              try {
                final status = await RUpgrade.getDownloadStatus(id!);
                if (status == DownloadStatus.STATUS_SUCCESSFUL) {
                  await RUpgrade.install(id!, installType: installType);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(S.of(context).The_current_ID_not_download)));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.of(context).Incremental_updating_failed)));
              }
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              S.of(context).History_related,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            title: Text(S.of(context).For_the_last_time_to_download_the_ID),
            trailing: lastId != null
                ? Text(
                    lastId.toString(),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.grey,
                        ),
                  )
                : null,
            onTap: () async {
              lastId = await RUpgrade.getLastUpgradedId();
              if (lastId == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.of(context).No_ID_last_time_to_download)));
                return;
              }
              setState(() {});
            },
          ),
          ListTile(
            title: Text(S
                .of(context)
                .According_to_the_last_time_ID_escalation_applications),
            onTap: () async {
              if (lastId == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S
                        .of(context)
                        .Currently_there_is_no_ID_can_be_upgraded)));
                return;
              }
              await RUpgrade.upgradeWithId(lastId!);
              setState(() {});
            },
          ),
          ListTile(
            title: Text(
              S.of(context).Look_at_the_last_time_ID_download_status,
            ),
            trailing: lastStatus != null
                ? Text(getStatus(lastStatus),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Colors.grey,
                        ))
                : null,
            onTap: () async {
              if (lastId == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(S.of(context).Currently_there_is_no_ID)));
                return;
              }
              lastStatus = await RUpgrade.getDownloadStatus(lastId!);
              setState(() {});
            },
          ),
          Divider(),
        ],
      );

  int? lastId;

  DownloadStatus? lastStatus;

  @override
  Widget build(BuildContext context) {
    return _buildMultiPlatformWidget();
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
                            backgroundColor: snapshot.data!.status ==
                                    DownloadStatus.STATUS_SUCCESSFUL
                                ? Colors.green
                                : null,
                            progress: snapshot.data!.percent! / 100,
                            child: Center(
                              child: Text(
                                snapshot.data!.status ==
                                        DownloadStatus.STATUS_RUNNING
                                    ? snapshot.data!.getSpeedString()
                                    : getStatus(snapshot.data!.status),
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
                        Text(S.of(context).The_s_after_finish(
                            '${snapshot.data!.planTime!.toStringAsFixed(0)}')),
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
            : Text(S.of(context).Waiting_for_download),
      );

  String getStatus(DownloadStatus? status) {
    if (status == DownloadStatus.STATUS_FAILED) {
      id = null;
      upgradeMethod = null;
      return S.of(context).Download_failed;
    } else if (status == DownloadStatus.STATUS_PAUSED) {
      return S.of(context).Download_the_suspended;
    } else if (status == DownloadStatus.STATUS_PENDING) {
      return S.of(context).Access_to_resources;
    } else if (status == DownloadStatus.STATUS_RUNNING) {
      return S.of(context).In_the_download;
    } else if (status == DownloadStatus.STATUS_SUCCESSFUL) {
      return S.of(context).Download_successful;
    } else if (status == DownloadStatus.STATUS_CANCEL) {
      id = null;
      upgradeMethod = null;
      return S.of(context).Download_the_cancel;
    } else {
      id = null;
      upgradeMethod = null;
      return S.of(context).The_unknown;
    }
  }

  String getUpgradeMethod() {
    switch (upgradeMethod) {
      case UpgradeMethod.all:
        return S.of(context).Are_already_starting_to_all_updates;
      case UpgradeMethod.hot:
        return S.of(context).Have_begun_to_hot_update;
      case UpgradeMethod.increment:
        return S.of(context).Has_already_started_to_incremental_updates;
      default:
        break;
    }
    return '';
  }

  String getUpgradeMethodName() {
    switch (upgradeMethod) {
      case UpgradeMethod.all:
        return S.of(context).Full_quantity_update;
      case UpgradeMethod.hot:
        return S.of(context).Hot_update;
      case UpgradeMethod.increment:
        return S.of(context).Incremental_updating;
      default:
        break;
    }
    return '';
  }
}

class CircleDownloadWidget extends StatelessWidget {
  final double? progress;
  final Widget? child;
  final Color? backgroundColor;

  const CircleDownloadWidget(
      {Key? key, this.progress, this.child, this.backgroundColor})
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
  final Color? backgroundColor;
  final Color color;
  final double? progress;

  Paint? mPaint;

  CircleDownloadCustomPainter(this.backgroundColor, this.color, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (mPaint == null) mPaint = Paint();
    double width = size.width;
    double height = size.height;

    Rect progressRect =
        Rect.fromLTRB(0, height * (1 - progress!), width, height);
    Rect widgetRect = Rect.fromLTWH(0, 0, width, height);
    canvas.clipPath(Path()..addOval(widgetRect));

    canvas.drawRect(widgetRect, mPaint!..color = backgroundColor!);
    canvas.drawRect(progressRect, mPaint!..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
