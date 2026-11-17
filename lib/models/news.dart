class NewsPost {
  NewsPost({
    required this.id,
    required this.title,
    this.preview,
    this.datePublished,
    this.titlePicture,
  });

  final int id;
  final String title;
  final String? preview;
  final String? datePublished;
  final String? titlePicture;

  factory NewsPost.fromJson(Map<String, dynamic> json) {
    return NewsPost(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      preview: json['preview'] as String?,
      datePublished: json['datePublished'] as String?,
      titlePicture: json['titlePicture'] as String?,
    );
  }
}

class NewsGroup {
  NewsGroup({required this.monthName, required this.posts});

  final String monthName;
  final List<NewsPost> posts;

  factory NewsGroup.fromJson(Map<String, dynamic> json) {
    return NewsGroup(
      monthName: json['monthName'] as String? ?? '',
      posts: (json['posts'] as List? ?? [])
          .map((e) => NewsPost.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
