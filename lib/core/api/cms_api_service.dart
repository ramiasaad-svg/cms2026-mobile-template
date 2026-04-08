import 'api_client.dart';

/// CMS API service — all endpoints used by the mobile app.
class CmsApiService {
  final ApiClient client;

  CmsApiService(this.client);

  // --- Mobile Config ---
  Future<ApiResponse> getSettings() => client.get('/mobile/settings');
  Future<ApiResponse> getMenu() => client.get('/mobile/menu');
  Future<ApiResponse> getLocalization(String lang) => client.get('/mobile/localization/$lang');
  Future<ApiResponse> getLatestVersion(String platform) => client.get('/mobile/app-version', params: {'platform': platform});

  // --- Content Modules ---
  Future<ApiResponse> getNewsList({int page = 1, int pageSize = 10}) =>
      client.get('/news', params: {'page': page, 'pageSize': pageSize, 'lang': client.currentLang});

  Future<ApiResponse> getNewsById(int id) => client.get('/news/$id');

  Future<ApiResponse> getPagesList({int page = 1, int pageSize = 10}) =>
      client.get('/pages', params: {'page': page, 'pageSize': pageSize, 'lang': client.currentLang});

  Future<ApiResponse> getPageById(int id) => client.get('/pages/$id');

  Future<ApiResponse> getBlogList({int page = 1, int pageSize = 10}) =>
      client.get('/blog', params: {'page': page, 'pageSize': pageSize, 'lang': client.currentLang});

  Future<ApiResponse> getBlogById(int id) => client.get('/blog/$id');

  Future<ApiResponse> getGalleryList({int page = 1, int pageSize = 10}) =>
      client.get('/gallery', params: {'page': page, 'pageSize': pageSize, 'lang': client.currentLang});

  Future<ApiResponse> getFaqList({int page = 1, int pageSize = 50}) =>
      client.get('/faq', params: {'page': page, 'pageSize': pageSize, 'lang': client.currentLang});

  Future<ApiResponse> getSpeechesList({int page = 1, int pageSize = 10}) =>
      client.get('/speeches', params: {'page': page, 'pageSize': pageSize, 'lang': client.currentLang});

  // --- Contact ---
  Future<ApiResponse> submitContact({required String fullName, required String email, required String subject, required String message, String? phone}) =>
      client.post('/contact', data: {'fullName': fullName, 'email': email, 'subject': subject, 'message': message, 'phone': phone});

  // --- AI Features ---
  Future<ApiResponse> semanticSearch(String query, {int topK = 10}) =>
      client.get('/search/semantic', params: {'q': query, 'topK': topK});

  Future<ApiResponse> getRecommendations(String entityType, int entityId, {int topK = 5}) =>
      client.get('/recommendations', params: {'entityType': entityType, 'entityId': entityId, 'topK': topK});

  // --- Device Registration ---
  Future<ApiResponse> registerDevice({required String deviceId, String? deviceName, String? platform, String? pushToken}) =>
      client.post('/mobile/devices', data: {'deviceId': deviceId, 'deviceName': deviceName, 'platform': platform, 'pushToken': pushToken});

  // --- Feedback ---
  Future<ApiResponse> submitFeedback({required String message, required int rating, String? deviceInfo}) =>
      client.post('/mobile/feedback', data: {'message': message, 'rating': rating, 'deviceInfo': deviceInfo});
}
