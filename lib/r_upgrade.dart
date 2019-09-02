import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class RUpgrade {
  static const MethodChannel _channel = const MethodChannel('r_upgrade');
  static const EventChannel _eChannel = const EventChannel('r_upgrade/e');

  //添加监听
  static Stream<DownloadInfo> addListener() => _eChannel
      .receiveBroadcastStream()
      .map((map) => DownloadInfo.formMap(map));

  /// 立即升级
  /// [url] 请求地址
  /// [header] 请求头
  /// [apkName] 在通知栏显示的头
  static Future<int> upgrade(
    String url, //请求url
    {
    Map<String, String> header, //请求头
    @required String apkName, // apk名 xxx.apk
    NotificationVisibility notificationVisibility =
        NotificationVisibility.VISIBILITY_VISIBLE_NOTIFY_COMPLETED, // 显示通知栏方式
  }) {
    return _channel.invokeMethod('upgrade', {
      'url': url,
      "header": header,
      "apkName": apkName,
      "notificationVisibility": notificationVisibility.value
    });
  }

  //取消升级
  static Future<bool> cancel(int id) {
    return _channel.invokeMethod('cancel', {
      'id': id,
    });
  }

  //安装应用
  static Future<void> install(String path) async {
    return await _channel.invokeMethod("install", {
      'path': path,
    });
  }
}

class DownloadInfo {
  final int total;
  final String address;
  final double planTime;
  final int progress;
  final double percent;
  final int id;
  final double speed;
  final DownloadStatus status;
  DownloadInfo(
      {this.total,
      this.address,
      this.planTime,
      this.progress,
      this.percent,
      this.id,
        this.status,
      this.speed});

  factory DownloadInfo.formMap(dynamic map) => DownloadInfo(
        total: map['total'],
        address: map['address'],
        planTime: map['planTime'],
        percent: map['percent'],
        id: map['id'],
        status: DownloadStatus._internal(map['status']),
        speed: map['speed'],
      );

  @override
  String toString() {
    return 'DownloadInfo{total: $total, address: $address, planTime: $planTime, progress: $progress, percent: $percent, id: $id, speed: $speed, status: $status}';
  }

}

class DownloadStatus {
  final int _value;

  int get value => _value;

  const DownloadStatus._internal(this._value);

  static DownloadStatus from(int value) => DownloadStatus._internal(value);

  static const STATUS_PAUSED = const DownloadStatus._internal(0);
  static const STATUS_PENDING = const DownloadStatus._internal(1);
  static const STATUS_RUNNING = const DownloadStatus._internal(2);
  static const STATUS_SUCCESSFUL = const DownloadStatus._internal(3);
  static const STATUS_FAILED = const DownloadStatus._internal(4);

  get hashCode => _value;

  operator ==(status) => status._value == this._value;

  toString() => 'DownloadStatus($_value)';


}

class NotificationVisibility {
  final int _value;

  const NotificationVisibility._internal(this._value);

  int get value => _value;

  get hashCode => _value;

  operator ==(status) => status._value == this._value;

  toString() => 'NotificationVisibility($_value)';

  static NotificationVisibility from(int value) =>
      NotificationVisibility._internal(value);

  /// This download is visible but only shows in the notifications
  /// while it's in progress.
  static const VISIBILITY_VISIBLE = const NotificationVisibility._internal(0);

  /// This download is visible and shows in the notifications while
  /// in progress and after completion.
  static const VISIBILITY_VISIBLE_NOTIFY_COMPLETED =
      const NotificationVisibility._internal(1);

  /// This download doesn't show in the UI or in the notifications.
  static const VISIBILITY_HIDDEN = const NotificationVisibility._internal(2);

  ///
  /// This download shows in the notifications after completion ONLY.
  /// It is usuable only with
  /// {@link DownloadManager#addCompletedDownload(String, String,
  /// boolean, String, String, long, boolean)}.
  ///
  static const VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION =
      const NotificationVisibility._internal(3);
}
