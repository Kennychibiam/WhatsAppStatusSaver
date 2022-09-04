import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

Future customToastWidget(String message)=> Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.black54,
    textColor: Colors.white70,
    toastLength: Toast.LENGTH_SHORT);