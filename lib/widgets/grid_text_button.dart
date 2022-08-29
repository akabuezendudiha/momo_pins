import 'package:flutter/material.dart';

// gridTextButton Template
Widget gridTextButton(
    {required IconData? iconData,
    required Color? backgroundColor,
    required String text,
    required Function onPressed,
    double iconSize = 40}) {
  return TextButton(
      onPressed: () => onPressed(),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Icon(
              iconData,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ));
}
