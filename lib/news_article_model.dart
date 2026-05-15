class NewsArticleModel {
  final String title;
  final String description;
  final String fullDescription;
  final String imageUrl;
  final String date;
  final String author;
  final String category;
  final String readTime;
  final String sourceUrl;

  const NewsArticleModel({
    required this.title,
    required this.description,
    required this.fullDescription,
    required this.imageUrl,
    required this.date,
    required this.author,
    required this.category,
    required this.readTime,
    required this.sourceUrl,
  });

  factory NewsArticleModel.fromJson(Map<String, dynamic> json) {
    final description = (json['description'] as String?)?.trim() ?? '';
    final content = (json['content'] as String?)?.trim() ?? '';
    final fullDescription = [
      if (description.isNotEmpty) description,
      if (content.isNotEmpty) content,
    ].join('\n\n');

    return NewsArticleModel(
      title: (json['title'] as String?)?.trim() ?? 'Untitled news',
      description: description.isEmpty
          ? 'No description provided.'
          : description,
      fullDescription: fullDescription.isEmpty
          ? 'No detailed description was provided for this article.'
          : fullDescription,
      imageUrl:
          (json['urlToImage'] as String?)?.trim() ??
          'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=900&q=80',
      date: _formatDate(json['publishedAt'] as String?),
      author: (json['author'] as String?)?.trim() ?? 'Unknown author',
      category: _readSourceName(json['source']),
      readTime: _readTime(fullDescription),
      sourceUrl: (json['url'] as String?)?.trim() ?? '',
    );
  }

  static String _readSourceName(dynamic source) {
    if (source is Map<String, dynamic>) {
      final name = source['name'] as String?;

      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }

    return 'News';
  }

  static String _formatDate(String? value) {
    if (value == null) return 'Unknown date';

    final date = DateTime.tryParse(value);

    if (date == null) return 'Unknown date';

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _readTime(String text) {
    final words = text.trim().split(RegExp(r'\s+')).where((word) {
      return word.isNotEmpty;
    }).length;
    final minutes = (words / 180).ceil().clamp(1, 30);

    return '$minutes min read';
  }
}
