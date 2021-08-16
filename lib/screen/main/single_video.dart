import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SingleVideo extends StatefulWidget {
  final File file;
  final PageController pageController;
  late final VideoPlayerController videoController;
  late final double? currentPage;

  SingleVideo({Key? key, required this.file, required this.pageController})
      : super(key: key) {
    videoController = VideoPlayerController.file(file);
    currentPage = pageController.page;
    pageController.addListener(() {
      double? newPage = pageController.page;
      if (currentPage != newPage) {
        videoController.pause();
      }
    });
  }

  @override
  _VideoPlayerState createState() =>
      _VideoPlayerState(videoController: videoController);
}

class _VideoPlayerState extends State<SingleVideo> {
  bool initialized = false;
  bool floatingButtonVisible = true;
  VideoPlayerController videoController;

  _VideoPlayerState({required this.videoController}) {
    videoController
      ..initialize().then((_) {
        setState(() {
          initialized = true;
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoController.pause();
    videoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Stack(children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (floatingButtonVisible == false) {
                    videoController.pause();
                  }
                  floatingButtonVisible = !floatingButtonVisible;
                });
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                ),
              ),
            ),
            Visibility(
              visible: floatingButtonVisible,
              child: Align(
                alignment: Alignment(0, 0),
                child: FloatingActionButton(
                  child: Icon(videoController.value.isPlaying
                      ? CupertinoIcons.pause
                      : CupertinoIcons.play),
                  backgroundColor: CupertinoColors.systemRed,
                  onPressed: () {
                    setState(() {
                      if (videoController.value.isPlaying) {
                        videoController.pause();
                      } else {
                        floatingButtonVisible = false;
                        videoController.play();
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
