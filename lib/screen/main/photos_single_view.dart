import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  const SingleViewBody({Key? key, required this.index, required this.asset})
      : super(key: key);

  @override
  _SingleViewBodyState createState() => _SingleViewBodyState(
      asset: asset,
      index: index,
      controller: PageController(initialPage: index));
}

class _SingleViewBodyState extends State<SingleViewBody> {
  final List<AssetEntity> asset;
  PageController controller;
  int index;

  _SingleViewBodyState(
      {required this.index, required this.controller, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SafeArea(
        child: PageView.builder(
            controller: controller,
            allowImplicitScrolling: true, // allows caching next page
            onPageChanged: (int newIndex) {
              index = newIndex;
            },
            itemCount: asset.length,
            itemBuilder: (context, position) {
              return BuildItem(asset: asset, index: position);
            }),
      ),
      Align(
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
                    print(index);
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
      )
    ]);
  }
}

class BuildItem extends StatefulWidget {
  final List<AssetEntity> asset;
  final int index;
  const BuildItem({Key? key, required this.asset, required this.index})
      : super(key: key);

  @override
  _BuildItemState createState() => _BuildItemState(asset: asset, index: index);
}

class _BuildItemState extends State<BuildItem> {
  final List<AssetEntity> asset;
  int index;
  int dragDown = 0;
  bool dragCancel = false;

  _BuildItemState({required this.asset, required this.index});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: asset[index].file,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            print("load $index finished");
            if (asset[index].type == AssetType.image) {
              return GestureDetector(
                  onVerticalDragStart: (details) {
                    dragDown = 0;
                    dragCancel = false;
                  },
                  onVerticalDragUpdate: (details) {
                    if (!dragCancel && details.delta.dy > 0) {
                      dragDown += 1;
                    }
                    if (!dragCancel && details.delta.dy < 0) {
                      dragCancel = true;
                    }
                  },
                  onVerticalDragEnd: (details) {
                    if (!dragCancel && dragDown > 5) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Image.file(
                    snapshot.data,
                  ));
            } else if (asset[index].type == AssetType.video) {
              VideoPlayerController controller =
                  VideoPlayerController.file(snapshot.data);
              return VideoPlayerScreen(
                  videoFile: snapshot.data, controller: controller);
            }
          }
          return Center(
            child: CupertinoActivityIndicator(
              animating: true,
            ),
          );
        });
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen(
      {Key? key, required this.videoFile, required this.controller})
      : super(key: key);

  final File videoFile;
  final VideoPlayerController controller;

  @override
  _VideoPlayerState createState() =>
      _VideoPlayerState(videoFile: videoFile, controller: controller);
}

class _VideoPlayerState extends State<VideoPlayerScreen> {
  final File videoFile;
  VideoPlayerController controller;
  bool initialized = false;
  bool floatingButtonVisible = true;

  _VideoPlayerState({required this.videoFile, required this.controller}) {
    controller
      ..initialize().then((_) {
        setState(() {
          initialized = true;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.pause();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Stack(children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (floatingButtonVisible == false) {
                    controller.pause();
                  }
                  floatingButtonVisible = !floatingButtonVisible;
                });
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            Visibility(
              visible: floatingButtonVisible,
              child: Align(
                alignment: Alignment(0, 0),
                child: FloatingActionButton(
                  child: Icon(controller.value.isPlaying
                      ? CupertinoIcons.pause
                      : CupertinoIcons.play),
                  backgroundColor: CupertinoColors.systemRed,
                  onPressed: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        floatingButtonVisible = false;
                        controller.play();
                      }
                    });
                  },
                ),
              ),
            ),
          ])
        : Center(
            child: CupertinoActivityIndicator(),
          );
  }
}
