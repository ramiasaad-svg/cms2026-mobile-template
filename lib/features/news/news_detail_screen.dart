import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/api/cms_api_service.dart';

class NewsDetailScreen extends StatefulWidget {
  final CmsApiService api;
  final String apiBaseUrl;
  final int newsId;

  const NewsDetailScreen({super.key, required this.api, required this.apiBaseUrl, required this.newsId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await widget.api.getNewsById(widget.newsId);
      if (res.success && res.data != null) {
        setState(() { _data = res.data as Map<String, dynamic>; _loading = false; });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${widget.apiBaseUrl.replaceAll('/api', '')}$path';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_data == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Not found')));

    final translations = _data!['translations'] as List? ?? [];
    final t = translations.isNotEmpty ? translations[0] : <String, dynamic>{};
    final title = t['title'] ?? '';
    final content = t['content'] ?? '';
    final imageUrl = _data!['imageUrl'];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: imageUrl != null ? 250 : 0,
            pinned: true,
            flexibleSpace: imageUrl != null ? FlexibleSpaceBar(
              background: CachedNetworkImage(imageUrl: _imageUrl(imageUrl), fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: Theme.of(context).primaryColor)),
            ) : null,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_data!['publishDate'] != null)
                    Text((_data!['publishDate'] as String).split('T').first,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  const Divider(height: 24),
                  Html(data: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
