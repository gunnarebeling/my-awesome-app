import 'package:flutter/material.dart';
import 'package:my_awesome_app/widgets/critic_report_dialog.dart';

class CriticReportButton extends StatelessWidget {
  const CriticReportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.help_outline,
        color: Colors.black,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => const CriticReportDialog(),
        );
      },
    );
  }
}
