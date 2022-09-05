import "package:flutter/material.dart";
import 'package:whatsapp_status_saver/main.dart';
import 'package:whatsapp_status_saver/pages/caurousel_view.dart';




class RouteGenerator{
   static const String MAIN_PAGE="MAIN_PAGE";
   static const String CAROUSEL_PAGE="CAROUSEL_PAGE";


  static Route<dynamic>routeGenerator(RouteSettings routeSettings){
    String? name=routeSettings.name;

    switch(name){
      case CAROUSEL_PAGE:
        dynamic args=routeSettings.arguments as Map;
        return MaterialPageRoute(builder:(context)=>Carousel(startIndex:args["StartIndex"], models:args["FilePaths"], isFromSavedMedia: args["IsFromSavedMedia"]));
      default:return MaterialPageRoute(builder:(context)=>MyApp());

    }

  }
}