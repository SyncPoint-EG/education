class CompletedLevel {
  final int stars;
  final bool completed;

  CompletedLevel({
    required this.stars,
    required this.completed,
  });

  CompletedLevel copyWith({
    int? stars,
    bool? completed,
  }) {
    return CompletedLevel(
      stars: stars ?? this.stars,
      completed: completed ?? this.completed,
    );
  }
}

class UserEntity {
  final String name;
  final String avatar;
  final int gold;
  final int gems;
  final int totalStars;
  final List<String> unlockedMilestones;
  final int currentLevel;
  final Map<int, CompletedLevel> completedLevels;
  final int totalSessions;
  final String createdAt;

  UserEntity({
    required this.name,
    required this.avatar,
    required this.gold,
    required this.gems,
    this.totalStars = 0,
    this.unlockedMilestones = const [],
    required this.currentLevel,
    required this.completedLevels,
    required this.totalSessions,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? name,
    String? avatar,
    int? gold,
    int? gems,
    int? totalStars,
    List<String>? unlockedMilestones,
    int? currentLevel,
    Map<int, CompletedLevel>? completedLevels,
    int? totalSessions,
    String? createdAt,
  }) {
    return UserEntity(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      gold: gold ?? this.gold,
      gems: gems ?? this.gems,
      totalStars: totalStars ?? this.totalStars,
      unlockedMilestones: unlockedMilestones ?? this.unlockedMilestones,
      currentLevel: currentLevel ?? this.currentLevel,
      completedLevels: completedLevels ?? this.completedLevels,
      totalSessions: totalSessions ?? this.totalSessions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
