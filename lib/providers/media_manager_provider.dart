import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:whatsapp_status_saver/models/photos.dart';
import 'package:whatsapp_status_saver/models/saved_media.dart';
import 'package:whatsapp_status_saver/models/videos.dart';


class MediaManagerProvider extends ChangeNotifier{


  List<PhotosModel>photosModel=[];
  List<VideosModel>videosModel=[];
  List<SavedMediaModel>savedMediaModel=[];
  DirectoryManager? directoryManager;

  MediaManagerProvider(this.directoryManager);

  void initializeVideoAndPhotosModels()async{
    Map<String,dynamic>?mapForVideosAndPhotos=await directoryManager?.getWhatsAppStatusDirectory();
    if(mapForVideosAndPhotos!=null){
      photosModel=List<String>.from(mapForVideosAndPhotos["Photos"]).map((e) => PhotosModel(photoPath: e,dateModified: File(e).statSync().modified)).toList();
      videosModel=List<String>.from(mapForVideosAndPhotos["Videos"]).map((e) => VideosModel(videoPath: e,dateModified: File(e).statSync().modified)).toList();

      photosModel.sort((a, b) =>b.dateModified!.compareTo(a.dateModified??DateTime.now()));
      videosModel.sort((a, b) =>b.dateModified!.compareTo(a.dateModified??DateTime.now()));


      String ?androidDefaultAppPath=await directoryManager?.getAppDefaultFilePath();
      Directory defaultAppDirectory=Directory(androidDefaultAppPath??"");


      if (!defaultAppDirectory.existsSync()) {

      }else{//if default ap folder exists check if file is already downloaded
        savedMediaModel=defaultAppDirectory.listSync().map((e) => SavedMediaModel(savedModelPath: e.path,dateModified: e.statSync().modified)).toList();
        savedMediaModel.sort((a, b) =>b.dateModified!.compareTo(a.dateModified??DateTime.now()));

        List<String>appSavedFiles=defaultAppDirectory.listSync().map((e) => basename(e.path)).toList();
        photosModel.forEach((photoModel) {
          if(appSavedFiles.contains(basename(photoModel.photoPath!))){
            photoModel.isPhotoDownloaded=true;

          }
        });

        videosModel.forEach((videoModel) {
          if(appSavedFiles.contains(basename(videoModel.videoPath!))){
            videoModel.isVideoDownloaded=true;

          }
        });
      }

    // photoFiles=mapForVideosAndPhotos["Photos"];
    // videoFiles=mapForVideosAndPhotos["Videos"];
    }
  }



}