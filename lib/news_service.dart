import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:urmat_hw_5_1/news_article_model.dart';

class NewsService {
  static const String _articlesUrl = 'https://newsapi.org/v2/everything';
  static const String _apiKey = '6542147a2ed14a5f9db8d2d84ddeaac8';

  static Future<List<NewsArticleModel>> fetchArticles({
    String topic = '',
  }) async {
    final searchTopic = topic.trim().isEmpty ? 'world' : topic.trim();
    final queryParameters = {
      'q': searchTopic,
      'pageSize': '10',
      'sortBy': 'publishedAt',
    };

    final uri = Uri.parse(
      _articlesUrl,
    ).replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: {'X-Api-Key': _apiKey});

    if (response.statusCode != 200) {
      throw Exception('Failed to load news');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final articles = data['articles'] as List<dynamic>? ?? [];

    return articles
        .whereType<Map<String, dynamic>>()
        .map(NewsArticleModel.fromJson)
        .toList();
  }
}
