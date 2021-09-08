import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class SingleVideo extends StatefulWidget {
  final File file;
  final PageController pageController;
  late final VideoPlayerController videoController;
  final int currentPage;

  SingleVideo(
      {Key? key,
      required this.file,
      required this.pageController,
      required this.currentPage})
      : super(key: key) {
    videoController = VideoPlayerController.file(file);
  }

  @override
  _VideoPlayerState createState() =>
      _VideoPlayerState(videoController: videoController);
}

class _VideoPlayerState extends State<SingleVideo> {
  bool initialized = false;
  VideoPlayerController videoController;
  late ChewieController chewieController;

  _VideoPlayerState({required this.videoController}) {
    pageInit();
  }

  @override
  void dispose() {
    videoController.pause();
    videoController.dispose();
    super.dispose();
  }

  Future<void> pageInit() async {
    await videoController.initialize();
    chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp
        ]);
    setState(() {
      initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Padding(
            padding: const EdgeInsets.only(bottom: 30),
          child: SafeArea(
                child: Center(child: Chewie(controller: chewieController))),
          )
        : Center(
            child: CupertinoActivityIndicator(),
          );
  }
}
