import 'package:flutter/material.dart';
import 'package:mpx_1635/pages/home_page.dart';
import 'package:mpx_1635/pages/media_page.dart';
import 'package:mpx_1635/pages/library_page.dart';

class NavigationDrawerWidget extends StatelessWidget {
    const NavigationDrawerWidget({super.key});

    final EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20);

    @override
    Widget build(BuildContext context) {
        const bool isCollapsed = false;

        return Drawer(
            child: Container(
                color: const Color(0xFF262AAA),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        Container(
                            padding: padding.add(const EdgeInsets.symmetric(vertical: 24)),
                            child: Row(
                                children: [
                                    const CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            'https://avatars.githubusercontent.com/u/160686513?v=4',
                                        ),
                                    ),
                                    const SizedBox(width: 16),
                                    if (!isCollapsed)
                                        const Text(
                                            'Mpx',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                ],
                            ),
                        ),
                        const Divider(color: Colors.white70, height: 1),
                        _buildItem(
                            context,
                            icon: Icons.home,
                            label: 'Home',
                            onTap: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomePage()),
                                );
                            },
                        ),
                        _buildItem(
                            context,
                            icon: Icons.music_note,
                            label: 'Media',
                            onTap: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MediaPage()),
                                );
                            },
                        ),
                        _buildItem(
                            context,
                            icon: Icons.library_books,
                            label: 'Library',
                            onTap: () {
                                Navigator.pop(context);
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LibraryPage()),
                                );
                            },
                        ),
                    ],
                ),
            ),
        );
    }

    Widget buildCollapseIcon(BuildContext context, bool isCollapsed){
      final double iconSize = 24;
      final icon = isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios;

      return Container(
        width: iconSize,
        height: iconSize,
        child: Icon(icon, color: Colors.white70),
      );
    }

    Widget _buildItem(
        BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
    }) {
        return ListTile(
            leading: Icon(icon, color: Colors.white70),
            title: Text(label, style: const TextStyle(color: Colors.white70)),
            onTap: onTap,
        );
    }
}