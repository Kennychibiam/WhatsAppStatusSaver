import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:whatsapp_status_saver/method_channels/intent_channel.dart';
import 'package:whatsapp_status_saver/models/photos.dart';
import 'package:whatsapp_status_saver/models/saved_media.dart';
import 'package:whatsapp_status_saver/models/videos.dart';
import 'package:whatsapp_status_saver/notification_widgets/custom_toast_widget.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';


class Carousel extends StatefulWidget {
  int? startIndex;
  List<dynamic> models = [];
  bool? isFromSavedMedia;
  Carousel(
      {Key? key,
      required this.startIndex,
      required this.models,
      required this.isFromSavedMedia})
      : super(key: key);

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late VideoPlayerController videoPlayerController;

  late MediaManagerProvider mediaManagerProvider;
  bool isPlaying=false;
  String currentFilePath="";
  dynamic currentModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentModel=widget.models[widget.startIndex??0];
    if(widget.models.runtimeType==List<PhotosModel>){
      currentFilePath=widget.models[widget.startIndex??0]?.photoPath;
    }
    else if(widget.models.runtimeType==List<VideosModel>){
      currentFilePath=widget.models[widget.startIndex??0]?.videoPath;
    }
    else if(widget.models.runtimeType==List<SavedMediaModel>){
      currentFilePath=widget.models[widget.startIndex??0]?.savedModelPath;
    }
    videoPlayerController=VideoPlayerController.file(File(currentFilePath));
    videoPlayerController.addListener(() {
      setState(() {

      });
    });
    videoPlayerController.setLooping(true);
    videoPlayerController.initialize();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    videoPlayerController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight=MediaQuery.of(context).size.height;
    mediaManagerProvider =
        Provider.of<MediaManagerProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: !(widget.isFromSavedMedia??false)?SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        overlayOpacity: 0.0,

        children: [
          SpeedDialChild(
            label: "Share",
            child: Icon(Icons.share),
            onTap: (){share(currentFilePath);},
          ),
          SpeedDialChild(
            label: "Download",
            child: Icon(Icons.download),
            onTap: (){downloadFile(currentModel, currentFilePath);},
          ),

        ],
      ):
      SpeedDial(
        overlayOpacity: 0.0,

        animatedIcon: AnimatedIcons.menu_close,
        children: [
          SpeedDialChild(
            label: "Share",
            child: Icon(Icons.share),
            onTap: (){share(currentFilePath);},
          ),
          SpeedDialChild(
            label: "Delete",
            child: Icon(Icons.delete),
            onTap: (){delete(currentModel, currentFilePath);},
          ),

        ],
      ),
      body: CarouselSlider.builder(
        options: CarouselOptions(
          height: screenHeight,
          enableInfiniteScroll: false,
          enlargeCenterPage: true,
          viewportFraction: 1.0,

          enlargeStrategy: CenterPageEnlargeStrategy.height,

          onPageChanged: (index, reason)async{
            await videoPlayerController.dispose();

            currentModel=widget.models[index];
            if(widget.models.runtimeType==List<PhotosModel>){
              currentFilePath=widget.models[index]?.photoPath;
            }
            else if(widget.models.runtimeType==List<VideosModel>){
              currentFilePath=widget.models[index]?.videoPath;

              isPlaying=false;
              setState(() {

              });

              await videoPlayerController.dispose();

              videoPlayerController=VideoPlayerController.file(File(currentFilePath));
              videoPlayerController.addListener(() {
                setState(() {

                });
              });
              videoPlayerController.setLooping(true);
              videoPlayerController.initialize();
            }
            else if(widget.models.runtimeType==List<SavedMediaModel>){
              currentFilePath=widget.models[index]?.savedModelPath;


              if(currentFilePath.endsWith(".mp4")){//needed for video files to set thumbnail b4 video player shows

                isPlaying=false;
                setState(() {

                });
              await videoPlayerController.dispose();

              videoPlayerController=VideoPlayerController.file(File(currentFilePath));
              videoPlayerController.addListener(() {
                setState(() {

                });
              });
              videoPlayerController.setLooping(true);
              videoPlayerController.initialize();
              }
            }
          },
          initialPage: widget.startIndex ?? 0,
        ),
        itemCount: widget.models.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          String filePath="";
          if(widget.models.runtimeType==List<PhotosModel>){
            filePath=widget.models[index]?.photoPath;
          }
          else if(widget.models.runtimeType==List<VideosModel>){
            filePath=widget.models[index]?.videoPath;
          }
          else if(widget.models.runtimeType==List<SavedMediaModel>){
            filePath=widget.models[index]?.savedModelPath;
          }

          File file = File(filePath);

          if (file.path.endsWith(".png") ||
              file.path.endsWith(".jpg")) {
            return InteractiveViewer(
              clipBehavior: Clip.none,
                child: Image.file(file, gaplessPlayback: true, fit: BoxFit.contain,height:double.infinity,width: double.infinity,));
          }

          else if (file.path.endsWith(".mp4")) {
                if (!isPlaying) {
                  return GestureDetector(
                  onTap: (){
                    setState(() {
                      isPlaying=true;
                      videoPlayerController.play();
                    });
                  },
                  child: FutureBuilder<Uint8List?>(
                      future: VideoThumbnail.thumbnailData(
                          quality: 100,
                          video: file.path,
                          imageFormat: ImageFormat.PNG),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Stack(children: [
                            InteractiveViewer(
                              clipBehavior: Clip.none,
                              child: Image.memory(
                                  gaplessPlayback: true,
                                  snapshot.data!,
                                  height: double.infinity,
                                  fit: BoxFit.contain),
                            ),
                            Center(
                                child: Icon(
                                  size: 36.0,
                                  Icons.play_circle_fill,
                                  color: Colors.grey,
                                ))
                          ]);
                        }
                        return SizedBox();
                      }),
                );
                } else {
                  return GestureDetector(
                    onTap: (){
                      if(videoPlayerController.value.isPlaying){
                        videoPlayerController.pause();
                      }
                      else{
                        videoPlayerController.play();
                      }
                    },
                    child: AspectRatio(
                    aspectRatio: 16/9,
                    child: VideoPlayer(videoPlayerController),
                ),
                  );
                }


              // FutureBuilder<Uint8List?>(
              //   future: VideoThumbnail.thumbnailData(
              //       quality: 100,
              //       video: file.path,
              //       imageFormat: ImageFormat.PNG),
              //   builder: (context, snapshot) {
              //     if(snapshot.hasData){
              //     return Stack(children: [
              //       InteractiveViewer(
              //         clipBehavior: Clip.none,
              //         child: Image.memory(
              //             gaplessPlayback: true,
              //             snapshot.data!,
              //             fit: BoxFit.fill),
              //       ),
              //       Center(
              //           child: Icon(
              //         size: 36.0,
              //         Icons.play_circle_fill,
              //         color: Colors.grey,
              //       ))
              //     ]);}
              //    return SizedBox();
              //   });
          }
          return SizedBox();
        },
      ),
    );
  }

  void delete(dynamic model,String filePath)async{
    File file=File(filePath);
    if(file.existsSync()){
          file.deleteSync();
    }

    widget.models.remove(model);
    setState(() {

    });
    mediaManagerProvider.savedMediaModel.remove(model);
    mediaManagerProvider.notifyListeners();
    MethodChannelHandler().fileIntentBroadcastChannel(filePath);


  }
  void share(String filePath)async{
     List<String>files=[filePath];
     await Share.shareFiles(files);
  }
  downloadFile(dynamic model,String filePath)async{
    if(!mediaManagerProvider.savedMediaModel.map((e) => basename(e.savedModelPath??"")).toList().contains(basename(filePath))){
    File file= File(filePath);
    if(file.existsSync()){

      DirectoryManager directoryManager=DirectoryManager();
      dynamic resultFromFileCopy=await directoryManager.moveFile(file);
      if(resultFromFileCopy[0]==true) {
        if (model.runtimeType == PhotosModel){
          mediaManagerProvider.photosModel
              .firstWhere((element) => element.photoPath == filePath)
              .isPhotoDownloaded = true;
      } else if (model.runtimeType == VideosModel){
          mediaManagerProvider.videosModel
              .firstWhere((element) => element.videoPath == filePath)
              .isVideoDownloaded = true;
      }

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
    else{
      customToastWidget("Already Downloaded");
    }
  }

}
