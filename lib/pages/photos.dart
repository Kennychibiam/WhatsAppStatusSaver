import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:whatsapp_status_saver/models/saved_media.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';

class Photos extends StatefulWidget {
  Photos({Key? key}) : super(key: key);

  @override
  State<Photos> createState() => _PhotosState();
}

class _PhotosState extends State<Photos>with AutomaticKeepAliveClientMixin<Photos> {
  late MediaManagerProvider mediaManagerProvider;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    mediaManagerProvider =
        Provider.of<MediaManagerProvider>(context, listen: false);
    return GridView(
      shrinkWrap: true,
        children: mediaManagerProvider.photosModel.map((model) => buildPhotosView(model.photoPath??"",width,model.isDownloading??false,model.isPhotoDownloaded??false)).toList(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2
        ),
        // itemBuilder: (context,index){
        //   String photoFile=mediaManagerProvider.photoFiles[index];
        //   return buildPhotosView(photoFile, width);
        // }
    );
  }


  Widget buildPhotosView(String photosPath, double screenWidth,bool isDownloading, bool isDownloaded) {
    var file = File(photosPath);
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Stack(
        children:[ Image.file(file, width: screenWidth / 2.0,
            height: screenWidth / 2.0,
            gaplessPlayback: true,
            fit: BoxFit.cover),
          if (!isDownloading && !isDownloaded)
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                  onPressed: () {downloadFile(photosPath);},
                  icon: CircleAvatar(
                      child: Icon(Icons.download_rounded))),
            )
          else if (isDownloaded)
            SizedBox()
          else if (isDownloading)
              Align(
                  alignment: Alignment.bottomRight ,
                  child: CircularProgressIndicator())
        ]
      ),
    );
  }


  downloadFile(String photoPath)async{
    File videoFile= File(photoPath);
    if(videoFile.existsSync()){
      mediaManagerProvider.photosModel.firstWhere((element) => element.photoPath==photoPath).isDownloading=true;

      setState(() {

      });
      DirectoryManager directoryManager=DirectoryManager();
      dynamic resultFromFileCopy=await directoryManager.moveFile(videoFile);
      mediaManagerProvider.photosModel.firstWhere((element) => element.photoPath==photoPath).isDownloading=false;
      if(resultFromFileCopy[0]==true){
        mediaManagerProvider.photosModel.firstWhere((element) => element.photoPath==photoPath).isPhotoDownloaded=true;
        SavedMediaModel savedMediaModel=SavedMediaModel(savedModelPath:resultFromFileCopy[1]);
        customToastWidget("Status Saved");
        if(mediaManagerProvider.savedMediaModel.isNotEmpty){
          mediaManagerProvider.savedMediaModel.insert(0, savedMediaModel);
        }else {
          mediaManagerProvider.savedMediaModel.add(savedMediaModel);
        }
        mediaManagerProvider.notifyListeners();
      }
      else{
        customToastWidget("Save Failed!");

      }
      setState(() {

      });
    }
  }



  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;



}

