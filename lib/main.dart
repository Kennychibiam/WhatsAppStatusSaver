import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp_status_saver/pages/photos.dart';
import 'package:whatsapp_status_saver/pages/saved_media.dart';
import 'package:whatsapp_status_saver/pages/videos.dart';
import 'package:whatsapp_status_saver/providers/media_manager_provider.dart';
import 'package:whatsapp_status_saver/directory_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_status_saver/routes/route_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  bool isAllPermissionsGranted=true;
  Map<Permission,PermissionStatus>permissions=await [Permission.storage,Permission.manageExternalStorage].request();
  permissions.forEach((key, value) { isAllPermissionsGranted=value.isGranted;});

  if (isAllPermissionsGranted) {
    DirectoryManager directoryManager =DirectoryManager();
    MediaManagerProvider mediaManagerProvider=MediaManagerProvider(directoryManager);
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

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController tabBarController = TabController(length: 3, vsync: this);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabBarController.addListener(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tabBarController.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
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
        ])),
        body: Consumer<MediaManagerProvider>(
          builder:(context,instance,child)=> TabBarView(

            controller: tabBarController,
            children: [
              Photos(),
              Videos(),
              SavedMedia(),
            ],
          ),
        ),
      ),
    );
  }
}
