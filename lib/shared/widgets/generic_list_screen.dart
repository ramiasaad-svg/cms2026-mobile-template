import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import 'content_card.dart';

/// Reusable list screen for any CMS content module.
class GenericListScreen extends StatefulWidget {
  final String title;
  final String routePrefix;
  final Future<ApiResponse> Function({int page, int pageSize}) fetchList;
  final String apiBaseUrl;

  const GenericListScreen({super.key, required this.title, required this.routePrefix, required this.fetchList, required this.apiBaseUrl});

  @override
  State<GenericListScreen> createState() => _GenericListScreenState();
}

class _GenericListScreenState extends State<GenericListScreen> {
  List<dynamic> _items = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await widget.fetchList(page: 1, pageSize: 50);
      if (res.success && res.data != null) {
        setState(() { _items = (res.data as Map)['items'] ?? []; _loading = false; });
      }
    } catch (_) { setState(() => _loading = false); }
  }

  String _img(String? p) => (p == null || p.isEmpty) ? '' : (p.startsWith('http') ? p : '${widget.apiBaseUrl.replaceAll('/api', '')}$p');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
            ? const Center(child: Text('No content available'))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length,
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  return ContentCard(
                    title: item['title'] ?? item['question'] ?? item['name'] ?? '',
                    subtitle: item['summary'] ?? item['answer'] ?? item['description'],
                    imageUrl: _img(item['imageUrl']),
                    date: item['publishDate'] ?? item['albumDate'] ?? item['eventDate'],
                    onTap: () {
                      final id = item['id'];
                      if (id != null) context.go('${widget.routePrefix}/$id');
                    },
                  );
                },
              ),
      ),
    );
  }
}
