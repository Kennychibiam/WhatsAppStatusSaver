import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:whatsapp_status_saver/models/photos.dart';
import 'package:whatsapp_status_saver/models/saved_media.dart';
import 'package:whatsapp_status_saver/notification_widgets/custom_toast_widget.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';
import 'package:whatsapp_status_saver/routes/route_controller.dart';

class Photos extends StatefulWidget {
  Photos({Key? key}) : super(key: key);

  @override
  State<Photos> createState() => _PhotosState();
}

class _PhotosState extends State<Photos>with AutomaticKeepAliveClientMixin<Photos> {
  late MediaManagerProvider mediaManagerProvider;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    mediaManagerProvider =
        Provider.of<MediaManagerProvider>(context, listen: false);
    return GridView(
      shrinkWrap: true,
        children: mediaManagerProvider.photosModel.map((model) => buildPhotosView(model,screenWidth)).toList(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2
        ),
        // itemBuilder: (context,index){
        //   String photoFile=mediaManagerProvider.photoFiles[index];
        //   return buildPhotosView(photoFile, width);
        // }
    );
  }


  Widget buildPhotosView(PhotosModel photoModel,double screenWidth) {
    var file = File(photoModel.photoPath??"");
    int index=mediaManagerProvider.photosModel.indexOf(photoModel);
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(context, RouteGenerator.CAROUSEL_PAGE,arguments:{
          "StartIndex":index,
          "FilePaths":mediaManagerProvider.photosModel,
          "IsFromSavedMedia":false
        }
        );

      },
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: Stack(
          children:[ Image.file(file, width: screenWidth / 2.0,
              height: screenWidth / 2.0,
              gaplessPlayback: true,
              fit: BoxFit.cover),
            if (!photoModel.isDownloading! && !photoModel.isPhotoDownloaded!)
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                    onPressed: () {downloadFile(photoModel.photoPath!);},
                    icon: CircleAvatar(
                        child: Icon(Icons.download_rounded))),
              )
            else if (photoModel.isPhotoDownloaded!)
              SizedBox()
            else if (photoModel.isDownloading!)
                Align(
                    alignment: Alignment.bottomRight ,
                    child: CircularProgressIndicator())
          ]
        ),
      ),
    );
  }


  downloadFile(String photoPath)async{
    File photoFile= File(photoPath);
    if(photoFile.existsSync()){
      mediaManagerProvider.photosModel.firstWhere((element) => element.photoPath==photoPath).isDownloading=true;

      setState(() {

      });
      DirectoryManager directoryManager=DirectoryManager();
      dynamic resultFromFileCopy=await directoryManager.moveFile(photoFile);
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

