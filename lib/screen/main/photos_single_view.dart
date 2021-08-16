import 'package:cloud_photos_v2/screen/main/single_photo.dart';
import 'package:cloud_photos_v2/screen/main/single_video.dart';
import 'package:flutter/cupertino.dart';
import 'package:photo_manager/photo_manager.dart';

class SingleViewScreen extends StatelessWidget {
  final int index;
  final List<AssetEntity> asset;
  const SingleViewScreen({Key? key, required this.index, required this.asset})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        child: SingleViewBody(
          index: index,
          asset: asset,
        ));
  }
}

class SingleViewBody extends StatefulWidget {
  final int index;
  final List<AssetEntity> asset;
  late final PageController pageController;

  SingleViewBody({Key? key, required this.index, required this.asset})
      : super(key: key) {
    pageController = PageController(initialPage: index);
  }

  @override
  _SingleViewBodyState createState() => _SingleViewBodyState();
}

class _SingleViewBodyState extends State<SingleViewBody> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SafeArea(
        child: PageView.builder(
            controller: widget.pageController,
            allowImplicitScrolling: true, // allows caching next page
            itemCount: widget.asset.length,
            itemBuilder: (_, position) {
              return customItemBuilder(position);
            }),
      ),
      customFooter()
    ]);
  }

  Widget customItemBuilder(int position) {
    return FutureBuilder(
        future: widget.asset[position].file,
        builder: (_, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            int currentPosition = position;
            print("load $currentPosition finished");
            if (widget.asset[position].type == AssetType.image) {
              return SinglePhoto(file: snapshot.data);
            } else if (widget.asset[position].type == AssetType.video) {
              return SingleVideo(file: snapshot.data);
            }
          }
          return Center(
            child: CupertinoActivityIndicator(
              animating: true,
            ),
          );
        });
  }

  Widget customFooter() {
    return Align(
      child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CupertinoButton(
                onPressed: () {},
                child: Icon(
                  CupertinoIcons.share,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () {},
                child: Icon(
                  CupertinoIcons.info_circle,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  print(widget.pageController.page);
                },
                child: Icon(
                  CupertinoIcons.trash,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              ),
              CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  CupertinoIcons.back,
                  size: 30,
                  color: CupertinoColors.white,
                ),
              )
            ],
          ),
          color: CupertinoColors.black,
          height: 60,
          width: double.infinity),
      alignment: Alignment(0, 1),
    ); 
  }
}
