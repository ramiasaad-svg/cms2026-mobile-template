import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/cms_api_service.dart';
import '../../shared/widgets/content_card.dart';

class NewsListScreen extends StatefulWidget {
  final CmsApiService api;
  final String apiBaseUrl;

  const NewsListScreen({super.key, required this.api, required this.apiBaseUrl});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) { _page = 1; _hasMore = true; }
    setState(() => _loading = true);

    try {
      final res = await widget.api.getNewsList(page: _page, pageSize: 10);
      if (res.success && res.data != null) {
        final items = res.data['items'] as List? ?? [];
        setState(() {
          if (refresh) _items = items;
          else _items = [..._items, ...items];
          _hasMore = (res.data['pagination']?['hasNext'] ?? false) as bool;
          _loading = false;
        });
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('News')),
      body: RefreshIndicator(
        onRefresh: () => _loadData(refresh: true),
        child: _loading && _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
            ? const Center(child: Text('No news available'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length + (_hasMore ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if (i >= _items.length) {
                    _page++; _loadData();
                    return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)));
                  }
                  final item = _items[i];
                  return ContentCard(
                    title: item['title'] ?? '',
                    subtitle: item['summary'],
                    imageUrl: _imageUrl(item['imageUrl']),
                    date: item['publishDate'],
                    onTap: () => context.go('/news/${item['id']}'),
                  );
                },
              ),
      ),
    );
  }
}
