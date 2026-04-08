import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';

class AppConfig {
  final AppInfo app;
  final ApiConfig api;
  final BrandingConfig branding;
  final List<ModuleConfig> modules;
  final LanguageConfig languages;
  final FirebaseConfig firebase;
  final FeatureFlags features;

  AppConfig({
    required this.app,
    required this.api,
    required this.branding,
    required this.modules,
    required this.languages,
    required this.firebase,
    required this.features,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      app: AppInfo.fromJson(json['app'] ?? {}),
      api: ApiConfig.fromJson(json['api'] ?? {}),
      branding: BrandingConfig.fromJson(json['branding'] ?? {}),
      modules: (json['modules'] as List? ?? [])
          .map((m) => ModuleConfig.fromJson(m))
          .where((m) => m.enabled)
          .toList()
        ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      languages: LanguageConfig.fromJson(json['languages'] ?? {}),
      firebase: FirebaseConfig.fromJson(json['firebase'] ?? {}),
      features: FeatureFlags.fromJson(json['features'] ?? {}),
    );
  }

  static Future<AppConfig> load() async {
    final jsonStr = await rootBundle.loadString('assets/config/app_config.json');
    return AppConfig.fromJson(json.decode(jsonStr));
  }
}

class AppInfo {
  final String appId;
  final String appName;
  final String? appNameAr;
  final String versionName;
  final int versionCode;

  AppInfo({required this.appId, required this.appName, this.appNameAr, required this.versionName, required this.versionCode});

  factory AppInfo.fromJson(Map<String, dynamic> j) => AppInfo(
    appId: j['appId'] ?? '', appName: j['appName'] ?? 'CMS2026',
    appNameAr: j['appNameAr'], versionName: j['versionName'] ?? '1.0.0', versionCode: j['versionCode'] ?? 1,
  );
}

class ApiConfig {
  final String baseUrl;
  final String mobileEndpoint;
  final int timeout;
  final int retryCount;

  ApiConfig({required this.baseUrl, this.mobileEndpoint = '/mobile', this.timeout = 30000, this.retryCount = 3});

  factory ApiConfig.fromJson(Map<String, dynamic> j) => ApiConfig(
    baseUrl: j['baseUrl'] ?? '', mobileEndpoint: j['mobileEndpoint'] ?? '/mobile',
    timeout: j['timeout'] ?? 30000, retryCount: j['retryCount'] ?? 3,
  );

  String get fullMobileUrl => '$baseUrl$mobileEndpoint';
}

class BrandingConfig {
  final String primaryColor;
  final String secondaryColor;
  final String? accentColor;
  final String themeMode;
  final String? logoUrl;
  final String? splashUrl;
  final String? fontFamily;

  BrandingConfig({required this.primaryColor, required this.secondaryColor, this.accentColor,
    this.themeMode = 'light', this.logoUrl, this.splashUrl, this.fontFamily});

  factory BrandingConfig.fromJson(Map<String, dynamic> j) => BrandingConfig(
    primaryColor: j['primaryColor'] ?? '#2f7995', secondaryColor: j['secondaryColor'] ?? '#1d586f',
    accentColor: j['accentColor'], themeMode: j['themeMode'] ?? 'light',
    logoUrl: j['logoUrl'], splashUrl: j['splashUrl'], fontFamily: j['fontFamily'],
  );

  Color get primary => _hexToColor(primaryColor);
  Color get secondary => _hexToColor(secondaryColor);
  Color get accent => _hexToColor(accentColor ?? '#ff9800');

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}

class ModuleConfig {
  final String name;
  final bool enabled;
  final String? icon;
  final String route;
  final int displayOrder;

  ModuleConfig({required this.name, required this.enabled, this.icon, required this.route, this.displayOrder = 0});

  factory ModuleConfig.fromJson(Map<String, dynamic> j) => ModuleConfig(
    name: j['name'] ?? '', enabled: j['enabled'] ?? true,
    icon: j['icon'], route: j['route'] ?? '/${j['name']}', displayOrder: j['displayOrder'] ?? 0,
  );
}

class LanguageConfig {
  final String defaultLang;
  final List<String> supported;
  final List<String> rtlLanguages;

  LanguageConfig({required this.defaultLang, required this.supported, required this.rtlLanguages});

  factory LanguageConfig.fromJson(Map<String, dynamic> j) => LanguageConfig(
    defaultLang: j['default'] ?? 'ar',
    supported: List<String>.from(j['supported'] ?? ['ar', 'en']),
    rtlLanguages: List<String>.from(j['rtlLanguages'] ?? ['ar']),
  );

  bool isRtl(String lang) => rtlLanguages.contains(lang);
}

class FirebaseConfig {
  final String? projectId;
  final String? senderId;

  FirebaseConfig({this.projectId, this.senderId});

  factory FirebaseConfig.fromJson(Map<String, dynamic> j) => FirebaseConfig(
    projectId: j['projectId'], senderId: j['senderId'],
  );

  bool get isConfigured => projectId != null && projectId!.isNotEmpty;
}

class FeatureFlags {
  final bool pushNotifications;
  final bool darkMode;
  final bool offlineMode;
  final bool semanticSearch;
  final bool recommendations;
  final bool inAppFeedback;

  FeatureFlags({this.pushNotifications = true, this.darkMode = true, this.offlineMode = true,
    this.semanticSearch = true, this.recommendations = true, this.inAppFeedback = true});

  factory FeatureFlags.fromJson(Map<String, dynamic> j) => FeatureFlags(
    pushNotifications: j['pushNotifications'] ?? true, darkMode: j['darkMode'] ?? true,
    offlineMode: j['offlineMode'] ?? true, semanticSearch: j['semanticSearch'] ?? true,
    recommendations: j['recommendations'] ?? true, inAppFeedback: j['inAppFeedback'] ?? true,
  );
}
