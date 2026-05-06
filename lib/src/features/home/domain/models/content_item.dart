enum ContentType { image, video }

class ContentItem {
  final String id;
  final ContentType type;
  final String url;
  final String? thumbnailUrl;
  final String? title;
  final String? author;
  final String? authorAvatar;
  final int likes;
  final int comments;
  final int shares;
  final double? userRating;
  final DateTime createdAt;

  ContentItem({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.title,
    this.author,
    this.authorAvatar,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.userRating,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  ContentItem copyWith({
    String? id,
    ContentType? type,
    String? url,
    String? thumbnailUrl,
    String? title,
    String? author,
    String? authorAvatar,
    int? likes,
    int? comments,
    int? shares,
    double? userRating,
    DateTime? createdAt,
  }) {
    return ContentItem(
      id: id ?? this.id,
      type: type ?? this.type,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      author: author ?? this.author,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      userRating: userRating ?? this.userRating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
