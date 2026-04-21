import 'package:flutter/material.dart';
import '../core/layout/app_layout.dart';

class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const ResponsiveBody({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > AppLayout.breakpoint;

        if (isWeb) {
          return Container(
            color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: SizedBox(
                width: AppLayout.maxContentWidth,
                child: child,
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
