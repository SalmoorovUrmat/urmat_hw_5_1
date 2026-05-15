import 'dart:async';

import 'package:flutter/material.dart';
import 'package:urmat_hw_5_1/news_article_model.dart';
import 'package:urmat_hw_5_1/news_details_screen.dart';
import 'package:urmat_hw_5_1/news_service.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  String query = '';
  List<NewsArticleModel> articles = [];
  bool isLoading = true;
  String? errorText;
  Timer? searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  @override
  void dispose() {
    searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadArticles([String topic = '']) async {
    setState(() {
      isLoading = true;
      errorText = null;
    });

    try {
      final loadedArticles = await NewsService.fetchArticles(topic: topic);

      if (!mounted) return;

      setState(() {
        articles = loadedArticles;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorText = 'Could not load news. Check your internet connection.';
      });
    }
  }

  void _searchNews(String value) {
    setState(() => query = value);
    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 600), () {
      _loadArticles(value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: _searchNews,
                      decoration: InputDecoration(
                        hintText: 'Search topic...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        suffixIcon: Icon(Icons.search, color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 56),
                    const Text(
                      'Latest news',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        minHeight: 3,
                        color: Colors.black,
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: _buildNewsList(),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 38),
                child: Center(
                  child: Text(
                    'You reached the end.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsList() {
    if (errorText != null) {
      return SliverToBoxAdapter(
        child: _MessageBlock(
          icon: Icons.wifi_off,
          text: errorText!,
          buttonText: 'Try again',
          onPressed: () => _loadArticles(query.trim()),
        ),
      );
    }

    if (!isLoading && articles.isEmpty) {
      return const SliverToBoxAdapter(
        child: _MessageBlock(
          icon: Icons.search_off,
          text: 'No news found for this topic.',
        ),
      );
    }

    return SliverList.separated(
      itemCount: articles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 22),
      itemBuilder: (context, index) {
        return NewsCard(article: articles[index]);
      },
    );
  }
}

class _MessageBlock extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? buttonText;
  final VoidCallback? onPressed;

  const _MessageBlock({
    required this.icon,
    required this.text,
    this.buttonText,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[400], size: 42),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 14),
            TextButton(onPressed: onPressed, child: Text(buttonText!)),
          ],
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final NewsArticleModel article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailsScreen(article: article),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 118,
            height: 156,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(35, 0, 0, 0),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              article.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Container(
                  color: Colors.grey[100],
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[100],
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[500],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: SizedBox(
              height: 156,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.35,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    article.date,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    article.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
