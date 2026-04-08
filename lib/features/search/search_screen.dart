import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/cms_api_service.dart';

class SearchScreen extends StatefulWidget {
  final CmsApiService api;

  const SearchScreen({super.key, required this.api});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() { _loading = true; _searched = true; });

    try {
      final res = await widget.api.semanticSearch(query);
      if (res.success && res.data != null) {
        setState(() { _results = res.data as List; _loading = false; });
      }
    } catch (_) {
      setState(() { _results = []; _loading = false; });
    }
  }

  void _navigateToResult(Map<String, dynamic> item) {
    final type = item['entityType'] ?? '';
    final id = item['entityId'] ?? 0;
    switch (type) {
      case 'news': context.go('/news/$id'); break;
      case 'page': context.go('/pages/$id'); break;
      case 'blog': context.go('/blog/$id'); break;
      case 'faq': context.go('/faq'); break;
      default: break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Search by meaning...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
            ),
          ),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (!_loading && _searched && _results.isEmpty)
            const Expanded(child: Center(child: Text('No results found'))),
          if (!_loading && _results.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final item = _results[i] as Map<String, dynamic>;
                  final score = ((item['score'] ?? 0) * 100).toStringAsFixed(0);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text('$score%', style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor)),
                    ),
                    title: Text(item['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(item['snippet'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: Chip(label: Text(item['entityType'] ?? '', style: const TextStyle(fontSize: 10))),
                    onTap: () => _navigateToResult(item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
