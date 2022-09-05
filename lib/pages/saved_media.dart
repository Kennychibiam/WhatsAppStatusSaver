import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:whatsapp_status_saver/models/saved_media.dart';
import 'package:whatsapp_status_saver/models/videos.dart';
import 'package:whatsapp_status_saver/notification_widgets/custom_toast_widget.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';
import 'package:path/path.dart'as path;
import 'package:whatsapp_status_saver/routes/route_controller.dart';


class SavedMedia extends StatefulWidget {
  const SavedMedia({Key? key}) : super(key: key);

  @override
  State<SavedMedia> createState() => _VideosState();
}

class _VideosState extends State<SavedMedia>
    with AutomaticKeepAliveClientMixin<SavedMedia> {
  late MediaManagerProvider mediaManagerProvider;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    mediaManagerProvider =
        Provider.of<MediaManagerProvider>(context, listen: false);
    return Consumer<MediaManagerProvider>(
      builder:(context,instance,child)=> GridView(
        shrinkWrap: true,
        children: mediaManagerProvider.savedMediaModel
            .map((savedMediaModel) => buildSavedMediaView(
            savedMediaModel,
            width,

        ))
            .toList(),
        gridDelegate:
        SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        // itemBuilder: (context,index){
        //   String photoFile=mediaManagerProvider.photoFiles[index];
        //   return buildPhotosView(photoFile, width);
        // }
      ),
    );
  }

  Widget buildSavedMediaView(SavedMediaModel savedMediaModel, double screenWidth) {

    var file = File(savedMediaModel.savedModelPath??"");
    String filePath=file.path;
    int index=mediaManagerProvider.savedMediaModel.indexOf(savedMediaModel);
    return filePath.endsWith(".mp4")?

    GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, RouteGenerator.CAROUSEL_PAGE,arguments:{
          "StartIndex":index,
          "FilePaths":mediaManagerProvider.savedMediaModel,
          "IsFromSavedMedia":true
        }
        );
      },
      child: FutureBuilder<Uint8List?>(
          future: VideoThumbnail.thumbnailData(
              quality: 100, video: filePath, imageFormat: ImageFormat.PNG),
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
                children: [
                  Container(
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
          }),
    ):GestureDetector(
      onTap:(){
        Navigator.pushNamed(context, RouteGenerator.CAROUSEL_PAGE,arguments:{
        "StartIndex":index,
        "FilePaths":mediaManagerProvider.savedMediaModel,
        "IsFromSavedMedia":true
      });
      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: Image.file(File(filePath), width: screenWidth / 2.0,
            height: screenWidth / 2.0,
            gaplessPlayback: true,
            fit: BoxFit.cover),
      ),
    );
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
