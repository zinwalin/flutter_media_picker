import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_media_picker/flutter_media_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_media_picker/flutter_media_picker.dart';
import 'package:flutter_media_picker/data/asset_media_file.dart';
import 'my_player.dart';
import 'package:flustars/flustars.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List assets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('资源选择器'),
      ),
      body: Container(
        child: ListView(
          children: [
            InkWell(
              onTap: () async {
                List list = await AssetPickers.getAssets();
                setState(() {
                  assets = list;
                });
              },
              child: Container(
                color: Color(0xfff1f1f1),
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(10),
                child: Text(
                  '选择图片',
                  style: TextStyle(color: Colors.lightGreen, fontSize: 16),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                List list = await AssetPickers.getAssets(
                    assetType: AssetsType.videoOnly);
                setState(() {
                  assets = list;
                });
              },
              child: Container(
                color: Color(0xfff1f1f1),
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(10),
                child: Text(
                  '选择视频',
                  style: TextStyle(color: Colors.lightGreen, fontSize: 16),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                List list = await AssetPickers.getAssets(
                    assetType: AssetsType.imageOrVideo);
                setState(() {
                  assets = list;
                });
              },
              child: Container(
                color: Color(0xfff1f1f1),
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(10),
                child: Text(
                  '图片或视频',
                  style: TextStyle(color: Colors.lightGreen, fontSize: 16),
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                List list = await AssetPickers.getAssets(
                    assetType: AssetsType.imageAndVideo);
                setState(() {
                  assets = list;
                });
              },
              child: Container(
                color: Color(0xfff1f1f1),
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.all(10),
                child: Text(
                  '图片和视频',
                  style: TextStyle(color: Colors.lightGreen, fontSize: 16),
                ),
              ),
            ),
            InkWell(
              child: Container(
                color: Colors.white,
                margin: EdgeInsets.all(5.0),
                child: Wrap(spacing: 0.0, children: <Widget>[
                  for (AssetMediaFile item in assets) _assetWidget(item)
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetWidget(AssetMediaFile file) {
    String filePath = file.path;
    MediaType type = file.type;

    return Container(
      height: (ScreenUtil.getScreenW(context) - 30) / 3,
      width: (ScreenUtil.getScreenW(context) - 30) / 3,
      margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0),
      decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.all(Radius.circular(1))),
      child: Container(
        child: (type == MediaType.IMAGE)
            ? Image.file(
                File(filePath),
                fit: BoxFit.cover,
              )
            : MyPlayer(
                file: File(filePath),
              ),
      ),
    );
  }
}
