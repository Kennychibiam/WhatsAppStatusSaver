import "package:flutter/material.dart";
import 'package:whatsapp_status_saver/main.dart';




class RouteGenerator{
   static final String MAIN_PAGE="MAIN_PAGE";


  static Route<dynamic>routeGenerator(RouteSettings routeSettings){
    String? name=routeSettings.name;

    switch(name){
      default:return MaterialPageRoute(builder:(context)=>MyApp());

    }

  }
}