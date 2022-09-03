import 'dart:ffi';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;

class SearchDirectoryClass {
  Future<Map<String, dynamic>?> getWhatsAppStatusDirectory() async {
    Directory? file = await path_provider.getExternalStorageDirectory();
    print(file?.path);
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
        if (path.basenameWithoutExtension(absolutePath) == "WhatsApp") {
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
}

// if (i != 3) {
// downloadPath += splitPlath![i] + "/";
// } else {
// downloadPath += splitPlath![i] + "/LiteVideoDownloader/";
// }
