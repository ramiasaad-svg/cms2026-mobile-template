import 'package:flutter/material.dart';
import '../../core/services/version_check_service.dart';
import '../../core/config/app_config.dart';

class UpdateRequiredScreen extends StatelessWidget {
  final VersionInfo versionInfo;
  final BrandingConfig branding;

  const UpdateRequiredScreen({super.key, required this.versionInfo, required this.branding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [branding.primary, branding.secondary]),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.system_update, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Update Required', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Version ${versionInfo.latestVersion} is available', style: TextStyle(color: Colors.grey[600])),
                  if (versionInfo.releaseNotes != null) ...[
                    const SizedBox(height: 16),
                    Text(versionInfo.releaseNotes!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                  ],
                  const SizedBox(height: 24),
                  if (versionInfo.downloadUrl != null)
                    SizedBox(width: double.infinity, height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Launch URL to store
                          // url_launcher package can be added for this
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Update Now'),
                        style: ElevatedButton.styleFrom(backgroundColor: branding.primary, foregroundColor: Colors.white),
                      )),
                  if (versionInfo.isMandatory) ...[
                    const SizedBox(height: 12),
                    Text('This update is mandatory.', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600)),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
