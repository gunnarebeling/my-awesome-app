import 'package:flutter/material.dart';

mixin Navigation<T extends StatefulWidget> on State<T> {
  Future<E?> pushScreen<E extends Object?>(Widget screen) {
    return Navigator.of(context).push<E>(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<E?> popAllAndPush<E extends Object?>(Widget screen) {
    return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (_) => false,
    );
  }

  void popScreen<E extends Object?>([E? result]) {
    return Navigator.of(context).pop<E>(result);
  }
}
