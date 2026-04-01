import 'package:flutter/material.dart';
import 'responsive_navigation.dart';

class ResponsiveScaffold extends StatelessWidget {
  final int currentIndex;
  final List<Widget> pages;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Function(int) onNavigationChanged;

  const ResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.pages,
    required this.onNavigationChanged,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return Scaffold(
            key: scaffoldKey,
            appBar: appBar,
            body: pages[currentIndex],
            drawer: drawer,
            bottomNavigationBar: ResponsiveNavigation(
              selectedIndex: currentIndex,
              onDestinationSelected: onNavigationChanged,
            ),
            floatingActionButton: floatingActionButton,
          );
        } else {
          return Scaffold(
            key: scaffoldKey,
            appBar: appBar,
            body: Row(
              children: [
                ResponsiveNavigation(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onNavigationChanged,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: pages[currentIndex],
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}
