import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? date;
  final VoidCallback? onTap;

  const ContentCard({super.key, required this.title, this.subtitle, this.imageUrl, this.date, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(height: 180, color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                errorWidget: (_, __, ___) => Container(height: 180, color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  if (date != null) ...[
                    const SizedBox(height: 8),
                    Text(date!.split('T').first, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
