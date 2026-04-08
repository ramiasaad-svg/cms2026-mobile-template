import 'dart:io';
import '../api/cms_api_service.dart';

class VersionInfo {
  final String latestVersion;
  final bool isMandatory;
  final String? releaseNotes;
  final String? downloadUrl;

  VersionInfo({required this.latestVersion, required this.isMandatory, this.releaseNotes, this.downloadUrl});
}

class VersionCheckService {
  final CmsApiService api;
  final String currentVersion;

  VersionCheckService({required this.api, required this.currentVersion});

  Future<VersionInfo?> checkForUpdate() async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final res = await api.getLatestVersion(platform);
      if (!res.success || res.data == null) return null;

      final data = res.data as Map<String, dynamic>;
      final latest = data['version'] as String? ?? currentVersion;

      if (_compareVersions(latest, currentVersion) > 0) {
        return VersionInfo(
          latestVersion: latest,
          isMandatory: data['isMandatory'] as bool? ?? false,
          releaseNotes: data['releaseNotes'] as String?,
          downloadUrl: data['downloadUrl'] as String?,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns positive if a > b, negative if a < b, 0 if equal.
  int _compareVersions(String a, String b) {
    final aParts = a.split('.').map(int.tryParse).toList();
    final bParts = b.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final av = i < aParts.length ? (aParts[i] ?? 0) : 0;
      final bv = i < bParts.length ? (bParts[i] ?? 0) : 0;
      if (av != bv) return av - bv;
    }
    return 0;
  }
}
