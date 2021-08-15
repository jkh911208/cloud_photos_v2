import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class SingleViewScreen extends StatelessWidget {
  final List<Widget> photos;
  final int index;
  final List<AssetEntity> asset;
  const SingleViewScreen(
      {Key? key,
      required this.photos,
      required this.index,
      required this.asset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(CupertinoIcons.back)),
          middle: Text("image"),
        ),
        backgroundColor: CupertinoColors.black,
        child: SingleViewBody(
          photos: photos,
          index: index,
          asset: asset,
        ));
  }
}

class SingleViewBody extends StatefulWidget {
  final List<Widget> photos;
  final int index;
  final List<AssetEntity> asset;
  const SingleViewBody(
      {Key? key,
      required this.photos,
      required this.index,
      required this.asset})
      : super(key: key);

  @override
  _SingleViewBodyState createState() => _SingleViewBodyState(
      asset: asset,
      photos: photos,
      index: index,
      controller: PageController(initialPage: index));
}

class _SingleViewBodyState extends State<SingleViewBody> {
  final List<AssetEntity> asset;
  PageController controller;
  int index;
  final List<Widget> photos;

  _SingleViewBodyState(
      {required this.photos,
      required this.index,
      required this.controller,
      required this.asset});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        controller: controller,
        itemCount: asset.length,
        itemBuilder: (context, position) {
          return buildItem(position);
        });
  }

  Widget buildItem(position) {
    return FutureBuilder(
        future: asset[position].originBytes,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data);
          }
          return CircularProgressIndicator();
        });
  }
}
