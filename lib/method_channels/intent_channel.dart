
import 'package:flutter/services.dart';

class MethodChannelHandler{
  static MethodChannelHandler methodChannelInstance=MethodChannelHandler.initialize();
  final String methodChannelName="FileIntentBroadcastChannel";
  MethodChannel ?methodChannel;

  factory MethodChannelHandler(){
    return methodChannelInstance;
  }

  MethodChannelHandler.initialize();

  void fileIntentBroadcastChannel(String filePath){
    try {
      methodChannel = MethodChannel(methodChannelName);
      methodChannel?.invokeMethod("BroadcastFile", {"FilePath": filePath});
      print("reachd");
      print(filePath);
    }catch(e){
      print("eeror platform");
    }
  }
}