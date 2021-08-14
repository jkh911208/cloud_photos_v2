import 'package:cloud_photos_v2/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_photos_v2/database.dart';

class ThumbnailScreen extends StatelessWidget {
  const ThumbnailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        backgroundColor: Constant.CloudPhotosGrey, child: ThumbnailBody());
  }
}

class ThumbnailBody extends StatefulWidget {
  const ThumbnailBody({Key? key}) : super(key: key);

  @override
  _ThumbnailBodyState createState() => _ThumbnailBodyState();
}

class _ThumbnailBodyState extends State<ThumbnailBody> {
  List photos = [];

  _ThumbnailBodyState() {
    getAllMedia();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text("Photos"),
        ),
        SliverFillRemaining(
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4),
              itemCount: photos.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                    padding: const EdgeInsets.all(1),
                    child: Image.memory(photos[index].thumbnail,
                        width: MediaQuery.of(context).size.width / 4 - 2,
                        height: MediaQuery.of(context).size.width / 4 - 2,
                        fit: BoxFit.cover));
              }),
        )
      ],
    );
  }

  Future getAllMedia() async {
    List<Media> newList = await MediaTable().selectAll();
    setState(() {
      photos = newList;
    });
  }
}
