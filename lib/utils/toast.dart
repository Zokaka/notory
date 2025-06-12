import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void toastInfo(
    String msg, {
      Color backgroundColor = Colors.black,
      Color textColor = Colors.white,
      ToastGravity gravity = ToastGravity.BOTTOM,
    }) {
  FToast fToast = FToast();
  fToast.init(navigatorKey.currentContext!);
  fToast.removeCustomToast();
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: backgroundColor,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon(Icons.check),
        // SizedBox(
        //   width: 12.0,
        // ),
        Text(
          msg,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ],
    ),
  );

  return fToast.showToast(
    toastDuration: const Duration(seconds: 2),
    gravity: gravity,
    // timeInSecForIosWeb: 1,
    // backgroundColor: backgroundColor,
    // textColor: textColor,
    // fontSize: 14.sp,
    child: toast,
  );
}
