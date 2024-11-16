import 'package:flutter/material.dart';
import 'package:flutter_app_base/widgets/buttons/critic_report_button.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final List<Widget> actions;

  const DefaultAppBar({
    super.key,
    this.title = '',
    this.centerTitle = true,
    this.actions = const [CriticReportButton()],
  });

  static const double appBarHeight = 60;

  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      centerTitle: centerTitle,
    );
  }
}
