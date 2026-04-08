import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/config/app_config.dart';
import 'core/api/api_client.dart';
import 'core/api/cms_api_service.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/cache_service.dart';
import 'core/services/crash_reporter.dart';
import 'core/services/analytics_service.dart';
import 'core/services/config_refresh_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/version_check_service.dart';
import 'core/services/auth_service.dart';
import 'shared/widgets/dynamic_drawer.dart';
import 'shared/widgets/generic_list_screen.dart';
import 'shared/widgets/responsive_layout.dart';
import 'features/home/home_screen.dart';
import 'features/news/news_list_screen.dart';
import 'features/news/news_detail_screen.dart';
import 'features/contact/contact_screen.dart';
import 'features/search/search_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/update/update_required_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase + Crashlytics
  await Firebase.initializeApp();
  CrashReporter.init();

  // 2. Config
  final config = await AppConfig.load();

  // 3. Services
  final cache = CacheService();
  await cache.init();
  final apiClient = ApiClient(config.api);
  apiClient.setLanguage(config.languages.defaultLang);
  final cmsApi = CmsApiService(apiClient);

  // 4. Auth
  final auth = AuthService(apiClient);
  await auth.init();

  // 5. Push notifications
  if (config.features.pushNotifications) {
    final token = await NotificationService().init();
    if (token != null) {
      try { await cmsApi.registerDevice(deviceId: token, platform: 'flutter', pushToken: token); } catch (_) {}
    }
  }

  // 6. Version check
  final pkg = await PackageInfo.fromPlatform();
  final updateInfo = await VersionCheckService(api: cmsApi, currentVersion: pkg.version).checkForUpdate();

  // 7. Menu
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
    menuItems = config.modules.map((m) => MenuItem(title: m.name, route: m.route, icon: m.icon)).toList();
  }

  // 8. OTA config refresh (non-blocking — updates menu/branding in background)
  final configRefresh = ConfigRefreshService(api: cmsApi, cache: cache, originalConfig: config);

  // 9. Set analytics user ID if logged in
  if (auth.isLoggedIn && auth.userName != null) {
    AnalyticsService.setUserId(auth.userName);
    CrashReporter.setUserId(auth.userName!);
  }

  runApp(CmsApp(config: config, cmsApi: cmsApi, apiClient: apiClient, cache: cache,
    auth: auth, menuItems: menuItems, updateInfo: updateInfo, configRefresh: configRefresh));
}

class CmsApp extends StatefulWidget {
  final AppConfig config;
  final CmsApiService cmsApi;
  final ApiClient apiClient;
  final CacheService cache;
  final AuthService auth;
  final List<MenuItem> menuItems;
  final VersionInfo? updateInfo;
  final ConfigRefreshService configRefresh;

  const CmsApp({super.key, required this.config, required this.cmsApi, required this.apiClient,
    required this.cache, required this.auth, required this.menuItems, this.updateInfo, required this.configRefresh});

  @override
  State<CmsApp> createState() => _CmsAppState();
}

class _CmsAppState extends State<CmsApp> {
  late String _lang;
  late GoRouter _router;
  late List<MenuItem> _menuItems;

  @override
  void initState() {
    super.initState();
    _lang = widget.config.languages.defaultLang;
    _menuItems = widget.menuItems;
    NotificationService().onNotificationTap = (route) { if (route != null) _router.go(route); };
    _router = _buildRouter();
    _runOtaRefresh();
  }

  /// OTA config refresh — runs in background, updates UI without restart.
  Future<void> _runOtaRefresh() async {
    final update = await widget.configRefresh.refreshIfNeeded();
    if (update != null && update.hasChanges) {
      if (update.menuChanged && update.newMenu != null) {
        setState(() {
          _menuItems = update.newMenu!.map((m) => MenuItem.fromJson(m as Map<String, dynamic>)).toList();
        });
      }
      // Branding changes require theme rebuild — setState triggers build()
      if (update.brandingChanged) setState(() {});
    }
  }

  void _toggleLang() {
    AnalyticsService.logLanguageChange(_lang == 'ar' ? 'en' : 'ar');
    setState(() { _lang = _lang == 'ar' ? 'en' : 'ar'; widget.apiClient.setLanguage(_lang); });
  }

  GoRouter _buildRouter() => GoRouter(initialLocation: '/', routes: [
    ShellRoute(
      builder: (ctx, state, child) {
        if (widget.updateInfo != null && widget.updateInfo!.isMandatory) {
          return UpdateRequiredScreen(versionInfo: widget.updateInfo!, branding: widget.config.branding);
        }
        final isTablet = ResponsiveLayout.isTablet(ctx);
        if (isTablet) {
          return TabletShell(sideNav: _sideNav(), content: child);
        }
        return Scaffold(
          drawer: DynamicDrawer(appName: widget.config.app.appName, logoUrl: widget.config.branding.logoUrl,
            primaryColor: widget.config.branding.primary, menuItems: _menuItems,
            currentLang: _lang, onLanguageToggle: _toggleLang),
          body: child,
        );
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => HomeScreen(config: widget.config)),
        GoRoute(path: '/news', builder: (_, __) => NewsListScreen(api: widget.cmsApi, apiBaseUrl: widget.config.api.baseUrl)),
        GoRoute(path: '/news/:id', builder: (_, s) => NewsDetailScreen(api: widget.cmsApi, apiBaseUrl: widget.config.api.baseUrl, newsId: int.parse(s.pathParameters['id']!))),
        GoRoute(path: '/pages', builder: (_, __) => GenericListScreen(title: 'Pages', routePrefix: '/pages', fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getPagesList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
        GoRoute(path: '/blog', builder: (_, __) => GenericListScreen(title: 'Blog', routePrefix: '/blog', fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getBlogList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
        GoRoute(path: '/gallery', builder: (_, __) => GenericListScreen(title: 'Gallery', routePrefix: '/gallery', fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getGalleryList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
        GoRoute(path: '/faq', builder: (_, __) => GenericListScreen(title: 'FAQ', routePrefix: '/faq', fetchList: ({page = 1, pageSize = 50}) => widget.cmsApi.getFaqList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
        GoRoute(path: '/events', builder: (_, __) => GenericListScreen(title: 'Events', routePrefix: '/events', fetchList: ({page = 1, pageSize = 10}) => widget.cmsApi.getSpeechesList(page: page, pageSize: pageSize), apiBaseUrl: widget.config.api.baseUrl)),
        GoRoute(path: '/contact', builder: (_, __) => ContactScreen(api: widget.cmsApi)),
        GoRoute(path: '/search', builder: (_, __) => SearchScreen(api: widget.cmsApi)),
        GoRoute(path: '/login', builder: (_, __) => LoginScreen(auth: widget.auth, branding: widget.config.branding, onLoginSuccess: () => _router.go('/'))),
      ],
    ),
  ]);

  Widget _sideNav() => ListView(children: [
    DrawerHeader(decoration: BoxDecoration(color: widget.config.branding.primary),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.apps, size: 40, color: Colors.white), const SizedBox(height: 8),
        Text(widget.config.app.appName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ])),
    ..._menuItems.map((m) => ListTile(leading: Icon(m.iconData), title: Text(m.title), onTap: () => _router.go(m.route))),
    const Divider(),
    ListTile(leading: const Icon(Icons.search), title: const Text('Search'), onTap: () => _router.go('/search')),
    ListTile(leading: const Icon(Icons.language), title: Text(_lang == 'ar' ? 'English' : 'العربية'), onTap: _toggleLang),
  ]);

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme(widget.config.branding);
    return MaterialApp.router(
      title: widget.config.app.appName,
      theme: theme.lightTheme, darkTheme: theme.darkTheme, themeMode: theme.themeMode,
      routerConfig: _router, locale: Locale(_lang),
      supportedLocales: widget.config.languages.supported.map((l) => Locale(l)),
      builder: (ctx, child) => Directionality(
        textDirection: widget.config.languages.isRtl(_lang) ? TextDirection.rtl : TextDirection.ltr,
        child: child!),
      debugShowCheckedModeBanner: false,
    );
  }
}
