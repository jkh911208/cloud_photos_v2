import 'dart:io';

import 'package:flutter/cupertino.dart';

class SinglePhoto extends StatefulWidget {
  final File file;
  const SinglePhoto({Key? key, required this.file}) : super(key: key);

  @override
  _SinglePhotoState createState() => _SinglePhotoState();
}

class _SinglePhotoState extends State<SinglePhoto> {
  @override
  Widget build(BuildContext context) {
    return Image.file(widget.file);
  }
}
