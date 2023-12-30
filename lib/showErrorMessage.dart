

import 'package:flutter/material.dart';

void showErrorMessage(context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
          actions: [
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(

              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400]),
            onPressed: () => Navigator.pop(context), // passing false
      child: Text('OK',

      style: TextStyle(
     // fontSize: 25,
     // color: Colors.black,
      fontFamily: 'NexaBold')
      ),

      ),
          ),],
      //  backgroundColor: Colors.yellow[550],
        title: Center(
          child: SelectableText(
            message,
            style: TextStyle(color: Colors.black),
          ),
        ),
      );
    },
  );
}