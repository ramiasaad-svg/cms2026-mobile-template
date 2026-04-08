import 'package:dio/dio.dart';
import '../config/app_config.dart';

class ApiClient {
  late final Dio _dio;
  final ApiConfig config;
  String _lang = 'ar';
  String? _token;

  ApiClient(this.config) {
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: Duration(milliseconds: config.timeout),
      receiveTimeout: Duration(milliseconds: config.timeout),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Accept-Language'] = _lang;
        if (_token != null) options.headers['Authorization'] = 'Bearer $_token';
        handler.next(options);
      },
      onError: (error, handler) {
        // TODO: handle 401 refresh, network errors
        handler.next(error);
      },
    ));
  }

  void setLanguage(String lang) => _lang = lang;
  void setToken(String? token) => _token = token;
  String get currentLang => _lang;

  Future<ApiResponse<T>> get<T>(String path, {Map<String, dynamic>? params, T Function(dynamic)? fromJson}) async {
    final response = await _dio.get(path, queryParameters: params);
    return ApiResponse.fromJson(response.data, fromJson);
  }

  Future<ApiResponse<T>> post<T>(String path, {dynamic data, T Function(dynamic)? fromJson}) async {
    final response = await _dio.post(path, data: data);
    return ApiResponse.fromJson(response.data, fromJson);
  }
}

class ApiResponse<T> {
  final bool success;
  final int statusCode;
  final String? message;
  final T? data;
  final List<String>? errors;
  final PaginationMeta? pagination;

  ApiResponse({required this.success, required this.statusCode, this.message, this.data, this.errors, this.pagination});

  factory ApiResponse.fromJson(Map<String, dynamic> json, [T Function(dynamic)? fromJson]) {
    return ApiResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'],
      data: fromJson != null && json['data'] != null ? fromJson(json['data']) : json['data'] as T?,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      pagination: json['pagination'] != null ? PaginationMeta.fromJson(json['pagination']) : null,
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  PaginationMeta({required this.currentPage, required this.pageSize, required this.totalCount, required this.totalPages});

  factory PaginationMeta.fromJson(Map<String, dynamic> j) => PaginationMeta(
    currentPage: j['currentPage'] ?? 1, pageSize: j['pageSize'] ?? 10,
    totalCount: j['totalCount'] ?? 0, totalPages: j['totalPages'] ?? 0,
  );
}
