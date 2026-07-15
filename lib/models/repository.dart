class Repository {
  final int id;
  final String name;
  final String? description;
  final String htmlUrl;
  final int stargazersCount;
  final String? language;
  final bool fork;

  const Repository({
    required this.id,
    required this.name,
    required this.htmlUrl,
    this.description,
    this.stargazersCount = 0,
    this.language,
    this.fork = false,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      htmlUrl: json['html_url'] as String,
      stargazersCount: (json['stargazers_count'] as int?) ?? 0,
      language: json['language'] as String?,
      fork: (json['fork'] as bool?) ?? false,
    );
  }
}
