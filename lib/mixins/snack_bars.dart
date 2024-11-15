import 'package:flutter/material.dart';

mixin SnackBars<T extends StatefulWidget> on State<T> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(String message, [Color? backgroundColor]) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(message),
      ),
    );
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> showErrorSnackBar(Object? error) async {
    return showSnackBar(
      error?.toString() ?? 'An unknown error occurred. Please try again later.',
      Colors.red,
    );
  }
}
