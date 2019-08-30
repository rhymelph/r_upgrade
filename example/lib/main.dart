import 'package:flutter/material.dart';
import 'package:r_upgrade/r_upgrade.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int id;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              height: 200,
              alignment: Alignment.center,
              child: Text('${id != null ? '正在下载id为=$id' : ''}'),
            ),
            ListTile(
              title: Text('开始更新'),
              onTap: () async {
                id = await RUpgrade.upgrade(
                    'https://raw.githubusercontent.com/rhymelph/flutter_douban/master/apk/app1.3.apk',
                    apkName: '豆瓣.apk');
                RUpgrade.addListener(id).listen((data){

                });
              },
            ),
            ListTile(
              title: Text('取消更新'),
              onTap: () async {
                bool cancel = await RUpgrade.cancel(id);
                print('cancel');
              },
            ),
          ],
        ),
      ),
    );
  }
}
