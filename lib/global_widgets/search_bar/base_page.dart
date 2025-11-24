import 'package:flutter/material.dart';
import 'package:mpx_1635/global_widgets/search_bar/global_search_bar.dart';
import 'package:mpx_1635/scr/sidebar/widgets/nav_bar/navigation_drawer.dart';

class BasePage extends StatelessWidget {
  final Widget child;
  final Function(String) onSearch;
  final String title;

  const BasePage({
    super.key,
    required this.child,
    required this.onSearch,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const NavigationDrawerWidget(),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: GlobalSearchBar(onSearch: onSearch),
        ),
      ),
      body: child,
    );
  }
}
