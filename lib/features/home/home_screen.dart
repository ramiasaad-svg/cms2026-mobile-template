import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_config.dart';

class HomeScreen extends StatelessWidget {
  final AppConfig config;

  const HomeScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final modules = config.modules;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(config.app.appName),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [config.branding.primary, config.branding.secondary],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final mod = modules[i];
                  return _ModuleCard(module: mod, primaryColor: config.branding.primary,
                    onTap: () => context.go(mod.route));
                },
                childCount: modules.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final ModuleConfig module;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ModuleCard({required this.module, required this.primaryColor, required this.onTap});

  static const _iconMap = <String, IconData>{
    'newspaper': Icons.newspaper, 'description': Icons.description,
    'photo_library': Icons.photo_library, 'edit_note': Icons.edit_note,
    'mail': Icons.mail, 'help': Icons.help, 'event': Icons.event,
    'work': Icons.work, 'library_books': Icons.library_books,
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_iconMap[module.icon] ?? Icons.article, size: 40, color: primaryColor),
            const SizedBox(height: 8),
            Text(module.name[0].toUpperCase() + module.name.substring(1),
              style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
