import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_status_saver/models/photos.dart';
import 'package:whatsapp_status_saver/models/videos.dart';


class MediaManagerProvider extends ChangeNotifier{


  //List<String>photoFiles=[];
  List<PhotosModel>photosModel=[];
  List<VideosModel>videosModel=[];
  //List<String>videoFiles=[];


  set setVideosAndPhotos(Map<String,dynamic>?mapForVideosAndPhotos){
    if(mapForVideosAndPhotos!=null){
      photosModel=List<String>.from(mapForVideosAndPhotos["Photos"]).map((e) => PhotosModel(photoPath: e)).toList();
      videosModel=List<String>.from(mapForVideosAndPhotos["Videos"]).map((e) => VideosModel(videoPath: e)).toList();
    // photoFiles=mapForVideosAndPhotos["Photos"];
    // videoFiles=mapForVideosAndPhotos["Videos"];
    }
  }



}