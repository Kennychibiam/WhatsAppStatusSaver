import 'package:flutter/material.dart';

Future<dynamic> showDialogExitWidget(BuildContext context,{String? notificationInfo}) async=> showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(

      content: Container(
        height: 50.0,
        child:Text(notificationInfo??"Do you want to exit application."),
      ),
      actions: [
        TextButton(onPressed: (){Navigator.pop(context,false);}, child:Text("No")),
        TextButton(onPressed: (){Navigator.pop(context,true);}, child:Text("Yes")),
      ],
    ));
