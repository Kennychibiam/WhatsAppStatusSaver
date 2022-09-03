import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      reverse:true,
        children: mediaManagerProvider.photoFiles.map((filePath) => buildPhotosView(filePath,width)).toList(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2
        ),
        // itemBuilder: (context,index){
        //   String photoFile=mediaManagerProvider.photoFiles[index];
        //   return buildPhotosView(photoFile, width);
        // }
    );
  }


  Widget buildPhotosView(String photosPath, double screenWidth) {
    var file = File(photosPath);
    return Container(
      margin: EdgeInsets.all(5.0),
      child: Image.file(file, width: screenWidth / 2.0,
          height: screenWidth / 2.0,
          gaplessPlayback: true,
          fit: BoxFit.cover),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;



}

