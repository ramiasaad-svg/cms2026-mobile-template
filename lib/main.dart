import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_config.dart';
import 'core/api/api_client.dart';
import 'core/api/cms_api_service.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/cache_service.dart';
import 'shared/widgets/dynamic_drawer.dart';
import 'shared/widgets/generic_list_screen.dart';
import 'features/home/home_screen.dart';
import 'features/news/news_list_screen.dart';
import 'features/news/news_detail_screen.dart';
import 'features/contact/contact_screen.dart';
import 'features/search/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load config
  final config = await AppConfig.load();

  // Initialize services
  final cache = CacheService();
  await cache.init();

  final apiClient = ApiClient(config.api);
  apiClient.setLanguage(config.languages.defaultLang);

  final cmsApi = CmsApiService(apiClient);

  // Load menu (cache-first)
  List<MenuItem> menuItems = [];
  try {
    final cached = cache.getCachedMenu();
    if (cached != null) {
      menuItems = cached.map((m) => MenuItem.fromJson(m as Map<String, dynamic>)).toList();
    } else {
      final res = await cmsApi.getMenu();
      if (res.success && res.data != null) {
        final items = res.data as List;
        menuItems = items.map((m) => MenuItem.fromJson(m as Map<String, dynamic>)).toList();
        await cache.cacheMenu(items);
      }
    }
  } catch (_) {
    // Fallback: generate menu from config modules
    menuItems = config.modules.map((m) => MenuItem(title: m.name, route: m.route, icon: m.icon)).toList();
  }

  runApp(CmsApp(config: config, cmsApi: cmsApi, apiClient: apiClient, cache: cache, menuItems: menuItems));
}

class CmsApp extends StatefulWidget {
  final AppConfig config;
  final CmsApiService cmsApi;
  final ApiClient apiClient;
  final CacheService cache;
  final List<MenuItem> menuItems;

  const CmsApp({super.key, required this.config, required this.cmsApi, required this.apiClient, required this.cache, required this.menuItems});

  @override
  State<CmsApp> createState() => _CmsAppState();
}

class _CmsAppState extends State<CmsApp> {
  late String _currentLang;
  late GoRouter _router;

  @override
  void initState() {
    super.initState();
    _currentLang = widget.config.languages.defaultLang;
    _router = _buildRouter();
  }

  void _toggleLanguage() {
    setState(() {
      _currentLang = _currentLang == 'ar' ? 'en' : 'ar';
      widget.apiClient.setLanguage(_currentLang);
    });
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => _AppShell(
            config: widget.config, menuItems: widget.menuItems,
            currentLang: _currentLang, onLanguageToggle: _toggleLanguage, child: child,
          ),
          routes: [
            GoRoute(path: '/', builder: (ctx, state) => HomeScreen(config: widget.config)),
            GoRoute(path: '/news', builder: (ctx, state) => NewsListScreen(api: widget.cmsApi, apiBaseUrl: widget.config.api.baseUrl)),
            GoRoute(path: '/news/:id', builder: (ctx, state) =>
              NewsDetailScreen(api: widget.cmsApi, apiBaseUrl: widget.config.api.baseUrl, newsId: int.parse(state.pathParameters['id']!))),
            GoRoute(path: '/pages', builder: (ctx, state) => GenericListScreen(title: 'Pages', routePrefix: '/pages',
              fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getPagesList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
            GoRoute(path: '/blog', builder: (ctx, state) => GenericListScreen(title: 'Blog', routePrefix: '/blog',
              fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getBlogList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
            GoRoute(path: '/gallery', builder: (ctx, state) => GenericListScreen(title: 'Gallery', routePrefix: '/gallery',
              fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getGalleryList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
            GoRoute(path: '/faq', builder: (ctx, state) => GenericListScreen(title: 'FAQ', routePrefix: '/faq',
              fetchList: ({page = 1, pageSize = 50}) => widget.cmsApi.getFaqList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
            GoRoute(path: '/events', builder: (ctx, state) => GenericListScreen(title: 'Events', routePrefix: '/events',
              fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getSpeechesList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
            GoRoute(path: '/contact', builder: (ctx, state) => ContactScreen(api: widget.cmsApi)),
            GoRoute(path: '/search', builder: (ctx, state) => SearchScreen(api: widget.cmsApi)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme(widget.config.branding);
    final isRtl = widget.config.languages.isRtl(_currentLang);

    return MaterialApp.router(
      title: widget.config.app.appName,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.themeMode,
      routerConfig: _router,
      locale: Locale(_currentLang),
      supportedLocales: widget.config.languages.supported.map((l) => Locale(l)),
      builder: (context, child) => Directionality(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AppShell extends StatelessWidget {
  final AppConfig config;
  final List<MenuItem> menuItems;
  final String currentLang;
  final VoidCallback onLanguageToggle;
  final Widget child;

  const _AppShell({required this.config, required this.menuItems, required this.currentLang, required this.onLanguageToggle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DynamicDrawer(
        appName: config.app.appName,
        logoUrl: config.branding.logoUrl,
        primaryColor: config.branding.primary,
        menuItems: menuItems,
        currentLang: currentLang,
        onLanguageToggle: onLanguageToggle,
      ),
      body: child,
    );
  }
}
