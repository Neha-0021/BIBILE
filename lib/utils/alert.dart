import 'package:flutter/material.dart';

class AlertBundle {
  SnackBarNotify(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showAlertDialog(
    BuildContext context,
    String? heading,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(heading ?? ""),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

    void showAlertDialogWithAction(
    BuildContext context,
    String? heading,
    String message,
    List<Widget> action,
    bool isBackPressDismissed
  ) {
    showDialog(
      context: context,
      barrierDismissible:isBackPressDismissed,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(heading ?? ""),
          content: Text(message),
          actions: action,
        );
      },
    );
  }
}
