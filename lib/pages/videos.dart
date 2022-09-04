import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:whatsapp_status_saver/models/saved_media.dart';
import 'package:whatsapp_status_saver/models/videos.dart';
import 'package:whatsapp_status_saver/pages/saved_media.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';
import 'package:path/path.dart'as path;


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
      children: mediaManagerProvider.videosModel
          .map((videoModel) => buildPhotosView(
              videoModel.videoPath ?? "",
              width,
              videoModel.isDownloading ?? false,
              videoModel.isVideoDownloaded ?? false))
          .toList(),
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      // itemBuilder: (context,index){
      //   String photoFile=mediaManagerProvider.photoFiles[index];
      //   return buildPhotosView(photoFile, width);
      // }
    );
  }

  Widget buildPhotosView(String videoPath, double screenWidth,
      bool isDownloading, bool isDownloaded) {
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
                      if (!isDownloading && !isDownloaded)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                              onPressed: () {downloadFile(videoPath);},
                              icon: CircleAvatar(
                                  child: Icon(Icons.download_rounded))),
                        )
                      else if (isDownloading)
                        Align(
                            alignment: Alignment.bottomRight,
                            child: CircularProgressIndicator())
                      else if (isDownloaded)
                        SizedBox()

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
                      if (!isDownloading && !isDownloaded)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                              onPressed: () {downloadFile(videoPath);},
                              icon: CircleAvatar(
                                  child: Icon(Icons.download_rounded))),
                        )
                      else if (isDownloaded)
                        SizedBox()
                      else if (isDownloading)
                        Align(
                            alignment: Alignment.bottomRight ,
                            child: CircularProgressIndicator())
                    ],
                  ),
          );
        });
  }


  downloadFile(String videoPath)async{
   File videoFile= File(videoPath);
    if(videoFile.existsSync()){
     mediaManagerProvider.videosModel.firstWhere((element) => element.videoPath==videoPath).isDownloading=true;

      setState(() {

      });
      DirectoryManager directoryManager=DirectoryManager();
      dynamic resultFromFileCopy=await directoryManager.moveFile(videoFile);
     mediaManagerProvider.videosModel.firstWhere((element) => element.videoPath==videoPath).isDownloading=false;
     if(resultFromFileCopy[0]==true){
       mediaManagerProvider.videosModel.firstWhere((element) => element.videoPath==videoPath).isVideoDownloaded=true;
       SavedMediaModel savedMediaModel=SavedMediaModel(savedModelPath:resultFromFileCopy[1]);
       if(mediaManagerProvider.savedMediaModel.isNotEmpty){
         mediaManagerProvider.savedMediaModel.insert(0, savedMediaModel);
       }else {
         mediaManagerProvider.savedMediaModel.add(savedMediaModel);
       }
       mediaManagerProvider.notifyListeners();
     }
      else{

      }
      setState(() {

      });
    }
  }
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
