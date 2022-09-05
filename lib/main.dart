import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_status_saver/notification_widgets/show_dialog_exit_notify_widget.dart';
import 'package:whatsapp_status_saver/pages/photos.dart';
import 'package:whatsapp_status_saver/pages/saved_media.dart';
import 'package:whatsapp_status_saver/pages/videos.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_status_saver/routes/route_controller.dart';

DirectoryManager directoryManager =DirectoryManager();
MediaManagerProvider mediaManagerProvider=MediaManagerProvider(directoryManager);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  MobileAds.instance.initialize();

  bool isAllPermissionsGranted=true;
  Map<Permission,PermissionStatus>permissions=await [Permission.storage,Permission.manageExternalStorage].request();
  permissions.forEach((key, value) { isAllPermissionsGranted=value.isGranted;});

  if (isAllPermissionsGranted) {

    mediaManagerProvider.initializeVideoAndPhotosModels();


    runApp(ChangeNotifierProvider<MediaManagerProvider>(
      create:(_)=> mediaManagerProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.routeGenerator,
        initialRoute: RouteGenerator.MAIN_PAGE,
      ),
    ));
  } else {}
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin, WidgetsBindingObserver{
  late TabController tabBarController = TabController(length: 3, vsync: this);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    tabBarController.addListener(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabBarController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

  } // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(mediaManagerProvider.isMultiSelectEnabled){
          mediaManagerProvider.disableMultiSelection();
          return false;
        }
            bool canExit=await showDialogExitWidget(context);
            if(canExit){
              return true;
            }
            else{
              return false;
        }
      },
      child:Consumer<MediaManagerProvider>(
      builder:(context,instance,child)=> Scaffold(
        appBar:  !mediaManagerProvider.isMultiSelectEnabled?AppBar(
            bottom: TabBar(controller: tabBarController, tabs: [
          Center(
              child: Tab(
            text: "PHOTOS",
          )),
          Center(
              child: Tab(
            text: "VIDEOS",
          )),
          Center(
              child: Tab(
            text: "SAVED",
          )),
        ]),
          flexibleSpace: Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.indigo,
            Colors.lightBlue,
          ],
        ),
      ),
    ),
        ):
        AppBar(
          title:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () {
                    mediaManagerProvider.selectDeselectAllElements();
                  },
                  child: !mediaManagerProvider.isEveryElementSelected
                      ? Text(
                    "Select All ",
                    style: TextStyle(color: Colors.white),
                  )
                      : Text(
                    "Cancel All",
                    style: TextStyle(color: Colors.white),
                  )),
              Text(
                "${mediaManagerProvider.selectedSavedMediaModel.length} selected",
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                  onPressed: ()async {
                    bool canDelete=await showDialogExitWidget(context,notificationInfo:"Do you want to delete selected items.");
                    if(canDelete){
                      mediaManagerProvider.delete();
                    }
                    else{
                     mediaManagerProvider.disableMultiSelection();
                    }
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
          bottom: TabBar(controller: tabBarController, tabs: [
            Center(
                child: Tab(
                  text: "PHOTOS",
                )),
            Center(
                child: Tab(
                  text: "VIDEOS",
                )),
            Center(
                child: Tab(
                  text: "SAVED",
                )),
          ]),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.indigo,
                  Colors.lightBlue,
                ],
              ),
            ),
          ),
        ),


        body:  TabBarView(

            controller: tabBarController,
            children: [
              Photos(),
              Videos(),
              SavedMedia(),
            ],
          ),

      ),),
    );
  }
}
