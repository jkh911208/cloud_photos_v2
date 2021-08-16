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
    int index = widget.index;
    return Stack(children: [
      SafeArea(
        child: PageView.builder(
            controller: widget.pageController,
            allowImplicitScrolling: true, // allows caching next page
            onPageChanged: (int newIndex) {
              index = newIndex;
            },
            itemCount: widget.asset.length,
            itemBuilder: (context, position) {
              return BuildItem(asset: widget.asset, position: position);
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
  final int position;
  const BuildItem({Key? key, required this.asset, required this.position})
      : super(key: key);

  @override
  _BuildItemState createState() => _BuildItemState();
}

class _BuildItemState extends State<BuildItem> {
  int dragDown = 0;
  bool dragCancel = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.asset[widget.position].file,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            int currentPosition = widget.position;
            print("load $currentPosition finished");
            if (widget.asset[widget.position].type == AssetType.image) {
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
            } else if (widget.asset[widget.position].type == AssetType.video) {
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
  final File videoFile;
  final VideoPlayerController controller;

  const VideoPlayerScreen(
      {Key? key, required this.videoFile, required this.controller})
      : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayerScreen> {
  bool initialized = false;
  bool floatingButtonVisible = true;

  _VideoPlayerState() {
    widget.controller
      ..initialize().then((_) {
        setState(() {
          initialized = true;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.pause();
    widget.controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Stack(children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (floatingButtonVisible == false) {
                    widget.controller.pause();
                  }
                  floatingButtonVisible = !floatingButtonVisible;
                });
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: widget.controller.value.aspectRatio,
                  child: VideoPlayer(widget.controller),
                ),
              ),
            ),
            Visibility(
              visible: floatingButtonVisible,
              child: Align(
                alignment: Alignment(0, 0),
                child: FloatingActionButton(
                  child: Icon(widget.controller.value.isPlaying
                      ? CupertinoIcons.pause
                      : CupertinoIcons.play),
                  backgroundColor: CupertinoColors.systemRed,
                  onPressed: () {
                    setState(() {
                      if (widget.controller.value.isPlaying) {
                        widget.controller.pause();
                      } else {
                        floatingButtonVisible = false;
                        widget.controller.play();
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
