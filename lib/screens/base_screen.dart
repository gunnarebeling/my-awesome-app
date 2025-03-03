import 'package:flutter/material.dart';
import 'package:my_awesome_app/mixins/navigation.dart';
import 'package:my_awesome_app/mixins/snack_bars.dart';
import 'package:my_awesome_app/widgets/app_bars/default_app_bar.dart';
import 'package:my_awesome_app/widgets/loading_spinner.dart';

abstract class BaseScreen extends StatefulWidget {
  final String title;
  final EdgeInsets minimumPadding;

  const BaseScreen({
    super.key,
    this.title = '',
    this.minimumPadding = const EdgeInsets.all(16),
  });

  @override
  State<BaseScreen> createState() => BaseScreenState();
}

class BaseScreenState<T extends BaseScreen> extends State<T> with Navigation<T>, SnackBars<T> {
  bool get _isLoading => false;

  void alertUser(Object err) => showErrorSnackBar(err);

  @override
  @mustCallSuper
  Widget build(BuildContext context, [Widget? child]) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 247, 175, 230),
      appBar: DefaultAppBar(
        title: widget.title,
      ),
      body: SafeArea(
        minimum: widget.minimumPadding,
        child: _isLoading //
            ? const LoadingSpinner()
            : child ?? const _EmptyContent(),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Nothing here.'),
    );
  }
}
