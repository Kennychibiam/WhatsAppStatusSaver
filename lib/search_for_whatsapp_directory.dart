
import 'dart:ffi';
import 'dart:io';

import 'package:path_provider/path_provider.dart'as path_provider;
import 'package:path/path.dart'as path;
class SearchDirectoryClass{

  Future <String?> getWhatsAppStatusDirectory() async{
   Directory? file=await path_provider.getExternalStorageDirectory();
   print(file?.path);
   List<String>? splitPlath = file?.path.split("/");
   String rootPath = "";
   for (int i = 0; i < 4; ++i) {

       rootPath += splitPlath![i] + "/";
     }
   return recursivelySearchFileSystemForStatus(rootPath);


   }

   String? recursivelySearchFileSystemForStatus(String rootPath){
    Directory directory=Directory(rootPath);
    bool isDirectoryFound=false;
    if(directory.existsSync()){
      List<FileSystemEntity> fileSystemEntity=directory.listSync();
      for (var fileEntity in fileSystemEntity) {
        String absolutePath=fileEntity.path.toString();
        if(path.basenameWithoutExtension(absolutePath)=="WhatsApp"){
          isDirectoryFound=true;
          return absolutePath;
        }
        else{
          recursivelySearchFileSystemForStatus(absolutePath);

        }
      }
    }
    if(isDirectoryFound){

    }
    return null;
   }
  }




  // if (i != 3) {
  // downloadPath += splitPlath![i] + "/";
  // } else {
  // downloadPath += splitPlath![i] + "/LiteVideoDownloader/";
  // }