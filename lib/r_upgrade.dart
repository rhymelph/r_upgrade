// Copyright 2019 The rhyme_lph Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class RUpgrade {
  static const MethodChannel _methodChannel =
      const MethodChannel('com.rhyme/r_upgrade_method');
  static const EventChannel _eventChannel =
      const EventChannel('com.rhyme/r_upgrade_event');

  ///
  /// Download info stream . this will listen your upgrade progress and more info.
  ///
  static Stream<DownloadInfo> get stream {
    assert(Platform.isAndroid, 'This method only support android application');
    return _eventChannel
        .receiveBroadcastStream()
        .map((map) => DownloadInfo.formMap(map));
  }

  ///
  /// You can use this method upgrade your android application.If your application is ios. Oh,so sorry...
  ///
  /// * [url] download url.
  /// * [header] download  request header.
  /// * [apkName] download  filename and notification title name.
  /// * [notificationVisibility] download running notification visibility mode.
  /// * [isAutoRequestInstall] download completed will install apk.
  static Future<int> upgrade(
    String url, {
    Map<String, String> header,
    String apkName,
    NotificationVisibility notificationVisibility =
        NotificationVisibility.VISIBILITY_VISIBLE_NOTIFY_COMPLETED,
    bool isAutoRequestInstall = true,
  }) {
    assert(Platform.isAndroid, 'This method only support android application');
    return _methodChannel.invokeMethod('upgrade', {
      'url': url,
      "header": header,
      "apkName": apkName,
      "notificationVisibility": notificationVisibility.value,
      "isAutoRequestInstall": isAutoRequestInstall,
    });
  }

  /// if your application is ios ,
  static Future<void> upgradeFromAppStore(String url) async {
    assert(Platform.isIOS, 'This method only support ios application');
    await _methodChannel.invokeMethod("upgradeFromAppStore", {
      'url': url,
    });
  }

  ///
  /// Cancel by the [id] download task .
  static Future<bool> cancel(int id) {
    assert(Platform.isAndroid, 'This method only support android application');
    return _methodChannel.invokeMethod('cancel', {
      'id': id,
    });
  }

  ///
  /// Install your apk by [id].
  ///
  static Future<bool> install(int id) async {
    assert(Platform.isAndroid, 'This method only support android application');
    return await _methodChannel.invokeMethod("install", {
      'id': id,
    });
  }

  ///
  /// hot upgrade your apk by [id].
  ///
  static Future<bool> hotUpgrade(int id) async {
    assert(Platform.isAndroid, 'This method only support android application');
    return await _methodChannel.invokeMethod("hotUpgrade", {
      'id': id,
    });
  }
}

///
/// A model class is download info
///
/// * [total] download total bytes
/// * [status] download status . you can watch [DownloadStatus]
/// * [progress] download progress bytes
/// * [planTime] download plan time /s
/// * [address] download file address
/// * [percent] download percent 0-100
/// * [id] download id
/// * [speed] download speed kb/s
///
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

///
/// A model class is download status
///
/// * [STATUS_PAUSED] download paused
/// * [STATUS_PENDING] download pending
/// * [STATUS_RUNNING] download running
/// * [STATUS_SUCCESSFUL] download successful
/// * [STATUS_FAILED] download failed
///
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

///
/// A model class is Notification Visibility
///
/// * [VISIBILITY_VISIBLE] This download is visible but only shows in the notifications
/// * [VISIBILITY_VISIBLE_NOTIFY_COMPLETED] This download is visible and shows in the notifications while
/// * [VISIBILITY_HIDDEN] This download doesn't show in the UI or in the notifications.
/// * [VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION] This download shows in the notifications after completion ONLY.
///
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
  ///
  static const VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION =
      const NotificationVisibility._internal(3);
}
