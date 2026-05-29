import 'dart:convert';

/// GitHub User model for list display
class GitHubUser {
  final int id;
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final String type;

  GitHubUser({
    required this.id,
    required this.login,
    required this.avatarUrl,
    required this.htmlUrl,
    required this.type,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
      type: json['type'] as String? ?? 'User',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'avatar_url': avatarUrl,
      'html_url': htmlUrl,
      'type': type,
    };
  }

  /// Convert to JSON string for storage
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory GitHubUser.fromJsonString(String jsonString) {
    return GitHubUser.fromJson(jsonDecode(jsonString));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GitHubUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  GitHubUser copyWith({
    int? id,
    String? login,
    String? avatarUrl,
    String? htmlUrl,
    String? type,
  }) {
    return GitHubUser(
      id: id ?? this.id,
      login: login ?? this.login,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      type: type ?? this.type,
    );
  }
}

/// Extended GitHub User model with detailed information
class GitHubUserDetail extends GitHubUser {
  final String? name;
  final String? company;
  final String? blog;
  final String? location;
  final String? email;
  final String? bio;
  final int publicRepos;
  final int publicGists;
  final int followers;
  final int following;
  final DateTime createdAt;

  GitHubUserDetail({
    required super.id,
    required super.login,
    required super.avatarUrl,
    required super.htmlUrl,
    required super.type,
    this.name,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.bio,
    required this.publicRepos,
    required this.publicGists,
    required this.followers,
    required this.following,
    required this.createdAt,
  });

  factory GitHubUserDetail.fromJson(Map<String, dynamic> json) {
    return GitHubUserDetail(
      id: json['id'] as int,
      login: json['login'] as String,
      avatarUrl: json['avatar_url'] as String,
      htmlUrl: json['html_url'] as String,
      type: json['type'] as String? ?? 'User',
      name: json['name'] as String?,
      company: json['company'] as String?,
      blog: json['blog'] as String?,
      location: json['location'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      publicRepos: json['public_repos'] as int? ?? 0,
      publicGists: json['public_gists'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'name': name,
      'company': company,
      'blog': blog,
      'location': location,
      'email': email,
      'bio': bio,
      'public_repos': publicRepos,
      'public_gists': publicGists,
      'followers': followers,
      'following': following,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a basic GitHubUser from detail
  GitHubUser toBasicUser() {
    return GitHubUser(
      id: id,
      login: login,
      avatarUrl: avatarUrl,
      htmlUrl: htmlUrl,
      type: type,
    );
  }
}
