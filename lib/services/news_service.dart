import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/news.dart';

class NewsService {
  NewsService._();

  static final NewsService instance = NewsService._();

  Future<(List<NewsGroup>, int)> getNews() async {
    try {
      final response = await ApiClient.instance.dio.get(
        '${ApiEndpoints.newsList}?pageSize=20',
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final total = data['meta']?['totalCount'] as int? ?? 0;
        final posts = (data['data'] as List)
            .map((e) => NewsPost.fromJson(e as Map<String, dynamic>))
            .toList();
        return (_groupByMonth(posts), total);
      }
      return (<NewsGroup>[], 0);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<NewsGroup>> getAllNews() async {
    try {
      final response = await ApiClient.instance.dio.get(
        '${ApiEndpoints.newsList}?allNews=true',
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final posts = (data['data'] as List)
            .map((e) => NewsPost.fromJson(e as Map<String, dynamic>))
            .toList();
        return _groupByMonth(posts);
      }
      return [];
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<String> getNewsFullPost(int newsId) async {
    try {
      final response = await ApiClient.instance.dio.get(
        '${ApiEndpoints.newsItem}?newsId=$newsId',
        options: Options(responseType: ResponseType.plain),
      );
      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  List<NewsGroup> _groupByMonth(List<NewsPost> posts) {
    final groups = <String, List<NewsPost>>{};
    for (final post in posts) {
      final month = _monthName(post.datePublished);
      groups.putIfAbsent(month, () => []).add(post);
    }
    return groups.entries
        .map((e) => NewsGroup(monthName: e.key, posts: e.value))
        .toList();
  }

  String _monthName(String? date) {
    if (date == null || date.isEmpty) return '';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) {
      final parts = date.split('.');
      if (parts.length == 3) {
        final d = DateTime.tryParse('${parts[2]}-${parts[1]}-${parts[0]}');
        if (d != null) {
          return _capitalize(DateFormat('MMMM yyyy', 'ru_RU').format(d));
        }
      }
      return date;
    }
    return _capitalize(DateFormat('MMMM yyyy', 'ru_RU').format(parsed));
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  ApiException _extractError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException('Произошла ошибка');
  }
}
