import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

Future<bool?> confirmPopup(BuildContext context, String title, String message) {
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: <Widget>[
      TextButton(
        child: const Text('Không'),
        onPressed: () {
          Navigator.pop(context, false);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          foregroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
        ),
      ),
      5.widthBox,
      TextButton(
        child: const Text('Có'),
        onPressed: () {
          Navigator.pop(context, true);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
          foregroundColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
        ),
      ),
    ],
  );

  // show the dialog
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
