import 'dart:ffi';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:whatsapp_status_saver/method_channels/intent_channel.dart';

class DirectoryManager{
  static String? rootAndroidDirectory;//absolute directory of my android app
  Future<Map<String, dynamic>?> getWhatsAppStatusDirectory() async {
    Directory? file = await path_provider.getExternalStorageDirectory();
    List<String>? splitPlath = file?.path.split("/");
    String rootPath = "";
    for (int i = 0; i < 4; ++i) {
      rootPath += splitPlath![i] + "/";
    }
    return recursivelySearchFileSystemForStatusFolder(rootPath);
  }

  Map<String, dynamic>? recursivelySearchFileSystemForStatusFolder(String rootPath) {
    Directory directory = Directory(rootPath);
    bool isDirectoryFound = false;
    String absolutePath = "";
    if (directory.existsSync()) {//check for whatsapp folder
      List<FileSystemEntity> fileSystemEntity = directory.listSync();
      for (var fileEntity in fileSystemEntity) {
        absolutePath = fileEntity.path.toString();
        List<String>directoryStrings=[];
       try{
       directoryStrings=Directory(absolutePath).listSync().map((e) => e.path).toList();//checks if folder is actually whatsapp folder
       }
       catch(e){}
        if (path.basenameWithoutExtension(absolutePath) == "WhatsApp" && directoryStrings.contains(absolutePath+"/Media") ) {
          isDirectoryFound = true;
          break;
        } else {
          recursivelySearchFileSystemForStatusFolder(absolutePath);
        }
      }
    }
    if (isDirectoryFound) {//if whatsapp folder found check for .media and .statuses to retrieve files



      FileSystemEntity mediaFolder = Directory(absolutePath)
          .listSync()
          .firstWhere((element) =>
      path.basenameWithoutExtension(element.path) == "Media");
      FileSystemEntity statusFolder = Directory(mediaFolder.path)
          .listSync()
          .firstWhere((element) =>
      path.basenameWithoutExtension(element.path) == ".Statuses");
      List<String>videoFilePaths = [];
      List<String>photoFilePaths = [];
      Directory(statusFolder.path).listSync().forEach((element) {
        String statusFilesPath=element.path;
        if (statusFilesPath.endsWith(".png")|| statusFilesPath.endsWith(".jpg")){
          photoFilePaths.add(statusFilesPath);
        }
        else if(statusFilesPath.endsWith(".mp4")){
          videoFilePaths.add(statusFilesPath);
        }
      });
      return {"Photos":photoFilePaths,"Videos":videoFilePaths};

    }
    return null;
  }



  Future<dynamic> moveFile(File file)async{//copy file from whatsapp status folder to application's folder
    bool isFileCopySuccessful=true;
    String newFilePath="";
    try {
      if (rootAndroidDirectory != null) {
        if (!Directory(rootAndroidDirectory ?? "").existsSync()) {
          Directory(rootAndroidDirectory ?? "").createSync();
        }
        newFilePath=rootAndroidDirectory! + path.basename(file.path);

        file.copySync(newFilePath);
        MethodChannelHandler().fileIntentBroadcastChannel(newFilePath);

      }
      else {
        String androidAppPath = await getAppDefaultFilePath();
        if (!Directory(androidAppPath ).existsSync()) {
          Directory(androidAppPath).createSync();
        }

        newFilePath=rootAndroidDirectory! + path.basename(file.path);
        file.copySync(newFilePath);
        MethodChannelHandler().fileIntentBroadcastChannel(newFilePath);

      }
    }catch(e){
      isFileCopySuccessful=false;
    }
    return [isFileCopySuccessful,newFilePath];
  }

  Future<String> getAppDefaultFilePath()async{
    Directory? file = await path_provider.getExternalStorageDirectory();
    List<String>? splitPlath = file?.path.split("/");
    String rootPath = "";
    for (int i = 0; i < 4; ++i) {
      if(i!=3){
      rootPath += splitPlath![i] + "/";
      }
      else{
        rootPath += splitPlath![i] + "/Status Saver WhatsApp/";

        rootAndroidDirectory=rootPath;

      }
    }
   return rootPath;
  }
}

// if (i != 3) {
// downloadPath += splitPlath![i] + "/";
// } else {
// downloadPath += splitPlath![i] + "/LiteVideoDownloader/";
// }
