import '../api/cms_api_service.dart';
import '../config/app_config.dart';
import '../storage/cache_service.dart';

/// Over-the-air configuration refresh — updates branding, feature flags, modules, and menu
/// without requiring a new app build.
///
/// Checks every 24 hours. Falls back to cached data if API fails.
class ConfigRefreshService {
  final CmsApiService api;
  final CacheService cache;
  final AppConfig originalConfig;

  static const _lastRefreshKey = 'lastConfigRefresh';
  static const _settingsKey = 'ota_settings';
  static const _refreshInterval = Duration(hours: 24);

  ConfigRefreshService({required this.api, required this.cache, required this.originalConfig});

  /// Check if a refresh is needed (24h since last refresh).
  bool get needsRefresh {
    final last = cache.getCachedContent(_lastRefreshKey);
    if (last == null) return true;
    final lastTime = DateTime.tryParse(last as String);
    if (lastTime == null) return true;
    return DateTime.now().difference(lastTime) > _refreshInterval;
  }

  /// Attempt to refresh configuration from CMS API.
  /// Returns an [OtaUpdate] if anything changed, null if no changes or refresh not needed.
  Future<OtaUpdate?> refreshIfNeeded() async {
    if (!needsRefresh) return null;
    return await forceRefresh();
  }

  /// Force refresh regardless of interval.
  Future<OtaUpdate?> forceRefresh() async {
    try {
      final changes = OtaUpdate();

      // 1. Fetch settings (branding, feature flags)
      final settingsRes = await api.getSettings();
      if (settingsRes.success && settingsRes.data != null) {
        final settings = settingsRes.data as Map<String, dynamic>;
        await cache.cacheContent(_settingsKey, settings);

        // Check for branding changes
        final newPrimary = settings['primaryColor'] as String?;
        if (newPrimary != null && newPrimary != originalConfig.branding.primaryColor) {
          changes.brandingChanged = true;
          changes.newPrimaryColor = newPrimary;
          changes.newSecondaryColor = settings['secondaryColor'] as String?;
          changes.newThemeMode = settings['themeMode'] as String?;
        }
      }

      // 2. Fetch menu
      final menuRes = await api.getMenu();
      if (menuRes.success && menuRes.data != null) {
        final menuItems = menuRes.data as List;
        final cachedMenu = cache.getCachedMenu();

        if (cachedMenu == null || menuItems.length != cachedMenu.length) {
          changes.menuChanged = true;
          changes.newMenu = menuItems;
        }
        await cache.cacheMenu(menuItems);
      }

      // 3. Fetch active languages (check if new ones added)
      // Languages rarely change, but we cache them for localization refresh

      // 4. Update last refresh timestamp
      await cache.cacheContent(_lastRefreshKey, DateTime.now().toIso8601String());

      return changes.hasChanges ? changes : null;
    } catch (e) {
      // API failed — keep previous configuration (safety requirement)
      return null;
    }
  }

  /// Get cached OTA settings (for reading between refreshes).
  Map<String, dynamic>? get cachedSettings {
    final data = cache.getCachedContent(_settingsKey);
    return data is Map<String, dynamic> ? data : null;
  }
}

/// Describes what changed during an OTA config refresh.
class OtaUpdate {
  bool brandingChanged = false;
  String? newPrimaryColor;
  String? newSecondaryColor;
  String? newThemeMode;

  bool menuChanged = false;
  List<dynamic>? newMenu;

  bool get hasChanges => brandingChanged || menuChanged;

  @override
  String toString() => 'OtaUpdate(branding=$brandingChanged, menu=$menuChanged)';
}
