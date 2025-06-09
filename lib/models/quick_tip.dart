class QuickTip {
  final String title;
  final String content;
  final String icon;
  final int priority;

  QuickTip({
    required this.title,
    required this.content,
    required this.icon,
    required this.priority,
  });

  factory QuickTip.fromJson(Map<String, dynamic> json) {
    return QuickTip(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      icon: json['icon'] ?? 'lightbulb',
      priority: json['priority'] ?? 1,
    );
  }
}

class QuickTipsResponse {
  final String categoryName;
  final List<QuickTip> tips;

  QuickTipsResponse({
    required this.categoryName,
    required this.tips,
  });

  factory QuickTipsResponse.fromJson(Map<String, dynamic> json) {
    return QuickTipsResponse(
      categoryName: json['categoryName'] ?? '',
      tips: (json['tips'] as List)
          .map((tip) => QuickTip.fromJson(tip))
          .toList(),
    );
  }
}