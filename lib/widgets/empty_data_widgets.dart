import 'package:flutter/material.dart';

class EmptyDataView extends StatelessWidget {
  final String icon;
  final String text;
  final Widget? button;

  const EmptyDataView({
    super.key,
    this.icon = '',
    this.text = 'No data available~',
    this.button,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ),
          if (button != null) ...[
            const SizedBox(height: 24),
            button!,
          ],
        ],
      ),
    );
  }
}
