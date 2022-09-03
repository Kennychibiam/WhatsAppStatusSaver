import 'package:flutter/material.dart';
import 'package:whatsapp_status_saver/pages/photos.dart';
import 'package:whatsapp_status_saver/pages/saved_media.dart';
import 'package:whatsapp_status_saver/pages/videos.dart';
import 'package:whatsapp_status_saver/search_for_whatsapp_directory.dart';
import 'package:permission_handler/permission_handler.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  var status=await Permission.storage.request();
  if(status.isGranted) {
    SearchDirectoryClass searchDirectoryClass = SearchDirectoryClass();
    String? whatsAppPath = await searchDirectoryClass
        .getWhatsAppStatusDirectory();
    print(whatsAppPath);

    runApp(MaterialApp(debugShowCheckedModeBanner: false,
      home: MyApp(

      ),
    ));
  }
  else{

  }
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>with SingleTickerProviderStateMixin {
  late TabController tabBarController=TabController(length: 3,vsync:this);


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabBarController.addListener(() {

    });
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
      onWillPop: ()async{
        return false;
      },
      child: Scaffold(
            appBar: AppBar(
              bottom:TabBar(
                controller:tabBarController,
                tabs:[
                  Center(child: Tab(text: "PHOTOS",)),
                  Center(child: Tab(text: "VIDEOS",)),
                  Center(child: Tab(text: "SAVED",)),
                ]
              )
            ),
        body: TabBarView(
          controller: tabBarController,
          children: [
            Photos(),
            Videos(),
            SavedMedia(),

          ],
        ),
      ),
    );
  }
}

