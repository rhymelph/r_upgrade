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
                padding: EdgeInsets.all(8),
                child: StreamBuilder(
                  stream: RUpgrade.addListener(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DownloadInfo> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('正在下载'),
                              Text(
                                  '${snapshot.data.planTime.toStringAsFixed(0)}s后完成'),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LinearProgressIndicator(
                                    value: snapshot.data.percent == 0
                                        ? null
                                        : snapshot.data.percent / 100,
                                  ),
                                ),
                              ),
                              Text('${snapshot.data.percent}%'),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text('${snapshot.data.speed.toStringAsFixed(2)}kb/s')
                        ],
                      );
                    } else {
                      return Text('等待下载');
                    }
                  },
                )),
            ListTile(
              title: Center(child: Text('开始更新')),
              onTap: () async {
                id = await RUpgrade.upgrade(
                    'https://raw.githubusercontent.com/rhymelph/r_upgrade/master/apk/app-release.apk',
                    apkName: '豆瓣.apk');
                setState(() {});
              },
            ),
            ListTile(
              title: Center(child: Text('取消更新')),
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
