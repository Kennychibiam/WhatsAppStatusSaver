import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future customToastWidget(String message)=> Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.black54,
    textColor: Colors.white70,
    toastLength: Toast.LENGTH_SHORT);