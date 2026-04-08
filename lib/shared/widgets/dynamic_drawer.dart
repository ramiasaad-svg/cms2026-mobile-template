import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuItem {
  final String title;
  final String route;
  final String? icon;

  MenuItem({required this.title, required this.route, this.icon});

  factory MenuItem.fromJson(Map<String, dynamic> j) => MenuItem(
    title: j['moduleName'] ?? j['title'] ?? '',
    route: j['route'] ?? '/',
    icon: j['icon'],
  );

  IconData get iconData => _iconMap[icon] ?? Icons.article;

  static const _iconMap = <String, IconData>{
    'newspaper': Icons.newspaper, 'description': Icons.description,
    'photo_library': Icons.photo_library, 'edit_note': Icons.edit_note,
    'mail': Icons.mail, 'help': Icons.help, 'event': Icons.event,
    'work': Icons.work, 'library_books': Icons.library_books,
    'home': Icons.home, 'search': Icons.search, 'settings': Icons.settings,
  };
}

class DynamicDrawer extends StatelessWidget {
  final String appName;
  final String? logoUrl;
  final Color primaryColor;
  final List<MenuItem> menuItems;
  final String currentLang;
  final VoidCallback onLanguageToggle;

  const DynamicDrawer({
    super.key, required this.appName, this.logoUrl, required this.primaryColor,
    required this.menuItems, required this.currentLang, required this.onLanguageToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (logoUrl != null && logoUrl!.startsWith('assets'))
                  Image.asset(logoUrl!, height: 48, errorBuilder: (_, __, ___) => const Icon(Icons.apps, size: 48, color: Colors.white))
                else
                  const Icon(Icons.apps, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(appName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () { Navigator.pop(context); context.go('/'); },
          ),
          const Divider(height: 1),
          // Dynamic menu items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: menuItems.length,
              itemBuilder: (ctx, i) {
                final item = menuItems[i];
                return ListTile(
                  leading: Icon(item.iconData),
                  title: Text(item.title),
                  onTap: () { Navigator.pop(context); context.go(item.route); },
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Search
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search'),
            onTap: () { Navigator.pop(context); context.go('/search'); },
          ),
          // Language toggle
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(currentLang == 'ar' ? 'English' : 'العربية'),
            onTap: () { Navigator.pop(context); onLanguageToggle(); },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
