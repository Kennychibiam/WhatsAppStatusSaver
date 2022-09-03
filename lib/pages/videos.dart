import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';

class Videos extends StatefulWidget {
  const Videos({Key? key}) : super(key: key);

  @override
  State<Videos> createState() => _VideosState();
}

class _VideosState extends State<Videos>
    with AutomaticKeepAliveClientMixin<Videos> {
  late MediaManagerProvider mediaManagerProvider;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    mediaManagerProvider =
        Provider.of<MediaManagerProvider>(context, listen: false);
    return GridView(
      shrinkWrap: true,
      reverse: true,
      children: mediaManagerProvider.videoFiles
          .map((filePath) => buildPhotosView(filePath, width))
          .toList(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      // itemBuilder: (context,index){
      //   String photoFile=mediaManagerProvider.photoFiles[index];
      //   return buildPhotosView(photoFile, width);
      // }
    );
  }

  Widget buildPhotosView(String videoPath, double screenWidth) {
    return FutureBuilder<Uint8List?>(
        future: VideoThumbnail.thumbnailData(
            quality: 100, video: videoPath, imageFormat: ImageFormat.PNG),
        builder: (context, snapshot) {
          return Container(
            margin: EdgeInsets.all(5.0),
            child: snapshot.data != null
                ? Stack(
                    children: [
                      Image.memory(
                          gaplessPlayback: true,
                          snapshot.data!,
                          width: screenWidth / 2.0,
                          height: screenWidth / 2.0,
                          fit: BoxFit.cover),
                      Center(
                          child: Icon(
                            size: 36.0,
                            Icons.play_circle_fill,
                        color: Colors.grey,
                      )),
                    ],
                  )
                : Stack(
                  children:[ Container(
                      color: Colors.black38,
                    ),
                    Center(
                        child: Icon(
                          size: 36.0,
                          Icons.play_circle_fill,
                          color: Colors.grey,
                        )),
                  ],
                ),
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
