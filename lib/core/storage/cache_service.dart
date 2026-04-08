import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Offline cache using Hive. Stores menu, localization, and recent content.
class CacheService {
  static const _cacheBoxName = 'cms_cache';
  static const _menuKey = 'menu';
  static const _maxAge = Duration(days: 7);

  late Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_cacheBoxName);
  }

  // --- Menu ---
  Future<void> cacheMenu(List<dynamic> menu) async {
    await _box.put(_menuKey, json.encode({'data': menu, 'cachedAt': DateTime.now().toIso8601String()}));
  }

  List<dynamic>? getCachedMenu() {
    final raw = _box.get(_menuKey);
    if (raw == null) return null;
    final cached = json.decode(raw);
    if (_isExpired(cached['cachedAt'])) return null;
    return cached['data'];
  }

  // --- Localization ---
  Future<void> cacheLocalization(String lang, Map<String, dynamic> data) async {
    await _box.put('locale_$lang', json.encode({'data': data, 'cachedAt': DateTime.now().toIso8601String()}));
  }

  Map<String, dynamic>? getCachedLocalization(String lang) {
    final raw = _box.get('locale_$lang');
    if (raw == null) return null;
    final cached = json.decode(raw);
    if (_isExpired(cached['cachedAt'])) return null;
    return Map<String, dynamic>.from(cached['data']);
  }

  // --- Generic Content Cache ---
  Future<void> cacheContent(String key, dynamic data) async {
    await _box.put('content_$key', json.encode({'data': data, 'cachedAt': DateTime.now().toIso8601String()}));
  }

  dynamic getCachedContent(String key) {
    final raw = _box.get('content_$key');
    if (raw == null) return null;
    final cached = json.decode(raw);
    if (_isExpired(cached['cachedAt'], maxAge: const Duration(hours: 1))) return null;
    return cached['data'];
  }

  Future<void> clearAll() async => await _box.clear();

  bool _isExpired(String? cachedAt, {Duration? maxAge}) {
    if (cachedAt == null) return true;
    final cached = DateTime.tryParse(cachedAt);
    if (cached == null) return true;
    return DateTime.now().difference(cached) > (maxAge ?? _maxAge);
  }
}
