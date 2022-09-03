import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';


class MediaManagerProvider extends ChangeNotifier{


  List<String>photoFiles=[];
  List<String>videoFiles=[];


  set setVideosAndPhotos(Map<String,dynamic>?mapForVideosAndPhotos){
    if(mapForVideosAndPhotos!=null){
    photoFiles=mapForVideosAndPhotos["Photos"];
    videoFiles=mapForVideosAndPhotos["Videos"];
    }
  }



}