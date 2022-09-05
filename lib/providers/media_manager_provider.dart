import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:whatsapp_status_saver/method_channels/intent_channel.dart';
import 'package:whatsapp_status_saver/models/photos.dart';
import 'package:whatsapp_status_saver/models/saved_media.dart';
import 'package:whatsapp_status_saver/models/videos.dart';


class MediaManagerProvider extends ChangeNotifier{


  List<PhotosModel>photosModel=[];
  List<VideosModel>videosModel=[];
  List<SavedMediaModel>savedMediaModel=[];
  List<SavedMediaModel>selectedSavedMediaModel=[];//for deletion
  DirectoryManager? directoryManager;
  bool isMultiSelectEnabled=false;
  bool isEveryElementSelected=false;

  MediaManagerProvider(this.directoryManager);

  void initializeVideoAndPhotosModels()async{
    Map<String,dynamic>?mapForVideosAndPhotos=await directoryManager?.getWhatsAppStatusDirectory();
    if(mapForVideosAndPhotos!=null){
      photosModel=List<String>.from(mapForVideosAndPhotos["Photos"]).map((e) => PhotosModel(photoPath: e,dateModified: File(e).statSync().modified,isDownloading: false,isPhotoDownloaded: false)).toList();
      videosModel=List<String>.from(mapForVideosAndPhotos["Videos"]).map((e) => VideosModel(videoPath: e,dateModified: File(e).statSync().modified,isDownloading: false,isVideoDownloaded: false)).toList();

      photosModel.sort((a, b) =>b.dateModified!.compareTo(a.dateModified??DateTime.now()));
      videosModel.sort((a, b) =>b.dateModified!.compareTo(a.dateModified??DateTime.now()));


      String ?androidDefaultAppPath=await directoryManager?.getAppDefaultFilePath();
      Directory defaultAppDirectory=Directory(androidDefaultAppPath??"");


      if (!defaultAppDirectory.existsSync()) {
        print("not exists");

      }else{//if default ap folder exists check if file is already downloaded
        print("exists");
        savedMediaModel=defaultAppDirectory.listSync().map((e) => SavedMediaModel(savedModelPath: e.path,dateModified: e.statSync().modified)).toList();
        savedMediaModel.sort((a, b) =>b.dateModified!.compareTo(a.dateModified??DateTime.now()));

        List<String>appSavedFiles=defaultAppDirectory.listSync().map((e) => basename(e.path)).toList();
        photosModel.forEach((photoModel) {
          if(appSavedFiles.contains(basename(photoModel.photoPath!))){
            photoModel.isPhotoDownloaded=true;

          }
          else{
            photoModel.isPhotoDownloaded=false;

          }
        });

        videosModel.forEach((videoModel) {
          if(appSavedFiles.contains(basename(videoModel.videoPath!))){
            videoModel.isVideoDownloaded=true;

          }
          else{
            videoModel.isVideoDownloaded=false;

          }
        });
      }

    // photoFiles=mapForVideosAndPhotos["Photos"];
    // videoFiles=mapForVideosAndPhotos["Videos"];
    }

    notifyListeners();
  }

  void disableMultiSelection()async {
    isMultiSelectEnabled=false;
    isEveryElementSelected=false;
    selectedSavedMediaModel=[];
    savedMediaModel.forEach((element) { element.isSelected=false;});
    notifyListeners();

  }
  void selectDeselectAllElements()async{

    if(isEveryElementSelected){
      selectedSavedMediaModel=[];
      savedMediaModel.forEach((element) { element.isSelected=false;});
      isEveryElementSelected=false;
    }
    else if(!isEveryElementSelected){
      isEveryElementSelected=true;
      savedMediaModel.forEach((element) {element.isSelected=true;
      if(!selectedSavedMediaModel.contains(element)){
        selectedSavedMediaModel.add(element);
      }
      });

    }
    notifyListeners();
  }
void delete()async{
    selectedSavedMediaModel.forEach((element) {
      savedMediaModel.remove(element);
      if(element.savedModelPath!=null){
      MethodChannelHandler().fileIntentBroadcastChannel(element.savedModelPath!);}
    });
    disableMultiSelection();

}
void enableMultiSelection(SavedMediaModel savedMedia){
  isMultiSelectEnabled=true;
  savedMediaModel.firstWhere((element) => element.savedModelPath==savedMedia.savedModelPath).isSelected=true;

  if(!selectedSavedMediaModel.contains(savedMedia)){
    selectedSavedMediaModel.add(savedMedia);
  }
  notifyListeners();
}
void toggleSelectItem(SavedMediaModel savedMedia)async{
    if(savedMedia.isSelected){
      savedMediaModel.firstWhere((element) => element.savedModelPath==savedMedia.savedModelPath).isSelected=false;
      selectedSavedMediaModel.removeWhere((element) => element.savedModelPath==savedMedia.savedModelPath);

    }
    else{
      savedMediaModel.firstWhere((element) => element.savedModelPath==savedMedia.savedModelPath).isSelected=true;
      selectedSavedMediaModel.add(savedMedia);

    }
    notifyListeners();
}
}