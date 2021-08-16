import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SingleVideo extends StatefulWidget {
  final File file;
  // late final VideoPlayerController videoController;

  SingleVideo({Key? key, required this.file}) : super(key: key);
  // {
  //   videoController = VideoPlayerController.file(file);
  // }

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<SingleVideo> {
  bool initialized = false;
  bool floatingButtonVisible = true;
  late VideoPlayerController _videoController;

  _VideoPlayerState() {
    _videoController = VideoPlayerController.file(widget.file);
    _videoController
      ..initialize().then((_) {
        setState(() {
          initialized = true;
        });
      });
    // widget.videoController
    //   ..initialize().then((_) {
    //     setState(() {
    //       initialized = true;
    //     });
    //   });
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   widget.videoController.pause();
  //   widget.videoController.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return initialized
        ? Stack(children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (floatingButtonVisible == false) {
                    _videoController.pause();
                  }
                  floatingButtonVisible = !floatingButtonVisible;
                });
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
            Visibility(
              visible: floatingButtonVisible,
              child: Align(
                alignment: Alignment(0, 0),
                child: FloatingActionButton(
                  child: Icon(_videoController.value.isPlaying
                      ? CupertinoIcons.pause
                      : CupertinoIcons.play),
                  backgroundColor: CupertinoColors.systemRed,
                  onPressed: () {
                    setState(() {
                      if (_videoController.value.isPlaying) {
                        _videoController.pause();
                      } else {
                        floatingButtonVisible = false;
                        _videoController.play();
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
